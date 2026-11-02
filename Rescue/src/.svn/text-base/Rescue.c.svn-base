/*
 ============================================================================
 Name        : rescue.c
 Author      :
 Version     :
 Copyright   : Your copyright notice
 Description : Hello World in C, Ansi-style
 ============================================================================
 */

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <unistd.h>
#include <stdbool.h>
#include <errno.h>

#include <sys/stat.h>
#include <sys/mount.h>
#include "syslog.h"

#define INSTALL_COMMAND_ENC "cat %s | openssl aes-128-ecb -d -pass pass:KaraSystems1 | tar -xjvP"
#define INSTALL_COMMAND "tar -xjvf %s"
#define USB_FILE_FIRMWARE "/mnt/usbdrive/_rescue_/firmware.enc"
#define USB_FILE_RECOVER_ENC "/mnt/usbdrive/_rescue_/recover.enc"
#define USB_FILE_RECOVER "/mnt/usbdrive/_rescue_/recover.tar"
#define USB_FILE_RECOVER_LOG "/mnt/usbdrive/_rescue_/log.txt"

#define LED_ON "echo ""default-on"" > /sys/class/leds/plug\\:green\\:health/trigger"
#define LED_OFF "echo ""none"" > /sys/class/leds/plug\\:green\\:health/trigger"
#define LOCK_FILE "/mnt/gate/bin/rescueLock"
bool debug;

#define DEFAULT_USER "root"
#define USB_DEVICE "/dev/sda"
#define USB_DEVICE1 "/dev/sda1"

#define MMC_DEVICE "/dev/mmcblk0"
#define MMC_DEVICE1 "/dev/mmcblk0p1"

static char* user;

static char* logfile;
static char* pidFile;
static char* logfile;
static char* argv0;

static char recoveryFile[128];

static void usage(void) {
	(void) fprintf(stderr, "usage:  %s  [-D debug] [-u user] [-v]  [-i pidfile] \n", argv0);
	exit(1);
}

static void clearLogUsb() {
	FILE * pFile = fopen(USB_FILE_RECOVER_LOG, "w");
	fclose(pFile);
}

static void writeLogUsb(char * message) {
	FILE * pFile = fopen(USB_FILE_RECOVER_LOG, "a");
	if (pFile > 0) {
		fputs(message, pFile);
		fclose(pFile);
	}
	fprintf(stderr, "%s", message);
}

static char cwd[128];

int getRecoveryFile() {
	struct stat sts;
	strcpy(recoveryFile, USB_FILE_RECOVER);
	if (stat(recoveryFile, &sts) == 0) {
		return 0;
	}
	strcpy(recoveryFile, USB_FILE_RECOVER_ENC);
	if (stat(recoveryFile, &sts) == 0) {
		return 1;
	} else {
		return -1;
	}
}

static bool install(int mode) {
	char installCommand[256];
	char message[256];
	struct stat sts;
	int retValue;

	if (stat(LOCK_FILE, &sts) == 0) { // if lock file exists do nothing
		writeLogUsb("Lock file exists, do nothing\n");
		fprintf(stdout, "Lock file exists, do nothing\n");
		return false;
	}
	FILE * pFile = fopen(LOCK_FILE, "w"); // write lock file
	fclose(pFile);
	retValue = system("/etc/init.d/mini_httpd.sh stop");
	if (retValue != 0) {
		sprintf(message, "HttpD Service Stop failed: Error %d - %s\n", retValue, strerror(errno));
		writeLogUsb(message);
	}
	retValue = system("/etc/init.d/bacserv.sh stop");
	if (retValue != 0) {
		sprintf(message, "bacserv Service Stop failed: Error %d - %s\n", retValue, strerror(errno));
		writeLogUsb(message);
	}
	if (mode == 0) {
		sprintf(installCommand, INSTALL_COMMAND, recoveryFile);
	} else {
		sprintf(installCommand, INSTALL_COMMAND_ENC, recoveryFile);
	}
	sprintf(message, "Installing - %s\n", installCommand);
	writeLogUsb(message);
	retValue = system(installCommand);
	if (retValue != 0) {
		sprintf(message, "Extracting File failed: Error %d - %s\n", retValue, strerror(errno));
		writeLogUsb(message);
		return false;
	} else {
		sprintf(message, "Files copied succesful. rebooting in 10 seconds\n");
		writeLogUsb(message);
		system("reboot");
	}
	return true;
}

/**
 *     M A I N
 *
 */
int main(int argc, char *argv[]) {

	int count = 0;
	int argn;
	int retValue;
	user = DEFAULT_USER;
	logfile = (char*) 0;
	pidFile = (char*) 0;
	argv0 = argv[0];
	debug = false;
	argn = 1;
	int mode;
	char message[256];
	struct stat sts;
	while (argn < argc && argv[argn][0] == '-') {
		if (strcmp(argv[argn], "-V") == 0) {
			(void) printf("%s\n", "RESCUE V1.2");
			exit(0);
		} else if (strcmp(argv[argn], "-D") == 0) {
			debug = true;
			printf("DEBUG mode\n");
		} else if (strcmp(argv[argn], "-u") == 0 && argn + 1 < argc) {
			++argn;
			user = argv[argn];
			printf("user is %s\n", user);
		} else if (strcmp(argv[argn], "-i") == 0 && argn + 1 < argc) {
			++argn;
			pidFile = argv[argn];
		} else {
			usage();
		}
		++argn;
	}

	/* Make ourselves a daemon. */
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

	if (chroot("/") < 0) {
		syslog(LOG_CRIT, "chroot - %m");
		perror("chroot");
		exit(1);
	}
	if (chdir("/") < 0) {
		syslog(LOG_CRIT, "chroot chdir - %m");
		perror("chroot chdir");
		exit(1);
	}

	getcwd(cwd, sizeof(cwd) - 1);
	printf("currentDirectory: %s\n", cwd);

	if (stat("/mnt/usbdrive", &sts) != 0) {
		mkdir("/mnt/usbdrive", 0777);
	}


	for (count = 0; count < 3; count++) {
		if (debug) {
			sleep(2);
		} else {
			sleep(5);
		}
		fprintf(stdout, "try to mount ");
		// check if there is a USB Pluged in

		if (stat(USB_DEVICE, &sts) == 0) {
			retValue = mount(USB_DEVICE, "/mnt/usbdrive", "vfat", 0, "");
			if (retValue != 0) {
				sprintf(message, "Mount %s failed with error: %d - %s\n", USB_DEVICE,  errno, strerror(errno));
				writeLogUsb(message);
				retValue = mount(USB_DEVICE1, "/mnt/usbdrive", "vfat", 0, "");
			}

			if (retValue == 0) {
				mode = getRecoveryFile();
				sprintf(message, "Recovery File: %s - Mode= %d\n", recoveryFile, mode);
				writeLogUsb(message);

				if (mode < 0) {
					writeLogUsb("No rescue directory found\n");
					remove(LOCK_FILE);
				} else {
					install(mode);
				}
			} else {

				sprintf(message, "Mount %s failed with error: %d - %s\n", USB_DEVICE1,  errno, strerror(errno));
				writeLogUsb(message);
				mode = getRecoveryFile();
				if (mode < 0) {
					writeLogUsb("No rescue directory found\n");
					remove(LOCK_FILE);
				} else {
					install(mode);
				}
			}
		}
//		printf("No drive found\n");
		remove(LOCK_FILE);
	} // for
	writeLogUsb("Ready\n");
	return EXIT_SUCCESS;
}
