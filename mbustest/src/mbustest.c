#include <stddef.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <inttypes.h>
#include "MainUtil.h"
#include "MBus.h"
#include "MbusEnum.h"

#include <sys/ioctl.h>

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

static char pSimFile[128];
static char pOutputFile[128];

int parseUD2(int recLength, MBus * pMBus);

uint8_t recBuffer[256];
int recPtr;

bool littleIndian = false;

uint8_t fileBuffer[2048];

static int bcdWeights[] = { 0x1, 100, 10000, 1000000, 100000000, 100000000 };

int bcdWeights10[] = { 0x1, 10, 100, 1000, 10000, 100000, 1000000, 10000000, 100000000 };

uint8_t getReceiveByte() {
	printf("RecRead : %03d:%02X - ", recPtr, recBuffer[recPtr]);
	return recBuffer[recPtr++];
}
/**
 *
 *
 */
static int asciiToInt(uint8_t * array, int length) {
	int value = 0;
	int i;
	for (i = 0; i < length; i++) {
		if (array[i] < 0x30 || array[i] > 0x39) {
			continue;
		}
		value = (value * 10) + (array[i] - 0x30);
	}
	return value;
}

static long arrayToLong(int length, int mode) {
	uint64_t value = 0;
	uint64_t tmp;
	uint8_t recByte;
	int i;
	if (mode != 0) { // MSB First
		for (i = 0; i < length; i++) {
			recByte = getReceiveByte();
			printf(" ArrayToLong \n");
			value = value << 8;
			value |= recByte;
		}
	} else { // LSB First
		for (i = 0; i < length; i++) {
			recByte = getReceiveByte();
			printf(" ArrayToLong \n");
			tmp = recByte & 0x00ff;
			value |= tmp << (8 * i);
		}
	}
	return value;
}

static float arrayToFloat(int mode) {
	uint32_t tmp;
	uint8_t * pTemp = (uint8_t *) &tmp;
	uint8_t recByte;

	if ((mode == 0 && littleIndian == false) || (mode != 0 && littleIndian)) {

		*pTemp++ = getReceiveByte();
		printf(" ArrayToFloat \n");
		*pTemp++ = getReceiveByte();
		printf(" ArrayToFloat \n");
		*pTemp++ = getReceiveByte();
		printf(" ArrayToFloat \n");
		*pTemp = getReceiveByte();
		printf(" ArrayToFloat \n");

//		printf ("Hex Float: %2x %2x %2x %2x, Float %f \n",
//				*tmp, *(tmp+1), *(tmp+2), *(tmp+3), *(float *) tmp);
	} else {

		pTemp[3] = getReceiveByte();
		printf(" ArrayToFloat \n");
		pTemp[2] = getReceiveByte();
		printf(" ArrayToFloat \n");
		pTemp[1] = getReceiveByte();
		printf(" ArrayToFloat \n");
		pTemp[0] = getReceiveByte();
		printf(" ArrayToFloat \n");

	}
	pTemp = (uint8_t *) &tmp;
	return *(float *) pTemp;
}

static int arrayToInt(uint8_t * array, int length, int mode) {
	uint32_t value = 0;
	uint32_t tmp;
	uint8_t recByte;
	int i;
	if (mode != 0) { // MSB First
		for (i = 0; i < length; i++) {
			recByte = getReceiveByte();
			printf(" ArrayToInt \n");
			value = value << 8;
			value |= array[i];
		}
	} else { // LSB First
		for (i = 0; i < length; i++) {
			recByte = getReceiveByte();
			printf(" ArrayToInt \n");
			tmp = array[i] & 0x00ff;
			value |= tmp << (8 * i);
		}
	}
	return value;
}

/**
 *
 */
static int bcdToInt(int length, int mode) {
	int value = 0;
	int i;
	uint8_t recByte;
	if (mode &= 0) { // MSB First
		for (i = 0; i < length; i++) {
			value = value * bcdWeights[i];
			recByte = getReceiveByte();
			printf(" BCD Data \n");
			value += ((recByte >> 4) * 10) + (recByte & 0x0f);
		}
	} else { // LSB First
		for (i = 0; i < length; i++) {
			//			tmp1 = (array[i] >> 4) * 10;
			//			tmp2 = (array[i] & 0x0f);
			//			tmp1 += tmp2;
			//			tmp1 = tmp1 * bdcWeights[i];
			recByte = getReceiveByte();
			printf(" BCD Data \n");
			value += (((recByte >> 4) * 10) + (recByte & 0x0f)) * bcdWeights[i];
		}
	}
	return value;
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

	buffer = (uint8_t *) malloc((sizeof(char) * lSize) + 1); // for zero
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
	buffer[lSize] = 0x0;
	fclose(pFile);
	//	free(buffer);
	return buffer;
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
/*
 *
 */
int main(int argc, char *argv[]) {
	char * pChar;
	char *pText;
	printf("Revision 93\n");

	if (argc < 1) {
		return -1;

	}
	strcpy(pSimFile, argv[1]);

	int dataLength;
	int error;
	pText = (char *) readFile(pSimFile, &dataLength);

	dataLength = dataToBinary(pText, recBuffer);
	recPtr = 0;
	error = parseUD2(dataLength, NULL);

	return 0;
}

/**
 *
 *  Parsing Response Class 2 Data
 *
 */
int parseUD2(int recLength, MBus * pMBus) {
	//	ObjectProperties * objectProperties;
	int pointer;
	uint8_t * receive = &recBuffer[0];
	uint8_t * receiveTmp;
	int length, recordNumber;
	uint8_t checkSum = 0;
	uint8_t controlField;
	uint8_t ciField, modeMSBF, dif, vif, function;
	uint8_t vifPrimary, vifPrimaryExt;
	uint8_t vifType, dife;
	int difCount, lvar;
	float readingValue;
	int readingValueInt;
	long readingValueLong;
	int tmp, retValue;
	MBusRecord * pMBusRecord;
	char * plainText;
	int plainTextLength;
	uint8_t recByte;

	uint8_t * recordLog;
	//	char * pChar;

	int storageNo, subunitNumber, tarif;

	bool firstRecord;
	uint32_t identificationNo;

	//	char meterName[12];
	if (recLength < 9) { // at least 9 bytes
		printf("Data is less then 9 bytes");
		return 1;
	}

	if (getReceiveByte() != 0x68) { // Start Character
		printf("First Character muss be 68");
		return 2;
	}
	printf(" Start Character \n");
	length = getReceiveByte();
	printf(" Length %d \n", length);
	if (length != getReceiveByte()) {
		printf("Lenght must be tice and zthe same");
		return 3; // length is wrong
	}
	printf(" Length %d \n", length);
	if (getReceiveByte() != 0x68) { // second  Start Character
		printf("Second start byte must be 68");
		return METER_STATUS_WRONG_START_CHARACTER;
	}
	printf(" second start field\n");
	// Check Length
	if (length != recLength - 6) {
		//		length = recLength-6;
		return METER_STATUS_WRONG_LENGTH; // wrong length
	}
	// check Checksum first
	receiveTmp = &receive[recPtr];
	tmp = length;
	while (tmp > 0) {
		checkSum += *receiveTmp++;
		tmp--;
	}
	if (checkSum != *receiveTmp) {
		printf("WRONG CHECKSUM");
		return METER_STATUS_WRONG_CHECKSUM; // wrong checksum
	}
	retValue = METER_STATUS_ACTIVE;
	controlField = getReceiveByte();
	printf(" - controlField \n");
	if (controlField != 0x8) { // must be RSP_UD
		retValue = METER_STATUS_WRONG_COMMAND;
		goto PARSE_ERROR;
	}
	//	objectProperties = getObject(pSerialPort);
	getReceiveByte(); // skip address field for the moment
	ciField = getReceiveByte();
	printf(" - CiField \n");
	modeMSBF = ciField & 0x04;
	switch (ciField) {
	case 0x70: // report of general application errors
		break;
	case 0x71: // report of Alarm Status
		break;
	case 0x72: // Variable data Respond
	case 0x74:
		length -= (12 + 3);
		if (length < 0) {
			retValue = METER_STATUS_WRONG_LENGTH;
			goto PARSE_ERROR;
		}
//		pthread_mutex_lock(&meterListMutex);
//		identificationNo = bcdToInt(receive, 4, modeMSBF);
//		if (pMBus == NULL) { // new Meter
//			pMBus = getMeter(pSerialPort->serialAddress, identificationNo, false);
//			if (pMBus == NULL) {
//				pMBus = addMeter(pSerialPort->serialAddress, identificationNo, false);
//				if (pMBus != NULL) {
//					pMBus->address = pSerialPort->serialAddress;
//					newMeters++;
//				} else {
//					pthread_mutex_unlock(&meterListMutex);
//					return METER_STATUS_LICENSE_LIMIT;
//				}
//			}
//		}

		//		objectProperties = pMBus->bacNetObject;
		// the fixed Header
//		pMBus->baudrateIndex = pSerialPort->baudrateIndex;
//		pMBus->identificationNo = bcdToInt(receive, 4, modeMSBF);
//		pMBus->identificationNoBCD[0] = *receive;
//		pMBus->identificationNoBCD[1] = *(receive + 1);
//		pMBus->identificationNoBCD[2] = *(receive + 2);
//		pMBus->identificationNoBCD[3] = *(receive + 3);
//
//		receive += 4; // for the identicators
//		pMBus->manufacture = arrayToInt(receive, 2, modeMSBF);
		getReceiveByte();
		printf("identificationNoBCD \n");

		getReceiveByte();
		printf("identificationNoBCD \n");

		getReceiveByte();
		printf("identificationNoBCD \n");

		getReceiveByte();
		printf("identificationNoBCD \n");

		getReceiveByte();
		printf("Manufacture 0 \n");

		getReceiveByte();
		printf("Manufacture 1 \n");

//		if (debug) {
//			printf ("Manufacture %d: %2x %2x\n", (receive - &recBuffer[0]), *receive, *(receive+1));
//		}
		//		objectProperties->mbus->manufacture[2] = (tmp & 0x1f) + 0x40;
		//		objectProperties->mbus->manufacture[1] = ((tmp >> 5) & 0x1f) + 0x40;
		//		objectProperties->mbus->manufacture[0] = ((tmp >> 10) & 0x1f) + 0x40;

		getReceiveByte();
		printf("Version  \n");

		getReceiveByte();
		printf("Medium  \n");

		getReceiveByte();
		printf("Access Number  \n");

		getReceiveByte();
		printf("Status  \n");

		getReceiveByte();
		printf("Signature  \n");

		getReceiveByte();
		printf("Signature  \n");

		firstRecord = false;
		recordNumber = 0;
		while (recPtr < recLength) {
			//
			//  A varaible Block of DATA
			//

			storageNo = 0;
			subunitNumber = 0;
			tarif = 0;
			vifPrimary = 0;
			vifPrimaryExt = 0;
			plainText = NULL;
			recordLog = receive;
#if PRINT_ENABLE
			printf ("Record No %d at %d: DIF %x\n", recordNumber, (receive - &recBuffer[0]), *receive);
#endif
			dif = getReceiveByte();
			printf("DIF Rec No %d\n", recordNumber);

			length--;
			//			printf("DIF: %X \n", dif);
			if ((dif & 0x40) == 0x40) { //  storage lsb
				storageNo = 1;
			}
			if ((dif & 0x80) == 0x80) { // Exteneded
				difCount = 0;
				do {
					dife = getReceiveByte();
					printf("DIFE Rec No %d\n", recordNumber);

					subunitNumber |= ((dife & 0x40) >> 6) << difCount;
					storageNo |= (dife & 0x0F) << ((difCount * 4) + 1);
					tarif |= ((dife & 0x30) >> 4) << difCount;
					difCount++;
				} while ((dife & 0x80) == 0x80);
				length -= (difCount);
			}
			function = (dif >> 4) & 0x3;
			if (dif == 0x0f || dif == 0x1f) { //  ignore manufacture data
				printf("Manfacture RECORD Rec No %d\n", recordNumber);
				readingValue = 0;
				readingValueInt = 0;

				while (length > 0) {
					recByte = getReceiveByte();
					printf("Manu Data \n");

				}
				vifType = VIF_MANUFACTURE;
			} else {
				// READ the ValueInformationBlock
				plainText = NULL;
				vif = getReceiveByte();
				printf("VIF Rec No %d\n", recordNumber);

				length--;

				vifType = VIF_IGNORE; // unknown

				if (vif == 0xFB) {
					vifType = VIF_EXT_FB;
					vif = getReceiveByte();
					printf("VIF Rec No %d\n", recordNumber);
					vifPrimary = vif;
					length--;
				} else if (vif == 0xFD) {
					vifType = VIF_EXT_FD;
					vifPrimary = getReceiveByte();
					printf("vifPrimary Rec No %d\n", recordNumber);
					vif = vifPrimary;
					length--;
				} else if (vif == 0x7C || vif == 0xFC) { // ascii value
					vifType = VIF_PLAIN_TEXT;
					plainTextLength = getReceiveByte(); // save plain text text marker
					printf("plainTextLength Rec No %d\n", recordNumber);
					plainText = (char *) receive;
					recPtr += plainTextLength;
					length -= (plainTextLength + 1);
					vif = 0;
					//				receive += tmp;
				} else if (vif < 0x7b) {
					vifType = VIF_PRIMARY;
					vifPrimary = vif;
				} else if (vif < 0xfb) {
					vifType = VIF_PRIMARY_EXT;
					vifPrimary = vif & 0x7F;
					vifPrimaryExt = getReceiveByte();
					printf("vifPrimaryExt Rec No %d\n", recordNumber);
					vif = vifPrimaryExt;
					length--;
				}

				while ((vif & 0x80) == 0x80) {
					vif = getReceiveByte(); // ignore all othre VIFs
					printf("VIF Rec No %d\n", recordNumber);
					length--;
				}

				// READ the Data
				int dataFieldLength = dif & 0x0f;
				switch (dataFieldLength) {
				case 0: // no data
				case 8: // Selection for Readout What's that?
					break;
				case 1: // 8bit int
				case 2: // 16 bit int
				case 3: //  24 bit int
				case 4: //  32 bit int
					readingValueInt = arrayToInt(receive, dataFieldLength, modeMSBF);
					readingValue = (float) readingValueInt;
					length -= dataFieldLength;
					break;
				case 5: // Float
					readingValue = arrayToFloat(modeMSBF);
					length -= 4;
					break;
				case 6: // 48 bit
					readingValueLong = arrayToLong(6, modeMSBF);
					readingValue = (float) readingValueLong;
					length -= 6;
					break;
				case 7: // 64 bit integer  read only the first 4 bytes
					readingValueLong = arrayToLong(8, modeMSBF);
					readingValue = (float) readingValueLong;
					length -= 8;
					break;
				case 9: // 2 bcd
					readingValueInt = bcdToInt(1, modeMSBF);
					printf("BCD 2 to Int: %d", readingValueInt);
					readingValue = (float) readingValueInt;
					length -= 1;
					break;
				case 10: // 4 bcd
					readingValueInt = bcdToInt(2, modeMSBF);
					printf("BCD 4 to Int: %d", readingValueInt);
					readingValue = (float) readingValueInt;
					length -= 2;
					break;
				case 11: // 6 bcd
					readingValueInt = bcdToInt(3, modeMSBF);
					printf("BCD 6 to Int: %d", readingValueInt);
					readingValue = (float) readingValueInt;
					length -= 3;
					break;
				case 12: // 8 bcd
					readingValueInt = bcdToInt(4, modeMSBF);
					printf("BCD 8 to Int: %d", readingValueInt);
					readingValue = (float) readingValueInt;
					//					recPtr += dataFieldLength - 8;
					length -= 4;
					break;
				case 14: // 12 bcd
					readingValueInt = bcdToInt(6, modeMSBF);
					printf("BCD 12 to Int: %d", readingValueInt);
					readingValue = (float) readingValueInt;
					length -= 6;
					break;
				case 13: // Varaible
					lvar = getReceiveByte();
					printf("Variable Length %d,  Rec No %d\n", lvar, recordNumber);
					length--;
					if (lvar < 0xBF) { // ascii to int
						int i;
						for (i = 0; i < lvar; i++) {
							recByte = getReceiveByte();
							printf("ASCII %c\n", recByte);

						}
					} else if (lvar < 0xCF) { // BCD
						lvar -= 0xC0;
						readingValue = (float) bcdToInt(lvar, modeMSBF);
					} else if (lvar < 0xDF) { // negative BCD
						lvar -= 0xD0;
						readingValue = 0 - (float) bcdToInt(lvar, modeMSBF);
					} else if (lvar < 0xEF) { // binary
						lvar -= 0xE0;
						readingValue = (float) arrayToInt(receive, lvar, modeMSBF);
					} else {
						lvar -= 0xF0;
						readingValue = (float) arrayToInt(receive, lvar, modeMSBF);
					}
					receive += lvar;
					length -= lvar;
					break;
				case 15: // Special Funtions
					length = 0; // ignore rest of DATA
					readingValue = 0;
					break;
				}
			}

//			pMBusRecord = arraylist_get(pMBus->mbusRecords, recordNumber);
//			if (pMBusRecord == NULL) {
//				pMBusRecord = allocZero(sizeof(MBusRecord)); // create Record
//				pMBusRecord->bacnetInstance = -1;
//				pMBusRecord->unit = -1;
//				pMBusRecord->parent = pMBus;
//				arraylist_add(pMBus->mbusRecords, pMBusRecord);
//			}
//			pMBusRecord->function = function;
//			pMBusRecord->tariff = tarif;
//			pMBusRecord->subunitNumber = subunitNumber;
//			pMBusRecord->storageNo = storageNo;
//			pMBusRecord->value = readingValue;
//			pMBusRecord->valueInt = readingValueInt;
//			pMBusRecord->viftype = vifType;
//			pMBusRecord->vifPrimary = vifPrimary;
//			pMBusRecord->vifPrimaryExt = vifPrimaryExt;
//			if ((plainText != NULL) && (pMBusRecord->plainText == NULL)) {
//				pMBusRecord->plainText = malloc(plainTextLength+1); // copy the plain text only once
//				strncpy(pMBusRecord->plainText, plainText, plainTextLength);
//				pMBusRecord->plainText[plainTextLength] = 0;
//			}
//			pMBusRecord->function = function;
//
//			//		printf ("MBUS Record Value %s  = %f\n", pMBus->name, pMBusRecord->value);
//
//			if ((function == 0) && (subunitNumber == 0) && (storageNo == 0) && (pMBus->recordNo == -1)) {
//				pMBus->recordNo = recordNumber;
//				addRecordBacnet(pMBus, pMBusRecord);
//			}
//			pMBus->meterState = METER_STATUS_ACTIVE;
//			if (pMBusRecord->bacnetInstance != -1) {
//				updateMBusBacnetValue(pMBusRecord);
//			}
			recordNumber++;
		} //  while (length > 0) { next variable block
		break;
	case 0x73: // Fixed data Respond
	case 0x77:

//		retValue = decodeFixedData(receive, length - 3, modeMSBF, &pMBus);
		break;

	default:
		retValue = METER_STATUS_WRONG_COMMAND; // invalid command
	}

	PARSE_ERROR: if (retValue == 0) {
		//		BIT_CLEAR(objectProperties->statusFlags, STATUS_FLAG_FAULT);

	} else {
//		if (pMBus != NULL) {
//			pMBus->meterState = retValue;
//			for (recordNumber = 0; recordNumber < arraylist_size(pMBus->mbusRecords); recordNumber++) {
//				pMBusRecord = arraylist_get(pMBus->mbusRecords, recordNumber);
//				if (pMBusRecord->bacnetInstance != -1) {
//					updateMBusBacnetValue(pMBusRecord);
//				}
//			}
//		}
		//		BIT_SET(objectProperties->statusFlags, STATUS_FLAG_FAULT);
	}
	return 0;
}

