#include <modbus.h>
#include <errno.h>
#include <pty.h>
#include <stdio.h>
#include <termio.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include <stdbool.h>

/* compiling : gcc slave-example.c -o slave-example -lmodbus */

void answer_sended(int function, int address, int length) {
	printf("packet sended : function 0x%x \t address 0x%x \t length %d\n", function, address, length);
}

uint8_t * writeFile(char * fileName, uint8_t * buffer) {

	FILE * pFile;
	pFile = fopen(fileName, "w");
	if (pFile == NULL) {
		return NULL;
	}
	fputs(buffer, pFile);
	fclose(pFile);
	return buffer;
}

int main() {
	char initMessage[256];
	int device;
	int retValue;
	int portFD;
	int ptn, bit;
	char ptname[100];

	Mbs_data = (int *) malloc(255 * sizeof(int)); /* allocate the modbus database */
	if ((retValue = portFD = open("/dev/ptmx", O_RDWR)) < 0) {
		sprintf(&initMessage[0], "ERROR: Failed to open port /dev/ptmx error %s", strerror(errno));
		fprintf(stderr, "%s\n", initMessage);
		return -1;
	}
	ioctl(portFD, TIOCGPTN, &ptn);
	bit = 0;
	ioctl(portFD, TIOCSPTLCK, &bit);
	snprintf(ptname, 32, "/dev/pts/%d", ptn);
	printf("Slave Port is %s\n", ptname);
	writeFile("/tmp/kara_simulator_port.txt", ptname);

	device = Mb_open_device(ptname, 9600, 1, 8, 2); /* open device Even PArity */

	Mb_verbose = 1; /* print debugging informations */

	Mb_slave(device, 1, NULL, NULL, answer_sended); /* start slave thread with slave number=1*/
	getchar(); /* hit <return> to stop program */
	Mb_slave_stop(); /* kill slave thread */
	Mb_close_device(device); /* close device */
	return 0;
}

