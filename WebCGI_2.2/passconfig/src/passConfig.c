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
#include <errno.h>
#include <syslog.h>
#include <string.h>
#include "Parser.h"

extern char * url_decode(char * outputBuffer, char * str, int length, bool copyAll);

char password[32];
char decodedPassword[32];
char forUser[32];

int runhtpass(char * passwd, char * message);

/**
 *
 *
 */
int parseInput(char * inputParameters) {
	char* word = NULL;
	int wordLength = 0;
	int position = 0;
	char * txt;
	int inputLength = strlen(inputParameters);

	while (position < inputLength) {
		getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
		if (word != NULL && wordLength > 0) {
			if (strncmp(word, "password", wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(password, &word[0], wordLength);
			} else if (strncmp(word, "forUser", wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(forUser, &word[0], wordLength);
			}
		}
	} // while
}

/**
 *
 *
 */
int main(int argc, char *argv[]) {
	int ind, retValue;
	char * inputParameters = NULL;
	char * remoteUser = NULL;
	char * xmlData;
	bool error;

	char configFile[128];
	char message[128];
	password[0] = 0;
	ezxml_t ezMessage;

	message[0] = 0;
	//	xmlData = ezxml_toxml(ezRoot);

	//	inputParameters = "passConfig?password=password";

	remoteUser = getenv("REMOTE_USER");
	if (argc > 1) {
		inputParameters = argv[1];
		remoteUser = argv[2];
	} else {
		inputParameters = getenv("QUERY_STRING");
	}

	if (strcmp(remoteUser, "admin") != 0) {
		adminMessageHtml("Sorry, only 'admin' user can change passwords.", true);
	} else {
		//	printf("inputParameters %s\n", inputParameters);
		if (inputParameters != NULL) {
			parseInput(inputParameters);
			if (password[0] != 0) { // password changed
				url_decode(&decodedPassword[0], &password[0], strlen(password), true);
				if (strchr(decodedPassword, ' ') != NULL) {
					strcpy(message, "Sorry, please don't use 'spaces' in password.");
					error = true;
				} else {
					retValue = runhtpass(decodedPassword, &message[0]);
					if (retValue != 0) {
						error = true;
					} else {
						strcpy(message, "Password saved successful");
						error = false;
					}
				}
			}
		}
		responseXSL("../passConfig.xsl");
		fprintf(stdout, "<root>");
		writeXmlChar(stdout, "message", message);
		writeXmlBool(stdout, "error", error);
		printGateways(stdout);
		fprintf(stdout, "</root>");

	}
}
/**
 *
 */
int runhtpass(char * passwd, char * message) {
	char command[128];
	int retValue;

	// setup command:
	sprintf(command, "%s %s %s %s", PASSWORD_EXECUTABLE, PASSWORD_FILE, forUser, passwd);

	// change password:
	retValue = system(command);
	if (retValue  != 0) {
		sprintf(message, "Error Executine htpasswd.  %d %s", retValue, command);
		return retValue;
	}

	// setup command:
	sprintf(command, "cp %s %s", PASSWORD_FILE, PASSWORD_FILE_CGI);
	// copy  password:
	retValue = system(command);
	if (retValue != 0) {
		sprintf(message, "Error coping passwd.  %d %s", retValue, command);
		return retValue;
	}

	return 0;
}

