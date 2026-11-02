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

char action;
char ipAddress[32];
char mask[32];
char port[6];
char page[32];
char tracerip[64];
char bbmd_index[4];
char argument[] = {
		"argument" };
bool saveAction;
bool iamAction;

char message[256];
char consume[16];

bool displayModbus = false;
bool displayOneWire = false;
bool error;
/**
 *
 */
bool getJnlp() {
	char * contents;
	int length;
	char * codebaseIndex;
	char * argumentIndex;
	char * documentRoot;
	char * pathInfo;
	char base[128];
	char path[PATH_MAX];
	documentRoot = getenv("DOCUMENT_ROOT");
	if (documentRoot == NULL) {
		documentRoot = WWW_PATH;
	}

	sprintf(base, "http://%s/cgi/noauth/nph-javalib/", getenv("HTTP_HOST"));
	strcpy(path, documentRoot);
	strcat(path, "/hmiw/lib/SvgEditor.jnlp");
	contents = readFile(path, &length);
	if (contents == NULL) {
		sendMessage("SVGEditor.jnlp not found", true);
		return false;
	}
	codebaseIndex = strstr(contents, "codebase=\"");
	codebaseIndex += 10;
	*codebaseIndex++ = 0;
	argumentIndex = strstr(codebaseIndex, "EditorMain\">");
	if (codebaseIndex == NULL || argumentIndex == NULL) {
		sendMessage("Invalid jnlp file", true);
		return false;
	}
	argumentIndex += 12;
	*argumentIndex++ = 0;
//	printf("HTTP/1.0 200 ok\r\n");
	printf("Content-type: application/x-java-jnlp-file\n");
	//	printf("Content-type: application/x-java-archiver\n");
	printf("\r\n");
	printf("%s",contents);
	printf("%s", base);
	printf("%s",codebaseIndex);
	writeXmlChar(stdout, argument, "-url");
	sprintf(base, "http://%s/", getenv("HTTP_HOST"));
	writeXmlChar(stdout, argument, base);
	writeXmlChar(stdout, argument, "-userName");
	writeXmlChar(stdout, argument, getenv("REMOTE_USER"));
	writeXmlChar(stdout, argument, "-pwd");
	writeXmlChar(stdout, argument, getenv("REMOTE_PASSWORD"));
	printf("%s",argumentIndex);
	return true;
}

/**
 *
 *
 */
int main(int argc, char *argv[]) {
	int ind, retValue;
	char * inputParameters = NULL;
	char * xmlData;
	char * remoteUser = NULL;
	char buffer[64];
	int wrfd;
	int deviceType;
	error = false;
	HtmlVariable * htmlVariables;

	message[0] = 0;
	//	xmlData = ezxml_toxml(ezRoot);
	remoteUser = getenv("REMOTE_USER");
	inputParameters = getenv("QUERY_STRING");
	if (inputParameters == NULL && argc > 1) {
		inputParameters = argv[1];
	}
	htmlVariables = getHtmlVariables();
	htmlVariables[VAR_ACTION].initializedCount = 0;
	if (inputParameters != NULL) {
		htmlVariables = initHtmlVariables();
		parseHtmlInput(inputParameters, strlen(inputParameters));
	}
	//		printf(stdout, inputParameters);
	if (htmlVariables[VAR_ACTION].initializedCount > 0) {

		switch (htmlVariables[VAR_ACTION].signedInt) {
		case CMD_SVG_EDITOR_JNLP:
			retValue = getJnlp();
			exit(0);
			break;
			//	case CMD_UPLOAD_IMAGE:
			//		break;

		}
		if (retValue == 0) {
			printf("Status: 200 Ok\r\n\r\n");
		} else {
			printf("Status: 400 Ok\r\n\r\n");
		}
		printf("%s",message);
		return 0;
	} else {
		responseXSL("../index.xsl");
		fprintf(stdout, "<root>");
		writeXmlChar(stdout, "message", message);
		if (message[0] != 0) {
			writeXmlBool(stdout, "error", error);
		}
		if ((remoteUser != NULL) && ((strcmp(remoteUser, "admin") == 0) || (strcmp(remoteUser, "demo")) == 0)) {
			writeXmlBool(stdout, "admin", true);
		}
		printGateways(stdout);
		fprintf(stdout,"<deviceType>%s</deviceType></root>" , getDeviceType(&deviceType));
		return 0;
	}
}
