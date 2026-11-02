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
#include <sys/ipc.h>
#include <sys/sem.h>
#include <errno.h>

#include <time.h>
#include <signal.h>
#include "cgic.h"

#include "Parser.h"
#include "HtmlParser.h"

#define MAX_BUF_SIZE 4048

#define SEM_NAME  "KARA_WEB"

#define SAVED_ENVIRONMENT "/tmp/cgicsave.env"

void response();

char * inputParameters = NULL;
int user;

char buffer[MAX_BUF_SIZE + 1];

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

//void LoadEnvironment() {
//	if (cgiReadEnvironment(SAVED_ENVIRONMENT) != cgiEnvironmentSuccess) {
//		cgiHeaderContentType("text/html");
//		fprintf(cgiOut, "<head>Error</head>\n");
//		fprintf(cgiOut, "<body><h1>Error</h1>\n");
//		fprintf(cgiOut, "cgiReadEnvironment failed. Most "
//				"likely you have not saved an environment "
//				"yet.\n");
//		exit(0);
//	}
//	/* OK, return now and show the results of the saved environment */
//}

/**
 *  Response from BACSERV
 *  First byte is the content Type
 *  Then the page name (zero terminated)
 *  Than the data in XML
 *
 */
void response() {
	int rdfd, numread, contentType;
	int ind;
	char page[64];
	rdfd = open(NAMED_PIPE_WRITE, O_RDONLY);
	numread = read(rdfd, buffer, 1);
	contentType = buffer[0];
	// read destination page name;
	ind = 0;
	page[0] = 0;
	while (true) {
		numread = read(rdfd, &page[ind], 1);
		if (page[ind] == 0 || numread == 0) {
			break;
		}
		ind++;
	}

	if (rdfd < 1) {
		printf("Status: 200 Ok\r\nContent-type: text/html\r\n\r\n");
		printf("<h2>ERROR:  failed<h2>");
	} else {
		switch (contentType) {
		case XML_XSL_CONTENT:
			printf("Status: 200 Ok\r\nContent-type: application/xml\r\n\r\n");
			printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\" ?>\n");
			printf("<?xml-stylesheet type=\"text/xsl\" href=\"../%s\" encoding=\"ISO-8859-1\" ?>\n", page);
			break;
		case HTML_XML_CONTENT:
			printf("Status: 200 Ok\r\nContent-type: text/xml\r\n\r\n");
			break;
		case EXCEL_CONTENT:
			printf("Status: 200 Ok\r\nContent-type: application/xml\r\n");
			printf("Content-disposition: attachement; filename=\"%s\"\r\n\r\n", page);
			printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
			break;
		case XML_CONTENT:
			printf("Status: 200 Ok\r\nContent-type: text/xml\r\n\r\n");
			printf("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
			break;
		case HTML_CONTENT:
			printf("Status: 200 Ok\r\nContent-type: text/html\r\n\r\n");
			break;
		}

		while (true) {
			numread = read(rdfd, buffer, MAX_BUF_SIZE);
			//			fprintf(stderr, "readbytes=%d", numread);
			if (numread > 0) {
				buffer[numread] = 0;
				printf(buffer);
			} else {
				break;
			}
		}
	}
}

/**
 *
 *
 */
int cgiMain() {
	int ind, retValue, wrfd, rdfd, length;
	int numread;
	int semaphoreId;
	struct timespec timeout;
	char * remoteUser = NULL;
	char * password;
	bool htmlPost;
	struct sigaction new_action;
	char name[1024];
	int size;
	char contentType[1024];
	char value[64];
	cgiFormResultType cgiFormResultType;


	char * xmlData;
	FILE * pFile;
	waitingResponce = false;
//	cgiWriteEnvironment("/tmp/karacgi.txt");

	char message[128];
	const char logger[] = "bacserv";
	ezxml_t ezMessage;

	openlog(logger, LOG_CONS, LOG_USER);
	setlogmask(LOG_UPTO(LOG_INFO));

	new_action.sa_handler = alarm_handler;
	sigemptyset(&new_action.sa_mask);
	new_action.sa_flags = 0;
	sigaction(SIGALRM, &new_action, NULL);
#ifdef DEBUG
	alarm(60); /* 20 second timeout */
#else
	alarm(15); /* 20 second timeout */
#endif

	//	sem_t *mutex;

	semId = semget(KEY, 1, 0666);
	if (semId < 0) { /* Semaphore does not exist. */
		sendMessageHtml("Program sema cannot find semaphore, exiting.", true);
		exit(0);
	}
	remoteUser = getenv("REMOTE_USER");
	password = getenv("REMOTE_PASSWORD");

	user = parseRemoteUser(remoteUser);

	/* Set up the sembuf structure. */
	/* Which semaphore in the semaphore array : */
	operations[0].sem_num = 0;
	/* Which operation? Add 1 to semaphore value : */
	operations[0].sem_op = -1; // reduce the semaphore count to lock

	/* Set the flag so we will wait : */
	operations[0].sem_flg = SEM_UNDO;

	/* So do the operation! */
	//	retValue = semop(semId, operations, 1);
	timeout.tv_sec = 20; // 10 seconds
	timeout.tv_nsec = 0;
	retValue = semop(semId, operations, 1);
	if (retValue == -1 && errno == EINTR) {
		if (alarm_triggered) {
			exit(-3);
		} else {
			syslog(LOG_ERR, "sematiemop function failed with error %d", errno);
			exit(-2);
		}
	}

	//	struct timespec ts;
	//
	//	ts.tv_sec = 8;
	//	ts.tv_nsec = 0;
	ezxml_t ezRoot;

	/* Open the first named pipe for writing */
	wrfd = open(NAMED_PIPE_READ, O_WRONLY | O_NONBLOCK);
	if (wrfd < 0) {
		printf("Status: 200 Ok\r\n");
		printf("Content-type: text/html\r\n");
		printf("\r\n");
		printf(
				"<h2 style=\"color: red\">ERROR: Server probably is not running. Error:  %s<p ><a href=\"/index.html\"> Return to Main Menu </a><h2>"
				"<p><h4><a href=\"/core\"> Downlaod Core-Dump </a></h4>  ",
				strerror(errno));
	} else {
		message[0] = (char) user;
		write(wrfd, &message[0], 1);

		write(wrfd, "gate=", 5);
		cgiFormString("gate", value, sizeof(value));
		write(wrfd, value, strlen(value));
		write(wrfd, "&action=", 8);
		cgiFormString("action", value, sizeof(value));
		write(wrfd, value, strlen(value));

//		write(wrfd, "&address=", 4);
//		cgiFormString("address", value, sizeof(value));
//		write(wrfd, value, strlen(value));

		cgiFormResultType = cgiFormTempFileName("file", value, sizeof(value));
		write(wrfd, "&address=", 9);
		write(wrfd, value, strlen(value));

		if (password != NULL) {
			write(wrfd, "&pwd=", 5);
			write(wrfd, password, strlen(password));
		}

		close(wrfd);
		waitingResponce = true;
		//		alarm(20);
		response();
	}

	if (htmlPost) { // was it a post
		free(inputParameters);
	}

	//	printf("REMOTE_USER is %s   %d\n", remoteUser, user);

	//release the 0th semaphore
	operations[0].sem_num = 0; //signifies 0th semaphore
	operations[0].sem_op = 1; //reduce the semaphore count to lock
	operations[0].sem_flg = 0; //wait till we get lock on semaphore
	if (semop(semId, operations, 1) == -1) {
		perror("Thread1:semop failure Reason:");
		exit(-1);
	}
}

/**
 *
 */
//static  void chartOutput () {
//	char * pChart;
//	char * ptr;
//	int length;
//	char fileName[64];
//	strcpy(fileName, "../amcharts/");
//	switch (reportType) {
//	case REPORT_TYPE_FROMTO:
//
//		break;
//	case REPORT_TYPE_HOURLY:
//		strcat(fileName, "hourChart.html");
//		break;
//	case REPORT_TYPE_DAILY:
//		strcat(fileName, "dailyChart.html");
//		break;
//	case REPORT_TYPE_MONTLY:
//		strcat(fileName, "montlyChart.html");
//		break;
//	}
//	pChart = (char *) readFile(fileName, &length);
//	if (pChart == NULL) {
//		printf("Status: 200 Ok\r\nContent-type: text/html\r\n\r\n");
//		printf("<h2>ERROR:  failed<h2>");
//	} else {
//		ptr = strstr(pChart, "KaraSystems");
//		if (ptr == NULL) {
//
//		} else {
//			*ptr = 0x0;
//			printf("Status: 200 Ok\r\nContent-type: text/html\r\n\r\n");
//			printf("%s", pChart);
//			printf("readMeters?action=D");
//			printf("%s", ptr + 11);
//		}
//		free(pChart);
//	}
//}

static void testPage () {
	char name[1024];
	int size;
	char contentType[1024];

	cgiHeaderContentType("text/html");
	/* Top of the page */
	fprintf(cgiOut, "<HTML><HEAD>\n");
	fprintf(cgiOut, "<TITLE>cgic test</TITLE></HEAD>\n");
	fprintf(cgiOut, "<BODY><H1>cgic test</H1>\n");
	/* If a submit button has already been clicked, act on the
	 submission of the form. */
	if ((cgiFormSubmitClicked("testcgic") == cgiFormSuccess)
			|| cgiFormSubmitClicked("saveenvironment") == cgiFormSuccess) {
//			HandleSubmit();
		fprintf(cgiOut, "<hr>\n");
	}

	if (cgiFormFileName("file", name, sizeof(name)) != cgiFormSuccess) {
		printf("<p>No file was uploaded.<p>\n");
		return;
	}

//	fprintf(cgiOut, "The filename submitted was: ");
	cgiHtmlEscape(name);
	fprintf(cgiOut, "<p>\n");
	cgiFormFileSize("file", &size);
	fprintf(cgiOut, "The file size was: %d bytes<p>\n", size);
	cgiFormFileContentType("file", contentType, sizeof(contentType));
	fprintf(cgiOut, "The alleged content type of the file was: ");
	cgiHtmlEscape(contentType);


	cgiFormString("action", contentType, sizeof(contentType));
	fprintf(cgiOut, "The action is : %s <p>\n", contentType);
	/* Now show the form */
//		ShowForm();
	/* Finish up the page */
	fprintf(cgiOut, "blabla </BODY></HTML>\n");
	return;
}
