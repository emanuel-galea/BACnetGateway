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
#include <errno.h>
#include <dirent.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>

#include "Parser.h"
#include "HtmlParser.h"

#define TEMP_ZIP_FILE_INCL "/tmp/firmware.enc.tmp"
#ifdef ARM5
#define TEMP_ZIP_FILE "/tmp/firmware.tar"
#define TEMP_OUTPUT_FILE " /tmp/output.txt"
#define INSTALL_COMMAND "tar -xPf /tmp/firmware.tar > /tmp/output.txt"
#define CONSOLE_OUTPUT "/tmp/output.txt"
#endif

#ifdef  LINUX_X86
#define TEMP_ZIP_FILE "/tmp/firmware.enc"
#define TEMP_OUTPUT_FILE "/tmp/output.txt"
#define INSTALL_COMMAND "tar -xPf  /tmp/firmware.tar >  /tmp/output.txt"
#define CONSOLE_OUTPUT "/home/emanuel/tmp/output.txt"
#endif


#define CONTENT_DISPOSITION "Content-Disposition:"
#define CONTENT_TYPE "Content-Type:"
#define PASSWORD "KaraSystems1"

#define NAMED_PIPE_READ		"/tmp/kara_pipe_read"
#define NAMED_PIPE_WRITE		"/tmp/kara_pipe_write"
#define MAX_BUF_SIZE 8096

#define CMD_UPLOAD_FILE 1
#define CMD_UPLOAD_IMAGE  2
#define CMD_GET_LOGS  3
#define CMD_SCAN_FILE  4
#define CMD_DOWNLOAD_LOG 5
#define CMD_ADMIN_LIST 6
#define CMD_RESET_CONFIG 7

#define IMAGES_DIR "hmi/images/"
#define IMAGE_LIST_FILE "hmi/imageList.xml"
#define VIEWS_DIR "hmi/views/"
#define HMI_DIR "hmi/ "

char buffer[MAX_BUF_SIZE + 1];
static const char NAME_TEXT[] = { "name=\"" };
static const char FILENAME_TEXT[] = { "filename=\"" };
static char nameProperty[64];
static char fileName[128];
static char boundary[128];
char tempBuffer[256];
char * documentRoot;

extern char * loggers[];
extern INDTEXT_DATA indLogLevels[];

HtmlVariable * htmlVariables;

static void sendMessageReboot(const char * message) {
	char errorMessage[16];
	char page[512];
	int status = 200;
	strcpy(errorMessage, "false");
	printf("Status: %d Ok\r\nContent-type: application/xml\r\n\r\n", status);
	sprintf(page, "<root>\n<message>%s</message>\n<error>%s</error>\n</root>", message, errorMessage);
	printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n");
	printf("<?xml-stylesheet type=\"text/xsl\" href=\"/messageReboot.xsl\" encoding=\"ISO-8859-1\" ?>\n%s", page);
}

/**
 *   Paste the variable name to "name" and the variable content to
 *
 */bool parseName(char * buffer) {
	char * charIndex;
	char * charIndex2;
	charIndex = strstr(buffer, NAME_TEXT);
	if (charIndex == NULL) {
		return false;
	}
	charIndex += (sizeof(NAME_TEXT) - 1);
	charIndex2 = strstr(charIndex, "\"");
	if (charIndex == NULL) {
		return false;
	}
	*charIndex2++ = 0;
	strcpy(nameProperty, charIndex);
	charIndex = strstr(charIndex2, FILENAME_TEXT);
	if (charIndex == NULL) {
		fileName[0] = 0;
		return true;
	}
	charIndex += sizeof(FILENAME_TEXT) - 1;
	charIndex2 = strstr(charIndex, "\"");
	*charIndex2 = 0;
	strcpy(fileName, charIndex);
	return true;
}

const char *indtext(INDTEXT_DATA * data_list, unsigned index) {
	const char *pString = NULL;

	if (data_list) {
		while (data_list->pString) {
			if (data_list->index == index) {
				pString = data_list->pString;
				break;
			}
			data_list++;
		}
	}

	return pString ? pString : " ";
}

void adminList(int error, char * message) {
	char deviceType [32];
	printf("Status: 200 Ok\r\nContent-type: application/xml\r\n\r\n");
	printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n");
	printf("<?xml-stylesheet type=\"text/xsl\" href=\"../%s\" encoding=\"ISO-8859-1\" ?>\n", "admin.xsl");
	printf("<root><gateways><mbus>1</mbus><modbus>1</modbus></gateways>");
	if (error >= 0) {
		printf("<error>%d</error><message>%s</message>", error, message);
	}
	printf("</root>");

}

/**
 *
 */
void printScanFile() {
	int totalRecords = 0;
	int ret;
	time_t time;
	int level;
	int logger;
	FILE* pStdout = stdout;
	FILE* pFile = fopen(SCAN_FILE, "r");

	printf("Status: 200 Ok\r\nContent-type: text/html\r\n\r\n");
	fprintf(pStdout, "<html><body><pre>");
	char ch;
	if (pFile != NULL) {
		while ((ch = fgetc(pFile)) != EOF) {
			fputc(ch, pStdout);
		}
	}
	fprintf(pStdout, "</pre></body></html>");
	if (pFile != NULL) {
		fclose(pFile);
	}
	return;
}

/**
 *
 */
int printLogFile(FILE * pFile) {
	int totalRecords = 0;
	int ret;
	time_t time;
	int level;
	int logger;
	FILE* pStdout = stdout;
	while (true) {
		//		ret = fscanf (pFile, "%d", &time);
		//		ret = fscanf (pFile, "%d,", level);
		ret = fscanf(pFile, "%ld,%d,%d,%[^\n]\n", &time, &level, &logger, buffer);
		if (ret == EOF) {
			break;
		}
		printf("<log><time>%s</time>", ctime(&time));
		writeXmlChar(pStdout, "level", indtext(indLogLevels, level));
		writeXmlChar(pStdout, "logger", loggers[logger]);
		writeXmlChar(pStdout, "message", buffer);
		fprintf(pStdout, "</log>\n");
		totalRecords++;
	}
	return totalRecords;
}

void downloadLogs() {
	FILE * pFile;
	printf("Status: 200 Ok\r\nContent-type: application/xml\r\n");
	printf("Content-disposition: attachement; filename=\"gatewaylog.xml\"\r\n\r\n");
	printf("<root>\n");
	pFile = fopen(LOG_FILE, "r");
	if (pFile != NULL) {
		printLogFile(pFile);
		fclose(pFile);
	}
	pFile = fopen(LOG_FILE2, "r");
	if (pFile != NULL) {
		printLogFile(pFile);
		fclose(pFile);
	}
	printf("</root>\n");

}

/*
 *
 */
void printLogs() {

	int ret;
	char * message;
	int totalRecords = 0;
	FILE * pFile;
	FILE* pStdout = stdout;

	printf("Status: 200 Ok\r\nContent-type: application/xml\r\n\r\n");
	printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n");
	printf("<?xml-stylesheet type=\"text/xsl\" href=\"../%s\" encoding=\"ISO-8859-1\" ?>\n", "logging.xsl");
	printf("<logs>");
	pFile = fopen(LOG_FILE, "r");
	if (pFile != NULL) {
		totalRecords = printLogFile(pFile);
		fclose(pFile);
	}
	pFile = fopen(LOG_FILE2, "r");
	if (pFile != NULL) {
		totalRecords += printLogFile(pFile);
		fclose(pFile);
	}
	writeXmlInt(pStdout, "totalLogs", totalRecords);
	fprintf(pStdout, "</logs>\n");
	return;
}

/**
 *
 */
void responseBuffer(char * page, char * buffer) {
	int rdfd, numread;
	printf("Status: 200 Ok\r\n");
	printf("Content-type: application/xml\r\n");
	printf("\r\n");

	printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
	printf("<?xml-stylesheet type=\"text/xsl\" href=\"../%s\" ?>\n", page);
	printf(buffer);
	return;
}
/**
 *
 */
int sysCommand(char * command, char * message) {
	FILE * pFile;
	uint8_t * pFileContents;
	char * consoleOutput;
	int retValue, length;
	retValue = system(command);
	if (retValue != 0) {
		pFileContents = readFile(CONSOLE_OUTPUT, &length);
		if (pFileContents == NULL) {
			consoleOutput = &buffer[0];
			strcpy(consoleOutput, "No console available");
		} else {
			consoleOutput = pFileContents;
		}
		sprintf(message, "Command Failed,  Return code %d-%s<p />  %s; Command: %s", errno, strerror(errno), consoleOutput, command);
		if (pFileContents != NULL) {
			free(pFileContents);
		}
		return retValue;
	}
	sprintf(message, "OK");
	return retValue;
}
/**
 *
 */
void saveAll(FILE * inputStream) {
	int readLength;
	FILE * pFile = fopen("/tmp/uploadtrace.txt", "w");
	while (true) {
		readLength = fread(buffer, 1, MAX_BUF_SIZE, inputStream);
		if (readLength < 1) {
			break;
		}
		fwrite(&buffer[0], 1, readLength, pFile); // no match  write previos part
	}
	fclose(pFile);
}
/*
 *
 */
//int sysCommand(char * command, char * message) {
//	FILE * pFile;
//	int retValue, length;
//	pFile = popen(command, "r");
//	if (pFile == NULL) {
//		strcpy(message, "Command  failed");
//		return -1;
//	}
//	length = 0;
//	buffer[0] = 0x0;
//	while (length < MAX_BUF_SIZE) {
//		retValue = fread(&buffer[length], 1, MAX_BUF_SIZE - length, pFile);
//		if (retValue < 1) {
//			break;
//		}
//		length += retValue;
//	}
//	retValue = pclose(pFile);
//	if (retValue != 0 && retValue != 256) {
//		sprintf(message, "Update Failed,  Return code %d<p />  %s  <p /> %s ", retValue, command, buffer);
//		return retValue;
//	}
//	sprintf(message, "OK, %s ", buffer);
//	return 0;
//}
/**
 *
 */
static int cmpBoundary(char * buffer, int length, int boundaryLength, bool * match) {
	int ind;
	int boundIndex = 0;
	for (ind = 0; ind < length; ind++) {
		if (buffer[ind] == boundary[boundIndex++]) {
			if (boundIndex == boundaryLength) {
				*match = true; // complete match
				return ind - boundaryLength;
			}
			continue;
		}
		boundIndex = 0;
	}
	return boundIndex;
}

/*
 *  Now Install
 *
 */
int installSoftware(char * message) {
	int retValue;
	message[0] = 0x0;
	chdir("/");
	retValue = sysCommand(INSTALL_COMMAND, message);
	if (retValue == 0) {
		strcpy(message, " Update Succesful. BACnet server stopped. Now you can reboot the device");
	}
	return retValue;
}

/**
 *
 * STOPING  the bacserv
 *
 */
void stopBacserv(char * message, char user) {
	int length;
	int retValue;
	int rdfd;
	int wrfd = open(NAMED_PIPE_READ, O_WRONLY | O_NONBLOCK);
	if (wrfd > 0) {
		message[0] = (char) user;
		length = sprintf(&message[1], "%s", "gate=main?action=1");
		retValue = write(wrfd, &message[0], length + 1);
		close(wrfd);
		rdfd = open(NAMED_PIPE_WRITE, O_RDONLY);
		if (rdfd < 1) {
			sprintf(message, "Service already stoped");
		} else {
			while (true) {
				length = read(rdfd, buffer, MAX_BUF_SIZE);
				if (length > 0) {
					buffer[length] = 0;
					//				printf(buffer);
				} else {
					break;
				}
			}
			close(rdfd);
		}
		sleep(2); // wait till the process ends;
	}
}

int resetConfig(char * message) {
	int length;
	message[0] = 0x0;
	sprintf(tempBuffer, "rm -r %s*.xml", OBJECTS_SAVE_PATH);
	int retValue = sysCommand(tempBuffer, message);
	if (retValue != 0 && (errno != 2)) {
		printf("Status: 400 Ok\r\n\r\n");
		printf("%d:",retValue);
		printf(message);
		return retValue;
	}

	sprintf(tempBuffer, "rm -r %s*.bac", OBJECTS_SAVE_PATH);
		retValue = sysCommand(tempBuffer, message);
		if (retValue != 0 && (errno != 2)) {
			printf("Status: 400 Ok\r\n\r\n");
			printf(message);
			return retValue;
		}

//	sprintf(tempBuffer, "mkdir %s", OBJECTS_SAVE_PATH);
//		retValue = sysCommand(tempBuffer, message);
//		if (retValue != 0) {
//			printf("Status: 400 Ok\r\n\r\n");
//			printf(message);
//			return retValue;
//		}

	sprintf(tempBuffer, "cp -r %s*.xml %s", OBJECTS_ORG_SAVE_PATH, OBJECTS_SAVE_PATH);
	length = strlen(tempBuffer);
	tempBuffer[(length-1)] = 0x0;  // remove the slash

	retValue = sysCommand(tempBuffer, message);
	if (retValue != 0) {
		printf("Status: 400 Ok\r\n\r\n");
		printf(message);
		return retValue;
	}
	adminList(0, "Configuraiton Resetted");
}
/**
 *
 */
int uploadFile(int inputLength, FILE * inputStream, char * message) {
	FILE * pFile;
	char path[128];
	int length = strlen(documentRoot);
	int readLength;
	strcpy(path, documentRoot);
	strcat(&path[length++], "/");
//	strcat(&path[length], VIEWS_DIR);
	strcat(&path[length], htmlVariables[VAR_NAME].charString);
	strcpy(message, path);
	pFile = fopen(path, "w");
	if (pFile == NULL) {
		sprintf(message, "Upload File '%s' Failed cause: %s", path, strerror(errno));
		return errno;
	}
	while (inputLength > 0) {
		if (inputLength < MAX_BUF_SIZE) {
			readLength = inputLength;
		} else {
			readLength = MAX_BUF_SIZE;
		}
		readLength = fread(buffer, 1, readLength, inputStream);
		fwrite(buffer, 1, readLength, pFile);
		inputLength -= readLength;
	}
	fclose(pFile);
	message[0] = 0;
	return 0;
}

/**
 *
 *
 */
int main(int argc, char *argv[]) {

	int ind, retValue, wrfd, rdfd, zipfd, readLength, user, boundaryLength;
	long length;
	int numread;
	bool updateSoftware = false;
	char * remoteUser = NULL;
	char * inputParameters = NULL;
	char * xmlData;
	char * temp;
	FILE * pFile;
	FILE * inputStream;
	bool error, refresh;
	bool zipped;
	char message[128];
	char tempBuffer[128];
	error = true;
	htmlVariables = getHtmlVariables();

	documentRoot = getenv("DOCUMENT_ROOT");
	if (documentRoot == NULL) {
		documentRoot = WWW_PATH;
	}
	remoteUser = getenv("REMOTE_USER");
	if (argc > 1) {
		remoteUser = argv[1];
	}
	if (remoteUser != NULL && strcmp(remoteUser, "admin") != 0) {
		sendAccesDenied();
		return 2;
	}
	user = parseRemoteUser(remoteUser);

//	inputParameters = "action=4";
	inputParameters = getenv("QUERY_STRING");
	if (argc > 2) {
		inputParameters = argv[2];
	}

	temp = getenv("CONTENT_LENGTH");
	length = 0;
	if (temp != NULL) {
		length = atol(temp); // messageLength
	}

	if (argc > 3) {
		inputStream = fopen(argv[3], "r");
		// obtain file size:
		fseek(inputStream, 0, SEEK_END);
		length = ftell(inputStream);
		rewind(inputStream);
	} else {
		inputStream = stdin;
	}

//		saveAll(inputStream);
//		strcpy(message, "save as origin");
//		goto ERROR1;

	message[0] = 0x0;
	htmlVariables[VAR_ACTION].initializedCount = 0x0;
	if (inputParameters != NULL) {
		htmlVariables = initHtmlVariables();
		parseHtmlInput(inputParameters, strlen(inputParameters));

	}
//		printf(stdout, inputParameters);
	if (htmlVariables[VAR_ACTION].initializedCount > 0) {
		switch (htmlVariables[VAR_ACTION].signedInt) {
		case CMD_UPLOAD_FILE:
			retValue = uploadFile(length, inputStream, &message[0]);
			break;
		case CMD_UPLOAD_IMAGE:
			break;
		case CMD_GET_LOGS:
			printLogs();
			return 0;
		case CMD_SCAN_FILE:
			printScanFile();
			return 0;
		case CMD_DOWNLOAD_LOG:
			downloadLogs();
			return 0;
		case CMD_ADMIN_LIST:
			adminList(-1, "");
			return 0;
		case CMD_RESET_CONFIG:
			retValue = resetConfig(message);
			return 0;
		}
		if (retValue == 0) {
			printf("Status: 200 Ok\r\n\r\n");
		} else {
			printf("Status: 400 Ok\r\n\r\n");
		}
		printf(message);
		return 0;
	}

	if (length > 0) {
		fgets(boundary, 128, inputStream);
		sprintf(message, "Length = %d, Boundary : %s\n", length, boundary);
		boundaryLength = strlen(boundary);
		length -= boundaryLength; // lenght is now file length
		while (length > 0) { // read till empty line comes
			fgets(buffer, MAX_BUF_SIZE, inputStream); // read the Content disposition
			length -= strlen(buffer);
			if (strstr(&buffer[0], "Content-Disposition:") != (char *) NULL) {
				parseName(buffer);
				continue;
			} else if (strstr(&buffer[0], CONTENT_TYPE) != NULL) {
				continue;
			} else if (strcmp(buffer, "\r\n") == 0) {
				break;
			} else {
				strcpy(message, "Uknown HTML Message");
				goto ERROR1;
			}
		}
		if (strcmp(nameProperty, "config") == 0) {
			strcpy(tempBuffer, "/tmp/config.xml");
		} else if (strcmp(nameProperty, "filename") == 0) {
			strcpy(tempBuffer, TEMP_ZIP_FILE);
			updateSoftware = true;
		} else {
			error = true;
			strcpy(message, "Uknown Input Name");
			goto ERROR1;
		}

		length -= boundaryLength; // lenght is now file length
		length -= 4; // for /r/n
		pFile = fopen(tempBuffer, "w");
		if (pFile == NULL) {
			strcpy(message, "Cannot write Temp file");
			goto ERROR1;

		}
		int tmp;
		int boundIndex = 0;
		bool match = false;
		int newBoundIndex;

		while (length > 0) {
			if (length < MAX_BUF_SIZE) {
				readLength = length;
			} else {
				readLength = MAX_BUF_SIZE;
			}
			readLength = fread(buffer, 1, readLength, inputStream);
			if (readLength < 1) {
				break;
			}
			// Check for Boundary
			if (boundIndex != 0) { // first part was found
				tmp = boundaryLength - boundIndex;
				newBoundIndex = boundIndex;
				for (ind = 0; ind < tmp; ind++) {
					if (buffer[ind] != boundary[newBoundIndex++]) {
						tmp = fwrite(&boundary[0], 1, boundIndex, pFile); // no match  write previos part
						break;
					} else {
						boundIndex++;
					}
				}
				if (ind >= tmp) {
					match = true; // ready complete match
				}
			}
			if (match == false) {
				boundIndex = cmpBoundary(buffer, readLength, boundaryLength, &match);
				if (match) { //  complete Match
					fwrite(&buffer[0], 1, boundIndex - 1, pFile);
					break;
				}
				if (boundIndex != 0) { // frist part of boundary
					tmp = fwrite(&buffer[0], 1, (readLength - boundIndex), pFile);
				} else {
					//				fputs(buffer, pFile);
					tmp = fwrite(&buffer[0], 1, readLength, pFile);
				}
				length -= readLength;
			} else {
				break;
			}
		}
		fclose(pFile);
		error = false;
	} else {
		responseBuffer("update.xsl", "<root>");
		printGateways(stdout);
		printf("</root>");
		return;
	}

	if (updateSoftware) {
		stopBacserv(&message[0], user);
		retValue = installSoftware(&message[0]);
		if (retValue == 0) {
			sendMessageReboot(message);
			return 0;
		} else {
			error = true;
		}
	} else {
		if (zipped) {
			sprintf(tempBuffer, "unzip /tmp/images.zip -d %s/%s", documentRoot, htmlVariables[VAR_ADDRESS].charString);
			retValue = sysCommand(tempBuffer, &message[0]);
			if (retValue == 0) {
				error = false;
			} else {
				error = true;
			}
		}
		if (error) {
			refresh = false;
		} else {
			strcpy(message, "Images uploaded succesful");
			refresh = true;

		}
		responseBuffer("hmiw/editImage.xsl", "<root>");
		writeXmlChar(stdout, "message", message);
		writeXmlBool(stdout, "error", error);
		writeXmlBool(stdout, "refresh", refresh);
		printf("</root>");
		return 0;
	}

	ERROR1: sendMessage(message, error);
	return 3;
//	}

}

