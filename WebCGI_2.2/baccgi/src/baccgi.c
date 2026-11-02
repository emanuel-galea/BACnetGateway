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
#include <unistd.h>

#include <time.h>
#include <signal.h>

#include "Parser.h"
#include "HtmlParser.h"

#define MAX_BUF_SIZE 4096

#define SEM_NAME  "KARA_WEB"

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
	cgiklogf (LOGGER_BACCGI, LOG_ERR, "alarm_handler");
	if (waitingResponce) {
		operations[0].sem_num = 0; //signifies 0th semaphore
		operations[0].sem_op = 1; //reduce the semaphore count to lock
		operations[0].sem_flg = 0; //wait till we get lock on semaphore
		if (semop(semId, operations, 1) == -1) {
			perror("Thread1 Alarm :semop failure Reason:");
		}
		exit(-1);
	}
	//	exit(-1);
}

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
	char page[128];
	rdfd = open(NAMED_PIPE_WRITE, O_RDONLY);
	if (rdfd == NULL) {
		cgiklogf (LOGGER_BACCGI, LOG_ERR, "NAMED_PIPE_WRITE, O_RDONLY failed");
		return;
	}
	numread = read(rdfd, buffer, 1);
	contentType = buffer[0];
	char * contents;
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
int main(int argc, char *argv[]) {
	int ind, retValue, wrfd, rdfd, length;
	int numread;
	int semaphoreId;
//	struct timespec timeout;
	char * remoteUser = NULL;
	char * password;
	bool htmlPost;
	struct sigaction new_action;
	char * contents;

	char * xmlData;
	FILE * pFile;
	waitingResponce = false;

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
	alarm(60); /* 60 second timeout */
#else
	alarm(20); /* 20 second timeout */
#endif

	//	sem_t *mutex;
	semId = semget(KEY, 1, 0666);
	if (semId < 0) { /* Semaphore does not exist. */
		cgiklogf (LOGGER_BACCGI, LOG_ERR, "Coulbn' create Semaphore");
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
//	timeout.tv_sec = 20; // 10 seconds
//	timeout.tv_nsec = 0;
	retValue = semop(semId, operations, 1);
	if (retValue == -1 && errno == EINTR) {
		if (alarm_triggered) {
			cgiklogf (LOGGER_BACCGI, LOG_ERR, "sematiemop failed (-3) with error %d", errno );
			exit(-3);
		} else {
			cgiklogf (LOGGER_BACCGI, LOG_ERR, "sematiemop failed with error %d", errno );
			exit(-2);
		}
	}

	//	struct timespec ts;
	//
	//	ts.tv_sec = 8;
	//	ts.tv_nsec = 0;
	ezxml_t ezRoot;

	/* Create the semaphore with external key KEY if it doesn't already
	 exists. Give permissions to the world. */
	//	mutex = sem_open(SEM_NAME ,O_CREAT,0644,1);
	//	if(mutex == SEM_FAILED) 	    {
	//	     perror("unable to create semaphore");
	//	      sem_unlink(SEM_NAME);
	//	      exit(-1);
	//	}
	//
	////	sem_timedwait(mutex, &ts);
	//	sem_wait(mutex);

	if (argc > 1) {
		inputParameters = argv[1];
	} else {
		inputParameters = getenv("QUERY_STRING");
	}
	length = 0;
	if (inputParameters == NULL) {
		inputParameters = getenv("CONTENT_LENGTH");
		if (inputParameters != NULL) {
			length = atoi(inputParameters);
		} else {
			length = 0;
		}
		if (length > 0) {
			inputParameters = malloc(length + 1);
			fread(inputParameters, 1, length, stdin);
			inputParameters[length] = 0;
			htmlPost = true;
			//			fprintf (stderr, "input params %s \n", inputParameters);
		}
	} else {
		htmlPost = false;
		length = strlen(inputParameters);
	}

	/* Open the first named pipe for writing */
	wrfd = open(NAMED_PIPE_READ, O_WRONLY | O_NONBLOCK);
	if (wrfd < 0) {
		printf("Status: 200 Ok\r\n");
		printf("Content-type: text/html\r\n");
		printf("\r\n");
		printf(
			"<h2 style=\"color: red\">ERROR: Server probably is not running. Error:  %s<p >"
			"<a href=\"/index.html\"> Return to Main Menu </a><h2>"
			"<a href=\"/cgi/update?action=5\"> Download the Log file</a><h2>"
			"<p><h4><a href=\"/core\"> Downlaod Core-Dump </a></h4>"
			"<A href=\"netConfig?reboot=yes\"  >"
			"<img border=\"0\" src=\"../images/32/system-reboot.png\" />"
			"Reboot Device now </A>" , strerror(errno));
//		contents = (char *)readFile(BACKTRACE_PATH, &length);
//		if (contents != NULL) {
//			printf ("<pre>");
//			printf ("%s", contents);
//			printf ("<pre>");
//			free(contents);
//		}

	} else {
		message[0] = (char) user;
		write(wrfd, &message[0], 1);
		write(wrfd, inputParameters, length);
	 	cgiklogf (LOGGER_BACCGI, LOG_DEBUG, "Params %s ", inputParameters);
		if (password != NULL) {
			write(wrfd, "&pwd=", 5);
			write(wrfd, password, strlen(password));
		}

		close(wrfd);
		waitingResponce = true;
		//		alarm(20);
		response();
		fflush(stdout);
	}

	if (htmlPost) { // was it a post
		free(inputParameters);
	}

	//	printf("REMOTE_USER is %s   %d\n", remoteUser, user);
	//release unlock the 0th semaphore
	operations[0].sem_num = 0;  //signifies 0th semaphore
	operations[0].sem_op = 1; 	//reduce the semaphore count to lock
	operations[0].sem_flg = 0; //wait till we get lock on semaphore
	if (semop(semId, operations, 1) == -1) {
		perror("Thread1: release semop failure Reason:");
		exit(-1);
	}
	//	sem_post(mutex);
	//	sem_close(mutex);
	//	  sem_unlink(SEM_NAME);

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
