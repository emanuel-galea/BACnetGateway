#include <stdio.h>
#include <termio.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <inttypes.h>
#include <stdlib.h>
#include <unistd.h>
#include "syslog.h"
#include <errno.h>
#include <string.h>
#include <pty.h>
#include <stdint.h>
#include <stdbool.h>
#include "matrix500.h"
#include "sys/stat.h"

#include "ArrayList.h"
#include "ezxml.h"
#include "Modbus.h"
#include "tables.h"

#define REC_BUFFER_LENGTH 256
#define DEFAULT_BAUD 2400
#define DEFAULT_PORT "/dev/ptys3"

typedef struct _serialPort {
	int portFD;
	uint8_t mbusAddress; // current Address
	char * portName;
	struct termios portstate_orig;
	int baudrateIndex;
} SerialPort;

int readSerialPort(SerialPort * pSerialPort);
static uint16_t crc16(uint16_t buffer_length, uint8_t *buffer);

uint8_t recBuffer[REC_BUFFER_LENGTH];
uint8_t sendBuffer[REC_BUFFER_LENGTH];
static char pSimFile[128];
static char pOutputFile[128];
static char pCrash[1];

pid_t pid;
int fd;
struct termios tty_state;
const int baudrateDelay[] = { 1200, 650, 400, 370, 300, 200, 200, 200 }; // milliseconds

static const int baudrateInterface[] = { B300, B600, B1200, B2400, B4800, B9600, B19200, B38400 };

const int baudrates[] = { 300, 600, 1200, 2400, 4800, 9600, 19200, 38400 };

static char decimalPoint[5][5] = { { "%.0f" }, { "%.1f" }, { "%.2f" }, { "%.3f" } };
static int decimalPointRound[4] = { 1, 10, 100, 1000 };

bool debug;
bool trace;
static char* pidFile;

typedef struct _MbusSlave {
	uint8_t address;
	uint8_t * class2Data;
	uint8_t * class2Data2;
	bool autoChecksum;
	int dataLength;
	int dataLength2;
} MbusSlave;

typedef struct _ModbusObjectDef {
	int address;
	int function;
	int subAddress;
	bool autoChecksum;
	int dataLength;
	uint8_t * data;
} ModbusObjectDef;

Arraylist meterArraylist;
Arraylist modbusArraylist;

char serialPortName[32];
static char initMessage[64];
int baudrateIndex;
bool bEnableTracer;
bool rs485;

char slaveName[32];

SerialPort serialPort;

/**
 *      Fast CRC
 *
 */
static uint16_t crc16(uint16_t buffer_length, uint8_t *buffer) {
	uint8_t crc_hi = 0xFF; /* high CRC byte initialized */
	uint8_t crc_lo = 0xFF; /* low CRC byte initialized */
	unsigned int ind; /* will index into CRC lookup */

	/* pass through message buffer */
	while (buffer_length--) {
		ind = crc_hi ^ *buffer++; /* calculate the CRC  */
		crc_hi = crc_lo ^ tableCrcHigh[ind];
		crc_lo = tableCrcLow[ind];
	}
	return (crc_hi << 8 | crc_lo);
}

static void printReal(float value) {
	float real;
	int64_t longValue;
	printf("Printing value: %.1f , ", value);
	value = value * decimalPointRound[2];
	longValue = value;
	real = (float) longValue / decimalPointRound[2];
	printf(decimalPoint[2], real);
	printf("\n");
}

static void printRealDouble(double value) {
	double real;
	int64_t longValue;
	printf("Printing value: %.1f , ", value);
	value = value * decimalPointRound[2];
	longValue = value;
	real = (double) longValue / decimalPointRound[2];
	printf(decimalPoint[2], real);
	printf("\n");
}
/**
 *
 *
 */
int setBaudrate(int baudrate) {
	//	char buffer[32];
	//	syslog(LOG_DEBUG, "set Baudrate to %d \n", baudrates[baudrate]);
	cfsetispeed(&tty_state, baudrateInterface[baudrate]);
	cfsetospeed(&tty_state, baudrateInterface[baudrate]);
	if (tcsetattr(serialPort.portFD, TCSANOW, &tty_state) < 0) {
		syslog(LOG_ERR, "set Baudrate ERROR ");
	}
	return 0;
}
/**
 *
 */

int dataToBinary(char * pText, uint8_t * pData) {
	char ch;
	int value;
	int dataLength = 0;
	while (*pText != 0) {
		value = 0;
		ch = *pText++;
		if ((ch >= '0') && (ch <= '9')) {
			value = ch - '0';
		} else if ((ch >= 'A') && (ch <= 'F')) {
			value = (ch - 'A') + 10;
		} else if ((ch >= 'a') && (ch <= 'f')) {
			value = (ch - 'a') + 10;
		} else {
			continue;
		}
		if (pText != 0) {
			ch = *pText++;
			value = value << 4;
			if ((ch >= '0') && (ch <= '9')) {
				ch = ch - '0';
			} else if ((ch >= 'A') && (ch <= 'F')) {
				ch = (ch - 'A') + 10;
			} else if ((ch >= 'a') && (ch <= 'f')) {
				ch = (ch - 'a') + 10;
			}
			value |= ch & 0xF;
			pData[dataLength++] = value;
		}
	}
	return dataLength;
}

/**
 *
 */
int checkAddress(int length) {
	int ind = 0;
	uint16_t s_crc;
	int retValue;
	uint8_t checksum;
	bool found = false;
	MbusSlave * pMbusSlave;
	ModbusObjectDef * pModbusObjectDef;
	int bufferLength;
	int i;
	if (length < 5) {
		return -1;
	}

	if (recBuffer[0] == 0x10) { // short frame
		for (ind = 0; ind < arraylist_size(meterArraylist); ind++) {
			pMbusSlave = arraylist_get(meterArraylist, ind);
			if (recBuffer[2] == pMbusSlave->address) {
				found = true;
				break; // address found
			}
		}
		if (found) {
			// which command
//			sleep(1);
			if (recBuffer[1] == 0x40) {
				sendBuffer[0] = 0xE5;
				retValue = write(serialPort.portFD, &sendBuffer[0], 1);
				if (trace) {
					printf("Send E5  to %d \n", pMbusSlave->address);
				}
			} else {
				if (recBuffer[1] == 0x5B) {
					if (pMbusSlave->dataLength2 == 0) {
						printf("5B record received but ther is only one data record present");
						return 0;
					}
					if (pMbusSlave->dataLength > 0) {
						bufferLength = pMbusSlave->dataLength;
						memcpy(sendBuffer, pMbusSlave->class2Data, pMbusSlave->dataLength);
					} else {
						return 0;
					}
				} else if (recBuffer[1] == 0x7B) {
					if (pMbusSlave->dataLength2 > 0) {
						bufferLength = pMbusSlave->dataLength2;
						memcpy(sendBuffer, pMbusSlave->class2Data2, pMbusSlave->dataLength2);
					} else if (pMbusSlave->dataLength > 0) {
						bufferLength = pMbusSlave->dataLength;
						memcpy(sendBuffer, pMbusSlave->class2Data, pMbusSlave->dataLength);
					} else {
						return 0;
					}
				}
				if (pMbusSlave->autoChecksum) {
					checksum = 0;
					for (ind = 4; ind < bufferLength - 2; ind++) {
						checksum += sendBuffer[ind];
					}
					sendBuffer[bufferLength - 2] = checksum;
				}
				write(serialPort.portFD, &sendBuffer[0], bufferLength);

				if (trace) {
					printf("SEND DATA length %d, DATA: ", bufferLength);
					if (bufferLength > 0) {
						for (i = 0; i < bufferLength; i++) {
							printf("%02X ", sendBuffer[i]);
						}
					}
					printf("\n");
				}

			}
		}

	} else {
		// Then it must be a MODBUS
		found = false;
		int startingAddress;
		for (ind = 0; ind < arraylist_size(modbusArraylist); ind++) {
			pModbusObjectDef = arraylist_get(modbusArraylist, ind);


			if ((recBuffer[0] == pModbusObjectDef->address) && (recBuffer[1] == pModbusObjectDef->function)) {
				// lets assume MODBUS
				printf("Modbus Address %d, Function %d, subAddress %d \n", pModbusObjectDef->address,
									pModbusObjectDef->function, pModbusObjectDef->subAddress);
				switch (recBuffer[1]) { //modbus function

				case FC_READ_COIL_STATUS:
				case FC_READ_INPUT_STATUS:
				case FC_READ_HOLDING_REGISTERS:
				case FC_READ_INPUT_REGISTERS:
					startingAddress = recBuffer[2] << 8;
					startingAddress |= recBuffer[3];
					if (startingAddress == pModbusObjectDef->subAddress) {
						found = true;
					}
					break;

				case FC_READ_DEVICE_IDENTIFICATION:
					found = true;
					break;

				}
				if (found) {
					break;
				}
			}
		} // for modbus
		if (found) {
			length = pModbusObjectDef->dataLength;
			memcpy(sendBuffer, pModbusObjectDef->data, length);
			if (pModbusObjectDef->autoChecksum) {
				s_crc = crc16(pModbusObjectDef->dataLength, sendBuffer);
				sendBuffer[length++] = s_crc >> 8;
				sendBuffer[length++] = s_crc & 0x00FF;
			}
			if (sendBuffer[0] == 0x01) {
				write(serialPort.portFD, &sendBuffer[0], 3);
				usleep(40000); // 2milli
				write(serialPort.portFD, &sendBuffer[3], length - 3);
			} else {
				usleep(2000); // 2milli
				write(serialPort.portFD, &sendBuffer[0], length);
			}
			if (debug) {
				printf("Send data Length %d to %d \n", length, pModbusObjectDef->address);
			}

		}

	}

	return 0;
}

uint8_t * writeFile(char * fileName, char * buffer) {

	FILE * pFile;
	pFile = fopen(fileName, "w");
	if (pFile == NULL) {
		return NULL;
	}
	fputs(buffer, pFile);
	fclose(pFile);
	return buffer;
}

/**
 *
 *
 */
uint8_t * readFile(char * fileName, int * pLength) {
	long lSize;
	long result;
	uint8_t * buffer;
	FILE * pFile;
	pFile = fopen(fileName, "r");
	if (pFile == NULL) {
		//		fprintf(stderr, "File error: %s \n", filePath);
		return NULL;
	}

	// obtain file size:
	fseek(pFile, 0, SEEK_END);
	lSize = ftell(pFile);
	rewind(pFile);

	buffer = (uint8_t *) malloc(sizeof(char) * lSize);
	if (buffer == NULL) {
		fputs("Memory error", stderr);
		return NULL;
	}

	// copy the file into the buffer:
	result = fread(buffer, 1, lSize, pFile);
	if (result != lSize) {
		fputs("Reading error", stderr);
		free(buffer);
		return NULL;
	}
	*pLength = lSize;
	fclose(pFile);
	//	free(buffer);
	return buffer;
}

/**
 *
 *
 */
int readSimulatorConfiguration() {
	int dataLength;
	//	int baudindexLocal;
	MbusSlave * pMbusSlave;
	ModbusObjectDef * pModbusObjectDef;
	char fileName[128];
	uint8_t * pData;
	char *pText;
	char * buffer;
	ezxml_t ezRoot;
	int mbusAddress;
	ezxml_t ezMeter, ezMeters, ezTemp, ezModbus, ezModbusObject;
	strcpy(fileName, pSimFile);

//	strcpy(fileName, "./simulator.xml");

	buffer = (char *) readFile(fileName, &dataLength);
	if (buffer == NULL) {
		fprintf(stderr, "No Configuration File found at %s", fileName);
		return -1;
	}
	printf("Reading Configuration File %s \n", fileName);
	ezRoot = ezxml_parse_str(buffer, dataLength);

	//	ezTemp = ezxml_child(ezMBus, ENABLE_TRACE);
	//	enableTracer = false;
	//	if (ezTemp != NULL && ezTemp->txt != NULL) {
	//		if (strcmp(ezTemp->txt, "true") && tracerIp[0] != 0) {
	//			enableTracer = true;
	//		}
	//	}
	ez_getChildBool(ezRoot, "rs485", &rs485);
	ez_getChildInt(ezRoot, "baudrate", &baudrateIndex, 3); // default baud is 2400
	ez_getChild(ezRoot, "portName", &fileName[0], DEFAULT_PORT);

	strcpy(serialPortName, "/dev/");
	strcat(serialPortName, fileName);
	fprintf(stderr, "Port Name %s \n Meters: ", serialPortName);
	ezMeters = ezxml_child(ezRoot, "meters");
	for (ezMeter = ezxml_child(ezMeters, "meter"); ezMeter != NULL; ezMeter = ezMeter->next) {
		dataLength = 0;
		ezTemp = ezxml_child(ezMeter, "data");
		if (ezTemp != NULL && ezTemp->txt != NULL) {
			pData = malloc(256);
			pText = ezTemp->txt;
			dataLength = dataToBinary(pText, pData);
			if (dataLength > 0) {
				ez_getChildInt(ezMeter, "address", &mbusAddress, 0xff);
				pMbusSlave = malloc(sizeof(MbusSlave));
				memset(pMbusSlave, 0, sizeof(MbusSlave));
				if (mbusAddress == 0xff && dataLength > 5) {
					mbusAddress = pData[5];
				}
				ez_getChildBool(ezMeter, "autoChecksum", &pMbusSlave->autoChecksum);
				pMbusSlave->class2Data = pData;
				pMbusSlave->dataLength = dataLength;
				ezTemp = ezxml_child(ezMeter, "data2");
				if (ezTemp != NULL && ezTemp->txt != NULL) {
					pData = malloc(256);
					pText = ezTemp->txt;
					dataLength = dataToBinary(pText, pData);
					pMbusSlave->class2Data2 = pData;
					pMbusSlave->dataLength2 = dataLength;
				}
				pMbusSlave->address = mbusAddress;
				fprintf(stderr, " %d ", mbusAddress);
				arraylist_add(meterArraylist, pMbusSlave);
			}

		}
	} // for
	/**
	 *  read modbus
	 */
	fprintf(stderr, "\n");
	ezModbus = ezxml_child(ezRoot, "modbus");
	for (ezModbusObject = ezxml_child(ezModbus, "object"); ezModbusObject != NULL;
			ezModbusObject = ezModbusObject->next) {
		dataLength = 0;
		ezTemp = ezxml_child(ezModbusObject, "data");
		if (ezTemp != NULL && ezTemp->txt != NULL) {
			pData = malloc(256);
			pText = ezTemp->txt;
			dataLength = dataToBinary(pText, pData);
			if (dataLength > 0) {
				pModbusObjectDef = malloc(sizeof(ModbusObjectDef));
				ez_getChildInt(ezModbusObject, "address", &pModbusObjectDef->address, 0xff);
				ez_getChildInt(ezModbusObject, "function", &pModbusObjectDef->function, 0xff);
				ez_getChildInt(ezModbusObject, "subAddress", &pModbusObjectDef->subAddress, 0xffff);
				ez_getChildBool(ezModbusObject, "autoChecksum", &pModbusObjectDef->autoChecksum);
				pModbusObjectDef->data = pData;
				pModbusObjectDef->dataLength = dataLength;
				arraylist_add(modbusArraylist, pModbusObjectDef);
			}
		}

	}
	fprintf(stderr, "Read configuration: Ready\n");
	return 0;
}
/**
 *
 *
 */
static void cleanup(void) {
	remove("/tmp/mbus_simulator_port.txt");
}
/**
 *
 *
 */
int initSerialInterface() {
	int retValue, interface;
	int ptn, bit;

	char ptname[100];

	serialPort.portName = &serialPortName[0];
	if ((retValue = serialPort.portFD = open(serialPort.portName, O_RDWR)) < 0) {
		sprintf(&initMessage[0], "ERROR: Failed to open port %s error %s", serialPort.portName, strerror(errno));
		fprintf(stderr, "%s\n", initMessage);
		return -1;
	}
//ifdef X86
	if (strcmp("/dev/ptmx", serialPort.portName) == 0) {
		ioctl(serialPort.portFD, TIOCGPTN, &ptn);
		bit = 0;
		ioctl(serialPort.portFD, TIOCSPTLCK, &bit);
		snprintf(ptname, 32, "/dev/pts/%d", ptn);
		printf("Slave Port is %s\n", ptname);
		writeFile(pOutputFile, ptname);
		chmod(ptname, S_IRUSR | S_IWUSR);
	}
//endif
	printf("BaudRate is %d\n", baudrates[baudrateIndex]);

	//	if ((retValue = serialPort.portFD = open(serialPort.portName, O_RDWR)) < 0) {
	//			sprintf(&initMessage[0], "ERROR: Failed to open port %s error %s", serialPort.portName, strerror(errno));
	//			fprintf(stderr, "%s\n", initMessage);
	//			return -1;
	//	}

	printf("Serial Port is %s\n", serialPortName);
#ifdef ARTILA
	if (ioctl(serialPort.portFD, UC500_GET_UART_TYPE, &interface) == 0) {
		printf("UART Type:%d\n", interface);
	}
	if (rs485) {
		interface = UC500_UART_TYPE_485;
	} else {
		interface = UC500_UART_TYPE_232;
	}
	// needed for Artila Matrix 500
	if (ioctl(serialPort.portFD, UC500_SET_UART_TYPE, &interface) != 0) {
		printf("set UART type: %d...Failed, errno: %d\r\n", interface, errno);
		//		close(serialPort.portFD);
		//		return -1;
	}
	if (ioctl(serialPort.portFD, UC500_GET_UART_TYPE, &interface) == 0) {
		printf("UART Type is now :%d \n", interface);
	}
	// close and open again is neede by Artila Matrix
	close(serialPort.portFD);
	if ((retValue = serialPort.portFD = open(serialPort.portName, O_RDWR)) < 0) {
		sprintf(&initMessage[0], "ERROR : Failed to Re-open port %s error %s", serialPort.portName, strerror(errno));
		fprintf(stderr, "%s\n", initMessage);
		return -1;
	}
#endif

	printf("Serial Port initialized\n");
	fflush(stdout);
	/* set tty into raw mode */

	if ((retValue = tcgetattr(serialPort.portFD, &serialPort.portstate_orig)) < 0) {
		perror("tcgetattr Failed ");
		return -2;
	}
	/* save off original settings */
	bzero(&tty_state, sizeof(tty_state));
	//	tty_state.c_lflag = 0; //ICANON;


 	tty_state.c_iflag |= INPCK; // Enable input parity checking.
 	tty_state.c_iflag |= PARMRK; // Enable input parity checking.

	tty_state.c_cflag |= (CLOCAL); // Enable Parity  ignore modem lines
	tty_state.c_cflag |= (PARENB); // Enable Parity  ignore modem lines
	//tty_state.c_cflag &= ~(PARODD); // Enable Parity EVEN
	//	tty_state.c_cflag |= PARODD; // TESTING Enable Parity ODD

//	tty_state.c_cflag &= ~(CSTOPB | CSIZE); // EVEN Parity, only one stop bit
//	tty_state.c_cflag &= ~(CSIZE); // EVEN Parity, only one stop bit
//	tty_state.c_cflag |= CSTOPB; // two stop bits
	tty_state.c_cflag |= CS8; // 8 bit
	tty_state.c_cflag |= CREAD; // enable receiver
	//	tty_state.c_cflag |= CRTSCTS; // enable RTS
	tty_state.c_cc[VMIN] = 1;
	tty_state.c_cc[VTIME] = 10; // 500 milli seconds
	cfsetispeed(&tty_state, baudrateInterface[baudrateIndex]);
	cfsetospeed(&tty_state, baudrateInterface[baudrateIndex]);

	//	cfsetispeed(&tty_state, tty_data.baudrate);
	//	cfsetospeed(&tty_state, tty_data.baudrate);
	tcflush(serialPort.portFD, TCIFLUSH);
	if ((retValue = tcsetattr(serialPort.portFD, TCSADRAIN, &tty_state)) < 0) {

		printf("Setting Serial Port settings failed %d-%s", errno, strerror(errno));
		perror("tcsetattr Failed ");
		return -3;
	}
	printf("Serial Port initialized");
	return 0;
}

/**
 *   M A I N
 *
 */
int main(int argc, char *argv[]) {

//	char sendCommand[] = { 05, 0x04, 0x13, 0xBB, 0x00, 0x01, 0x44, 0xEF };

	char * pChar;
	strcpy(pSimFile, argv[0]);
	pChar = strrchr(pSimFile, '/');
	if (pChar != NULL) {
		strcpy(pChar, "/simulator.xml");
	}
	printf("Revision 94\n");
	strcpy(pOutputFile, "/tmp/kara_simulator_port");

	debug = false;
	trace = false;
	int argn = 1;
	while (argn < argc && argv[argn][0] == '-') {
		if (strcmp(argv[argn], "-D") == 0) {
			debug = true;
			printf("DEBUG mode\n");
		} else if (strcmp(argv[argn], "-t") == 0) {
			trace = true;
			printf("TRACE mode\n");
		} else if (strcmp(argv[argn], "-i") == 0 && argn + 1 < argc) {
			++argn;
			pidFile = argv[argn];
		} else if (strcmp(argv[argn], "-f") == 0 && argn + 1 < argc) {
			++argn;
			strcpy(pSimFile, argv[argn]);

		} else if (strcmp(argv[argn], "-c") == 0 && argn + 1 < argc) {
			++argn;
			strncpy(pCrash, argv[argn], 100000);
			abort();
			printf("simulator File is %s\n", pSimFile);
		}

		++argn;
	}

	printf("Output File port is %s\n", pOutputFile);

	printf("debug %d,  PID %s\n", debug, pidFile);
	/*******************************************************
	 *
	 */
	printf("Float experiments \n");
	printReal(1234.12);
	printReal(21474863);
	printReal(31474863);
	printReal(12345678);
	printReal(9987654321.1234);
	printf("Double experiments \n");
	printRealDouble(1234.12);
	printRealDouble(21474863);
	printRealDouble(31474863);
	printRealDouble(12345678);
	printRealDouble(9987654321.1234);
	printf("\n");

	/***************************************************************************************		*/

	if (debug == false) {
		if (daemon(1, 1) < 0) {
			syslog(LOG_CRIT, "daemon - %m");
			perror("daemon");
			exit(1);
		}
	}
	(void) setsid();

	if (pidFile != (char*) 0) {
		/* Write the PID file. */
		FILE* pidfp = fopen(pidFile, "w");
		if (pidfp == (FILE*) 0) {
			syslog(LOG_CRIT, "%s - %m", pidFile);
			perror(pidFile);
			//			exit(1);
		}
		(void) fprintf(pidfp, "%d\n", (int) getpid());
		(void) fclose(pidfp);
	}

	int retValue;
	atexit(cleanup);
	meterArraylist = arraylist_create(NULL);
	modbusArraylist = arraylist_create(NULL);
	readSimulatorConfiguration();
	retValue = initSerialInterface();
	if (retValue != 0) {
		printf("Serila Initialization error %d\n", retValue);
		exit(1);
	}

//	setBaudrate(baudrateIndex);
	printf("waiting for data");
	fflush(stdout);

	while (1) {

//		write(serialPort.portFD, &sendCommand[0], 8);
//		usleep(20000);
//		tcdrain(serialPort.portFD);
//		tcflush(serialPort.portFD, TCIFLUSH); // empty receive buffer first
		usleep(500);
		retValue = readSerialPort(&serialPort);
		if (retValue == 0) {
			//			retValue = initSerialInterface();
			//			if (retValue != 0) {
			//					printf("Serila Initialization error %d\n", retValue);
			//			}
			usleep(20);
			continue;
		}
		if (retValue < 1) {
			if (trace) {
				fprintf(stderr, "Communication Error %d %s", retValue, strerror(errno));
				perror("Communication Error ");
			}
//			retValue = initSerialInterface();
//			if (retValue != 0) {
//				printf("Serila Initialization error %d\n", retValue);
//			}
			continue;
			//			exit(3);
		}
		usleep(1000);
		checkAddress(retValue);
		arraylist_clear(meterArraylist);
		readSimulatorConfiguration();
	}

}

/**
 *
 * @return 0 = nothing received, LT 0  means error, GT 0 lenght of data received
 *
 */
int readSerialPort(SerialPort * pSerialPort) {

	int retValue;
	int i;
	struct timeval tv;
	int recIndex = 0;
	int timeout;
//	timeout = baudrateDelay[pSerialPort->baudrateIndex];
	timeout = 20000;
	tcflush(pSerialPort->portFD, TCIFLUSH); // empty receive buffer first
	while (1) {
		if (timeout >= 1000) {
			tv.tv_sec = timeout / 1000;
			tv.tv_usec = (timeout % 1000) * 1000;
		} else {
			tv.tv_sec = 0;
			tv.tv_usec = timeout * 1000;
		}
		fd_set rset;
		FD_ZERO(&rset);
		FD_SET(pSerialPort->portFD, &rset);
		retValue = select(pSerialPort->portFD + 1, &rset, NULL, NULL, &tv);
		if (errno == EINTR) {
			printf("A non blocked signal was caught\n");
			/* Necessary after an error */
			FD_ZERO(&rset);
			FD_SET(pSerialPort->portFD, &rset);
			continue;
		}
		if (retValue == 0) {
//			printf("Timeout\n");
			retValue = recIndex;
			break;
		} else if (retValue < 0) {
			fprintf(stderr, "Select Error: %s\n", strerror(errno));
			break;
		} else {
			if (FD_ISSET(pSerialPort->portFD, &rset)) {
				/* data coming from device */
				usleep(100); // wait for the rest
				retValue = read(pSerialPort->portFD, &recBuffer[recIndex], REC_BUFFER_LENGTH - recIndex);
				if (retValue == -1) {
					break;
				}
				recIndex += retValue;
				//				printf("Data recieved length=%d  -  ", retValue);
				if (trace) {
					printf("length: %d \n", retValue);
				}
				//				fprintf(stderr, "data recieved %d", retValue);

				timeout = 50; // 50 milliseconds
				//				return recIndex;
			}
			//			tv.tv_sec = 0;
			//			tv.tv_usec = 150 * 1000; // 150 milli
			//			usleep(10000);		// 10 milli
			//			if (debug) {
			//				printf("Data Received %d ", retValue);
			//			}
		}

	} // while
//		if (sock_fd != 0 && retValue > 0) {
//			sendto(sock_fd, recBuffer, retValue, 0, (struct sockaddr *) &traceDestinationSockAddr,
//					sizeof(struct sockaddr));
//		}
	if (trace && (recIndex > 0)) {
		printf("Data Received Port %d, length %d, DATA: ", pSerialPort->mbusAddress, recIndex);
		if (retValue > 0) {
			for (i = 0; i < retValue; i++) {
				printf("%02X ", recBuffer[i]);
			}
		}
		printf("\n");
		retValue = recIndex;
	}

	fflush(stdout);
	return retValue;
}
