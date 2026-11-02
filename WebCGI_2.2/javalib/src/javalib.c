/*
 * bacConfig.cpp
 *
 *  Created on: Sep 28, 2009
 *      Author: emanuel
 */
#include "ezxml.h"
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <syslog.h>
#include <string.h>
#include <sys/sem.h>
#include <sys/ipc.h>
#include <netinet/in.h>
#include "Configuration.h"
#include <errno.h>
#include <dirent.h>
#include "Parser.h"
#include "HtmlParser.h"

#define CMD_SVG_EDITOR_JNLP 1
#define CMD_GET_JAR 2
#define BUFFER_SIZE 2048

char action;

char argument[] = {
		"argument" };
bool saveAction;

char message[128];

bool error;
char * documentRoot;
/**
 *
 */
//bool getJnlp() {
//	char * contents;
//	int length;
//	char * codebaseIndex;
//	char * argumentIndex;
//	char * pathInfo;
//	char base[128];
//	char path[PATH_MAX];
//
//	sprintf(base, "http://%s/cgi/noauth/nph-javalib/", getenv("HTTP_HOST"));
//	strcpy(path, documentRoot);
//	strcat(path, "/hmiw/lib/SvgEditor.jnlp");
//	contents = readFile(path, &length);
//	if (contents == NULL) {
//		sendMessage("SVGEditor.jnlp not found", true);
//		return false;
//	}
//	codebaseIndex = strstr(contents, "codebase=\"");
//	codebaseIndex += 10;
//	*codebaseIndex++ = 0;
//	argumentIndex = strstr(codebaseIndex, "EditorMain\">");
//	if (codebaseIndex == NULL || argumentIndex == NULL) {
//		sendMessage("Invalid jnlp file", true);
//		return false;
//	}
//	argumentIndex += 12;
//	*argumentIndex++ = 0;
//	printf("HTTP/1.0 200 ok\r\n");
//	printf("Content-type: application/x-java-jnlp-file\n");
//	//	printf("Content-type: application/x-java-archiver\n");
//	printf("\r\n");
//	printf(contents);
//	printf(base);
//	printf(codebaseIndex);
//	writeXmlChar(stdout, argument, "-url");
//	sprintf(base, "http://%s/", getenv("HTTP_HOST"));
//	writeXmlChar(stdout, argument, base);
//	writeXmlChar(stdout, argument, "-userName");
//	writeXmlChar(stdout, argument, getenv("REMOTE_USER"));
//	writeXmlChar(stdout, argument, "-userPassword");
//	writeXmlChar(stdout, argument, getenv("REMOTE_PASSWORD"));
//	printf(argumentIndex);
//	return true;
//}

/**
 *
 *
 */
int main(int argc, char *argv[]) {
	int ind, retValue;
	long fileSize;
	char * inputParameters = NULL;
	char * xmlData;
	char * remoteUser = NULL;
	char buffer[BUFFER_SIZE];
	char message[128];
	char path[PATH_MAX];
	int wrfd;
	FILE * pFile;
	error = false;
	HtmlVariable * htmlVariables = getHtmlVariables();

	message[0] = 0;
	documentRoot = getenv("DOCUMENT_ROOT");
	if (documentRoot == NULL) {
		documentRoot = WWW_PATH;
	}
	//	remoteUser = getenv("REMOTE_USER");
	inputParameters = getenv("QUERY_STRING");
	if (inputParameters == NULL && argc > 1) {
		inputParameters = argv[1];
	}
	htmlVariables[VAR_ACTION].initializedCount = 0;
	if (inputParameters != NULL) {
		htmlVariables = initHtmlVariables();
		parseHtmlInput(inputParameters, strlen(inputParameters));
	}
	//		printf(stdout, inputParameters);
	if (htmlVariables[VAR_ACTION].initializedCount > 0) {

//		switch (htmlVariables[VAR_ACTION].signedInt) {
//		case CMD_SVG_EDITOR_JNLP:
//			getJnlp();
//			exit(0);
//			break;
//			//	case CMD_UPLOAD_IMAGE:
//			//		break;
//
//		}
		printf("Status: 400 Ok\r\n\r\n");
		printf("XXX");
		return;
	} else {
		bool pack200 = true;
		// send the packed
		inputParameters = getenv("PATH_INFO");
		if (inputParameters != NULL) {
			sprintf(path, "%s/hmiw/lib%s.pack.gz", documentRoot, inputParameters);
			pFile = fopen(path, "r");
			if (pFile == NULL) {
				pack200 = false;
				sprintf(path, "%s/hmiw/lib%s", documentRoot, inputParameters);
				pFile = fopen(path, "r");
				if (pFile == NULL) {
					printf("HTTP/1.0 403 file not found\r\n");
					sendMessage("file not found", true);
					return;
				}
			}
			fseek(pFile, 0, SEEK_END);
			fileSize = ftell(pFile);
			rewind(pFile);

			printf("HTTP/1.0 200 ok\r\n");
			printf("Content-type: application/x-java-archive\r\n");
			if (pack200) {
				printf("Content-encoding: pack200-gzip\r\n");
			}

			printf("Content-length: %d\r\n", fileSize);
			//	printf("Content-type: application/x-java-archiver\n");
			printf("\r\n");
			while (true) {
				retValue = fread(buffer, 1, BUFFER_SIZE, pFile);
				if (retValue < 1) {
					break;
				}
				fwrite(buffer, 1, retValue, stdout);
			}
			fclose(pFile);
			fflush(stdout);
		}

	}
}
