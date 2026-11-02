/*
 * bacConfig.cpp
 *
 *  Created on: Sep 28, 2009
 *      Author: emanuel
 */

#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <syslog.h>
#include <string.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <netinet/in.h>
#include <signal.h>
#include "Configuration.h"
#include "Parser.h"
#include <errno.h>
#include <dirent.h>
#include "HtmlParser.h"
#include "ezxml.h"

#define KEY (1492)

char action;
char ipAddress[32];
char mask[32];
char port[6];
char page[32];
char maxAPDU[16];
char tracerip[64];
char bbmd_index[4];
bool saveAction;
bool iamAction;

const char bacnetIp[] = { "BACnet/IP" };
const char bacnetEthernet[] = { "BACnet/Ethernet" };
const char bacnetTypeOption[] = { "bacnetTypeOption" };

char message[128];
char consume[16];

#define DEBIAN_SYSLOG   "/etc/syslog.conf"

#define COMMAND_SEND_IAM 'E'

#define KEY (1492)

volatile int alarm_triggered = 0;
volatile bool waitingResponce;
struct sembuf operations[2];
int semId; /* Internal identifier of the semaphore. */

void alarm_handler(int sig) {
	alarm_triggered = 1;
	//	fprintf(stderr, " ALARM\n");
	if (waitingResponce) {
		operations[0].sem_num = 0; //signifies 0th semaphore
		operations[0].sem_op = 1; //reduce the semaphore count to lock
		operations[0].sem_flg = 0; //wait till we get lock on semaphore
		if (semop(semId, operations, 1) == -1) {
			perror("Thread1:semop failure Reason:");
		}
		exit(-1);
	}
	//	exit(-1);
}

//ezxml_t ezOutput;

/* index and text pairs */
//typedef struct {
//	unsigned index; /* index number that matches the text */
//	const char *pString; /* text pair - use NULL to end the list */
//} INDTEXT_DATA;
//INDTEXT_DATA loggingTag[] = {
//		{
//				LOG_EMERG, "Emergency" }, {
//				LOG_ALERT, "Alert" }, {
//				LOG_CRIT, "Critical" }, {
//				LOG_ERR, "Error" }, {
//				LOG_WARNING, "Warning" }, {
//				LOG_NOTICE, "Notice" }, {
//				LOG_INFO, "Info" }, {
//				LOG_DEBUG, "Debug" }, {
//				-1, NULL }, };
//INDTEXT_DATA baudrates[] = {
//		{
//				300, "300" }, {
//				600, "600" }, {
//				1200, "1200" }, {
//				2400, "2400" }, {
//				4800, "4800" }, {
//				9600, "9600" }, {
//				19200, "19200" }, {
//				38400, "38400" }, {
//				-1, NULL }, };
//bool indtext_by_string(INDTEXT_DATA * data_list, const char *search_name, unsigned *found_index) {
//	bool found = false;
//	unsigned index = 0;
//
//	if (data_list && search_name) {
//		while (data_list->pString) {
//			if (strcmp(data_list->pString, search_name) == 0) {
//				index = data_list->index;
//				found = true;
//				break;
//			}
//			data_list++;
//		}
//	}
//
//	if (found && found_index)
//		*found_index = index;
//
//	return found;
//}
/**
 *
 */
//void writeOptions(char * header, INDTEXT_DATA * data_list) {
//	printf("<%s>", header);
//	while (data_list->pString) {
//		printf("<option>%s</option>\n", data_list->pString);
//		data_list++;
//	}
//	printf("</%s>\n", header);
//}

/**
 *
 *
 */
ezxml_t getDeviceElement(ezxml_t ezRoot, char * element) {
	int instance, type;
	ezxml_t ezTemp, ezObject, ezInstance, ezTemp2;

	ezTemp = ezxml_child(ezRoot, "objects");
	if (ezTemp != NULL) {
		for (ezObject = ezxml_child(ezTemp, "object"); ezObject; ezObject = ezObject->next) {
			ezInstance = ezxml_child(ezObject, element);
			if (ezInstance == NULL) {
				syslog(LOG_ERR, "Instance is NULL");
				continue;
			}
			ezTemp2 = ezxml_child(ezObject, "type");
			if (ezTemp2 == NULL || ezTemp2->txt == NULL) {
				syslog(LOG_ERR, "ObjectType is null");
				return NULL;
			}
			if (strcmp(ezTemp2->txt, "Device") == 0) {
				return ezInstance;
			}
		}
	}
	return NULL;
}
/**
 *
 */
int checkBBDMEntry() {
	// if there is any new BBMD
	struct in_addr ip_addr;
	if (ipAddress[0] == 0x0 || mask[0] == 0x0 || port[0] == 0) {
		return 1;
	}
	if (atoi(port) == 0) {
		return 2;
	}
	ip_addr.s_addr = inet_addr(ipAddress);
	if (ip_addr.s_addr == -1) {
		return 3;
	}
	ip_addr.s_addr = inet_addr(mask);
	if (ip_addr.s_addr == -1 && strcmp(mask, "255.255.255.255") != 0) {
		return 4;
	}
	return 0;
}
/**
 *
 *
 */
void parseInput(ezxml_t ezRoot, char * inputParameters) {
	char* word = NULL;
	int wordLength = 0;
	int retValue;
	int entryIndex;
	int ind;

	ezxml_t ezElement, ezTemp, ezTemp2, ezMBus, ezBaudrates, ezBBMD;
	int position = 0;
	int logEntries;
	mask[0] = 0x0;
	ipAddress[0] = 0x0;
	bbmd_index[0] = 0x0;
	tracerip[0] = 0x0;
	port[0] = 0;
	consume[0] = 0x0;
	maxAPDU[0] = 0x0;
	char * txt;
	action = '0';
	saveAction = false;
	iamAction;
	char temp[64];
	int inputLength = strlen(inputParameters);

	getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
	if (word != NULL && wordLength > 0) {
		if (strncmp(word, "action", wordLength) == 0) {
			getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			action = word[0];
			//		   syslog(LOG_ERR, "ACTION =%d", (int)action );
			//			if (action < '9') {
			// BACnet configuration parsing
			strcpy(page, "../bacConfig.xsl");
			setTxt(ezRoot, "0", 1, "bacnetTrace");
			while (position < inputLength) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				if (word != NULL && wordLength > 0) {
					if (strncmp(word, "deviceInstance", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						ezElement = getDeviceElement(ezRoot, "instance");
						setTxt(ezElement, &word[0], wordLength, NULL);
					} else if (strncmp(word, "deviceName", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						ezElement = getDeviceElement(ezRoot, "name");
						setTxtDecode(ezElement, &word[0], wordLength, NULL);
					} else if (strncmp(word, "maxAPDU", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						setTxt(ezRoot, &word[0], wordLength, "maxAPDU");
					} else if (strncmp(word, "iamTime", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						setTxt(ezRoot, &word[0], wordLength, "iamTime");
					} else if (strncmp(word, "bacnetTypeOption", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						setTxt(ezRoot, &word[0], wordLength, "bacnetTypeValue");
					} else if (strncmp(word, "mask", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						if (wordLength < 32) {
							strncpy(mask, word, wordLength);
						}
					} else if (strncmp(word, IP_ADDRESS, wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						if (wordLength < 32) {
							strncpy(ipAddress, word, wordLength);
						}
					} else if (strncmp(word, "save", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						saveAction = true;
					} else if (strncmp(word, "iam", wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						iamAction = true;
					} else if (strncmp(word, PORT, wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						if (wordLength < 6) {
							strncpy(port, word, wordLength);
						}
					} else if (strncmp(word, BBMD_ENTRY_INDEX, wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						if (wordLength < 2) {
							strncpy(bbmd_index, word, wordLength);
						}
					} else if (strncmp(word, ENABLE_TRACE, wordLength) == 0) {
						getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
						setTxt(ezRoot, &word[0], wordLength, ENABLE_TRACE);
					}
				}
			} // while
			if (action == '1') { // delete bbmd entry
				entryIndex = atoi(bbmd_index);
				ezBBMD = ezxml_child(ezRoot, "bbmd");
				ind = 1;
				for (ezTemp = ezxml_child(ezBBMD, BBMD_ENTRY); ezTemp != NULL; ezTemp = ezTemp->next) {
					if (entryIndex == ind) {
						ezxml_cut(ezTemp);
						ezxml_free(ezTemp);
						saveAction = true;
						break;
					}
					ind++;
				}
			} else {

				retValue = checkBBDMEntry();
				switch (retValue) {
				case 0:
					ezBBMD = ezxml_child(ezRoot, "bbmd");
					ezTemp = ezxml_add_child(ezBBMD, "entry", 0);
					setTxt(ezTemp, ipAddress, strlen(ipAddress), IP_ADDRESS);
					setTxt(ezTemp, mask, strlen(mask), MASK);
					setTxt(ezTemp, port, strlen(ipAddress), PORT);
					break;
				case 1: // no entries
				case 2: // wrong  port
				case 3: // wrong Ip
				case 4: // wrong mask
					break;

				}
			}

			//			} else {
			//				// MBus
			//				strcpy(page, "../mbusConfig.xsl");
			//				ezMBus = ezxml_child(ezRoot, "MBus");
			//				ezBaudrates = ezxml_child(ezMBus, "baudrates");
			//				setTxt(ezMBus, "0", 3, "mbusTrace");
			//				setTxt(ezMBus, "off", 3, "rs485");
			//				setTxt(ezMBus, "off", 3, "consumption");
			//				// set all baudrates to false
			//				for (ezTemp = ezxml_child(ezBaudrates, "option"); ezTemp; ezTemp = ezTemp->next) {
			//					ezxml_set_attr(ezTemp, "enabled", "false");
			//				}
			//				while (position < inputLength) {
			//					getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//					if (word != NULL && wordLength > 0) {
			//						if (strncmp(word, "mbusTrace", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							if (strncmp(word, "on", wordLength) == 0) {
			//								setTxt(ezRoot, &word[0], wordLength, "mbusTrace");
			//							}
			//						} else if (strncmp(word, "serialPortOption", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							setTxt(ezMBus, &word[0], wordLength, "serialPortValue");
			//						} else if (strncmp(word, "mbusRS485", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							setTxt(ezMBus, &word[0], wordLength, "rs485");
			//						} else if (strncmp(word, "mbusConsumption", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							setTxt(ezMBus, &word[0], wordLength, "consumption");
			//							strncpy(consume, &word[0], wordLength);
			//						} else if (strncmp(word, "save", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							saveAction = true;
			//						} else if (strncmp(word, "baudrate", wordLength) == 0) {
			//							getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
			//							for (ezTemp = ezxml_child(ezBaudrates, "option"); ezTemp; ezTemp = ezTemp->next) {
			//								if (strncmp(ezTemp->txt, word, wordLength) == 0) {
			//									ezxml_set_attr(ezTemp, "enabled", "true");
			//									break;
			//								}
			//							}
			//						}
			//					}
			//				} // while

		}

	} else {
		return;
	}
}

void writeSyslogConf() {
	FILE* new_file = NULL; // new file pointer
	// open original and backup file:
	new_file = fopen(DEBIAN_SYSLOG, "w");
	if (new_file == NULL) {
		sprintf(message, "Couldn't open file '%s'. Error: %s", DEBIAN_SYSLOG, strerror(errno));
		return;
	}
	fprintf(new_file, "*.*	@%s\n", tracerip);
	fflush(new_file);
	fclose(new_file);

}
///**
// *
// */
//int addSerialPorts(ezxml_t ezRoot) {
//	ezxml_t ezSerialRoot, ezTemp, ezTemp2;
//	char * buffer;
//	char * entry;
//	int dataLength;
//	int count = 0;
//	buffer = (char *) readFile(SERIALPORTS_PATH, &dataLength);
//	if (buffer == NULL) {
//		//		klog(LOGGER_CONFIGURATION, LOG_WARNING, "No Serial Port Configuration found.");
//		return -1;
//	}
//	ezSerialRoot = ezxml_parse_str(buffer, dataLength);
//	for (ezTemp = ezxml_child(ezSerialRoot, "serialPortOption"); ezTemp; ezTemp = ezTemp->next) {
//		ezTemp2 = ezxml_add_child(ezRoot, ezTemp->name, 0);
//		ezxml_set_txt(ezTemp2, ezTemp->txt);
//		ezxml_set_attr(ezTemp2, "value", ezTemp->attr[1]);
//	}
//	ezxml_free(ezSerialRoot);
//	free(buffer);
//}

/**
 *
 *
 */
int main(int argc, char *argv[]) {
	int ind, retValue;
	char * inputParameters = NULL;
	char * xmlData;
	char * remoteUser = NULL;
	DIR *pDir;
	bool error = true;
	struct sigaction new_action;

	char configFile[128];

	char buffer[64];
	int wrfd;
	ezxml_t ezMessage;

	ezxml_t ezRoot, ezTemp, ezChild;

	new_action.sa_handler = alarm_handler;
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = 0;
	sigaction(SIGALRM, &new_action, NULL);
#ifdef DEBUG
	alarm(60); /* 20 second timeout */
#else
	alarm(15); /* 20 second timeout */
#endif

	semId = semget(KEY, 1, 0666);
	if (semId < 0) { /* Semaphore does not exist. */
		sendMessageHtml("Program sema cannot find semaphore, exiting.", true);
		exit(0);
	}

	/* Set up the sembuf structure. */
	/* Which semaphore in the semaphore array : */
	operations[0].sem_num = 0;
	/* Which operation? Add 1 to semaphore value : */
	operations[0].sem_op = -1; // reduce the semaphore count to lock

	/* Set the flag so we will wait : */
	operations[0].sem_flg = SEM_UNDO;

	/* So do the operation! */
	retValue = semop(semId, operations, 1);

	//	ezRoot = ezxml_parse_file("www/cgi/config.xml");
	strcpy(configFile, CONFIG_FILE);
	message[0] = 0;
	ezRoot = ezxml_parse_file(configFile);
	//	xmlData = ezxml_toxml(ezRoot);
	remoteUser = getenv("REMOTE_USER");
	if (ezRoot != NULL) {
		//		inputParameters
		//						= "bacConfig?deviceInstance=2270&baudrate=300&baudrate=2400&baudrate=4800&baudrate=9600&logLevel=Debug&tracerIp=192.168.2.5&mbusRS485=on&mbusTraceEnable=on";
		if (argc > 1) {
			inputParameters = argv[1];
		} else {
			inputParameters = getenv("QUERY_STRING");
		}
		ezTemp = ezxml_child(ezRoot, bacnetTypeOption);
		if (ezTemp == NULL) {
			ezTemp = ezxml_add_child(ezRoot, bacnetTypeOption, 0);
			ezxml_set_txt(ezTemp, bacnetIp);
			ezxml_set_attr(ezTemp, "value", "0");
			ezTemp = ezxml_add_child(ezRoot, bacnetTypeOption, 0);
			ezxml_set_txt(ezTemp, bacnetEthernet);
			ezxml_set_attr(ezTemp, "value", "1");
		}

		if (inputParameters != NULL) {
			parseInput(ezRoot, inputParameters);
			xmlData = ezxml_toxml(ezRoot);
			if (saveAction) {
				if (remoteUser != NULL && strcmp(remoteUser, "admin") != 0) {
					adminMessageHtml("Access denied. Sorry, only 'admin' user can change these settings.", true);
					return -1;
				}
				if (action >= '9') { // MBUS Config
					if (strcmp(consume, "on") == 0) {
						if ((pDir = opendir(CONSUME_SAVE_PATH)) == NULL) {
							adminMessageHtml("Consume Directory not available. Plugin the SD Card.", true);
							return-2;
						} else {
							closedir(pDir);
						}
					}
				}

				if (writeFile(configFile, xmlData, -1)) {
					strcpy(message, "Configuration saved. Please reboot the device.");
					error = false;
				} else {
					strcpy(message, "ERROR: Couldn't save Configuration");
				}
#ifdef ARM5
				writeSyslogConf();
#endif

			}
			free(xmlData);
		}
		if (iamAction) {
			wrfd = open(NAMED_PIPE_READ, O_WRONLY | O_NONBLOCK);
			if (wrfd < 0) {
				strcpy(message, "ERROR: MBus Server probably is not running");
			} else {
				buffer[0] = COMMAND_SEND_IAM;
				write(wrfd, buffer, 1); // send command 1
				close(wrfd);
			}
		}
		printf("Status: 200 Ok\r\nContent-type: application/xml\r\n\r\n");
		printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
		printf("<?xml-stylesheet type=\"text/xsl\" href=\"../%s\" ?>\n", page);
		ezxml_free(ezRoot);
		ezRoot = ezxml_parse_file(configFile); // bug in ezxml cannot call toxml twice

		ezTemp = ezxml_child(ezRoot, bacnetTypeOption);
		if (ezTemp == NULL) {
			ezTemp = ezxml_add_child(ezRoot, bacnetTypeOption, 0);
			ezxml_set_txt(ezTemp, bacnetIp);
			ezxml_set_attr(ezTemp, "value", "0");
			ezTemp = ezxml_add_child(ezRoot, bacnetTypeOption, 0);
			ezxml_set_txt(ezTemp, bacnetEthernet);
			ezxml_set_attr(ezTemp, "value", "1");
		}

		//		if (action >= '9') { // MBUS Config
		//			if (addSerialPorts(ezRoot) == -1) {
		//				strcpy(message, "Serial Port Configuration File not found");
		//			}
		//		}

		if (message[0] != 0) {
			setTxt(ezRoot, message, strlen(message), "message");
			if (error) {
				setTxt(ezRoot, "1", 1, "error");
			} else {
				setTxt(ezRoot, "0", 1, "error");
			}
		}

		ezChild = ezxml_parse_file(GATEWAYS_FILE);
		if (ezChild) {
			ezxml_insert(ezChild, ezRoot, 0);
		}
		xmlData = ezxml_toxml(ezRoot);

		printf("%s", xmlData);
		free(xmlData);
		ezxml_free(ezRoot);
	} else {
		adminMessageHtml("Configuration File not found", true);
	}

	//release the 0th semaphore
	operations[0].sem_num = 0; //signifies 0th semaphore
	operations[0].sem_op = 1; //reduce the semaphore count to lock
	operations[0].sem_flg = 0; //wait till we get lock on semaphore

	if (semop(semId, operations, 1) == -1) {
		perror("Thread1:semop failure Reason:");
		exit(-1);
	}

}

///**
// *
// *
// */
//int decodeOutput(ezxml_t ezRoot) {
//
//	int dataLength;
//	ezxml_t ezAddress, ezTemp, ezTemp2, ezTemp3, ezObject, ezInstance, ezProperty;
//
//	// reading log level
//	ezTemp = ezxml_child(ezRoot, "log");
//	if (ezTemp != NULL && ezTemp->txt != NULL) {
//		unsigned logLevel;
//		if (indtext_by_string(&loggingTag[0], ezTemp->txt, &logLevel) == true) {
//			printf("<logLevel>%s</logLevel>\n", ezTemp->txt);
//		} else {
//			syslog(LOG_ERR, "Wrong Log Level");
//		}
//	}
//
//	ezTemp = ezxml_child(ezRoot, "MBus");
//	if (ezTemp != NULL && ezTemp->txt != NULL) {
//		ezTemp2 = ezxml_child(ezTemp, "serialTrace");
//		if (ezTemp2 != NULL && ezTemp2->txt != NULL) {
//			printf("<mbusTracer>%s</mbusTracer>\n", ezTemp2->txt);
//		}
//		ezTemp2 = ezxml_child(ezTemp, "enabledBaudrates");
//
//		if (ezTemp2 != NULL && ezTemp2->txt != NULL) {
//			printf("<enabledBaudrates>\n");
//			for (ezTemp3 = ezxml_child(ezTemp2, "baudrate"); ezTemp3; ezTemp3 = ezTemp3->next) {
//				printf("<baudrate>%s</baudrate>\n", ezTemp3->txt);
//			}
//			printf("</enabledBaudrates>\n");
//		}
//
//	}
//	ezInstance = getDeviceInstance(ezRoot);
//	if (ezInstance != NULL && ezInstance->txt != NULL) {
//		printf("<deviceId>%s</deviceId>\n", ezInstance->txt);
//	} else {
//		syslog(LOG_WARNING, "no objects found");
//	}
//}
