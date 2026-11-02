#include <time.h>
#include "Parser.h"
#include "netConfigArtila.h"
#include "ezxml.h"
#include "ReadConfig.h"

#define HOST_NAME "hostName"
#define IP_ADDRESS "ipAddress"
#define NET_MASK "netMask"
#define GATEWAY "gateway"
#define NAME_SERVER "nameServer"
#define SEARCH_WORD "searchWord"
#define MESSAGE "message"
#define REBOOT "reboot"
#define MESSAGE "message"
#define EPOCH "epoch"

char unknownUser[] = "User?";
char adminUser[] = "admin";

char hostName[128];
char ipAddress[128];
char netMask[64];
char gateway[64];
char nameServer[128];
char searchWord[128];
char message[256];
char param_reboot[16];
char epoch[16];
char synchronize[32];
int deviceType;
char macAddress[32];
/**
 *
 *
 */
int parseInput(char * inputParameters, char ** message) {
	char* word = NULL;
	int wordLength = 0;
	int position = 0;
	epoch[0] = 0x0;
	synchronize[0] = 0x0;

	int inputLength = strlen(inputParameters);

	while (position < inputLength) {
		getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
		if (word != NULL && wordLength > 0) {
			if (strncmp(word, HOST_NAME, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(hostName, word, wordLength);
				hostName[wordLength] = 0;
			} else if (strncmp(word, IP_ADDRESS, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(ipAddress, word, wordLength);
				ipAddress[wordLength] = 0;
			} else if (strncmp(word, NET_MASK, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(netMask, word, wordLength);
				netMask[wordLength] = 0;
			} else if (strncmp(word, GATEWAY, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(gateway, word, wordLength);
				gateway[wordLength] = 0;
			} else if (strncmp(word, NAME_SERVER, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(nameServer, word, wordLength);
				nameServer[wordLength] = 0;
			} else if (strncmp(word, SEARCH_WORD, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(searchWord, word, wordLength);
				searchWord[wordLength] = 0;
			} else if (strncmp(word, REBOOT, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(param_reboot, word, wordLength);
				param_reboot[wordLength] = 0;
			} else if (strncmp(word, EPOCH, wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(epoch, word, wordLength);
				epoch[wordLength] = 0;
			} else if (strncmp(word, "synchronize", wordLength) == 0) {
				getNextWord((char*) inputParameters, &position, &word, &wordLength, inputLength);
				strncpy(synchronize, word, wordLength);
				synchronize[wordLength] = 0;
			}
		}
	}
	return 0;
}
/**
 *
 *
 */bool isIpValide(const char *ip_str) {
	unsigned int n1, n2, n3, n4;
	if (sscanf(ip_str, "%u.%u.%u.%u", &n1, &n2, &n3, &n4) != 4)
		return false;

	if ((n1 != 0) && (n1 <= 255) && (n2 <= 255) && (n3 <= 255) && (n4 <= 255))
		return true;
	return false;
}
/**
 *
 */
int setTime() {
	int epochInt;
	time_t rawtime;
	struct tm * dt;
	if (epoch[0] == 0) {
		return -1;
	}
	rawtime = atoi(epoch);
	dt = localtime(&rawtime);

	char date[100];

	if (deviceType == DEVICE_ARTILA) {

		sprintf(date,"date -s %02d%02d%02d%02d%d.%02d;hwclock -w",dt->tm_mon+1,dt->tm_mday,dt->tm_hour,dt->tm_min,dt->tm_year+1900,dt->tm_sec);
//	sprintf(date, "/bin/date %02d%02d%02d%02d%d.%02d; /sbin/hwclock -w", dt->tm_mon + 1, dt->tm_mday, dt->tm_hour,
//			dt->tm_min, dt->tm_year + 1900, dt->tm_sec);
	} else {

		sprintf(date, "/bin/date -s '%04d-%02d-%02d %02d:%02d:%02d'", dt->tm_year + 1900, dt->tm_mon + 1, dt->tm_mday,
				dt->tm_hour, dt->tm_min, dt->tm_sec);

	}

	return system(date);
}
/**
 *
 *
 *
 */
int main(int argc, char *argv[]) {
	// initialize some variables:
	char * inputParameters = NULL;
	char * remoteUser;
	char * outputMessage = NULL;
	char * xmlData;
	int retValue, length;
	//	ezxml_t ezRoot;
	FILE * pipe;
	char buffer[1024];
	int result;
	time_t seconds;
	bool admin;
	bool invalidIp;
	char * contents;
	bool readMacResult;

#ifdef ARM_LINUX
	deviceType = DEVICE_ARTILA;
#else

//	if (argc > 1) {
//		inputParameters = argv[1];
//		readConfigurationDebian("cat /tmp/interfaces");
//	}

	deviceType = DEVICE_UNKNOWN;
	pipe = popen("cat /etc/*-release", "r");
	if (pipe != NULL) {
		result = fread(buffer, 1, 1024, pipe);
		if (result > 1) {
			buffer[result] = 0;
			if (strstr(buffer, "Ubuntu") != NULL) {
				deviceType = DEVICE_SHEEVA_UBUNTU;
			} else if (strstr(buffer, "wheezy") != NULL) {
				deviceType = DEVICE_RASPBERRY_PI;
			} else if (strstr(buffer, "raspbian") != NULL) {
				deviceType = DEVICE_RASPBERRY_PI;
			} else {
				deviceType = DEVICE_ARTILA;
			}
		}
		pclose(pipe);
	}
	if (deviceType == DEVICE_UNKNOWN) {
		pipe = popen("cat /etc/issue", "r");
		if (pipe != NULL) {
			result = fread(buffer, 1, 1024, pipe);
			if (result > 1) {
				buffer[result] = 0;
				if (strstr(buffer, "Debian") != NULL) {
					deviceType = DEVICE_SHEEVA_DEBIAN;
				}
			}
			pclose(pipe);
		}
	}

	if (deviceType == DEVICE_UNKNOWN) {
		sendMessage("Sorry, unknown Device", true);
		return -3;
	}

#endif

	hostName[0] = 0;
	ipAddress[0] = 0;
	param_reboot[0] = 0;
	//	char configFile[128];
	//	strcpy(configFile, "netConfig.xml");
	//	ezRoot = ezxml_parse_file("www/cgi/netConfig.xml");
	remoteUser = getenv("REMOTE_USER");
	if (remoteUser == NULL) {
		if (deviceType == DEVICE_ARTILA) {
			remoteUser = &adminUser[0];
		} else {
			remoteUser = &unknownUser[0];
		}
	}

	//	if (ezRoot == NULL) {
	//		sendMessage("Couldn't read netconfig.xml", true);
	//		return;
	//	}
	// get query from enviroment:
	if (argc > 1) {
		inputParameters = argv[1];
		remoteUser = argv[2];

	} else {
		inputParameters = getenv("QUERY_STRING");
	}

	admin = false;
	if (remoteUser != NULL && strcmp(remoteUser, "admin") == 0) {
		admin = true;
	}

	if (inputParameters == NULL) {
		inputParameters = getenv("CONTENT_LENGTH");

		//		inputParameters = "13";
		if (inputParameters != NULL) {
			length = atoi(inputParameters);
		} else {
			length = 0;
		}
		if (length > 0) {
			inputParameters = malloc(length + 1);
			fread(inputParameters, 1, length, stdin);
			inputParameters[length] = 0;
			//			fprintf (stderr, "input params %s \n", inputParameters);
		}
	}

	if (inputParameters != NULL) {
		if (admin == false) {
			sendMessage("Sorry, access denied. Only for 'admin' user.", true);
			return -2;
		}
		parseInput(inputParameters, &outputMessage);
		if (strcmp(param_reboot, "yes") == 0) {

			system("/bin/sync");
			system("/sbin/reboot");
			fflush(stdout);
			sendMessage("The device will reboot soon, please wait .., Then click on 'Main-Menu' button. ", false);
			return 0;
		}
		if (synchronize[0] != 0) {
			readConfiguration();
			if (setTime() == -1) {
				strcpy(message, "Time Synchronization failed");
			} else {
				strcpy(message, "Time Synchronized.");
			}
		} else {
			// SAVE check ips
			invalidIp = false;
			if (isIpValide(ipAddress) == false) {
				strcpy(message, "Invalid IP Address");
			} else if (isIpValide(netMask) == false) {
				strcpy(message, "Invalid Subnet Mask");
			} else if (isIpValide(gateway) == false) {
				strcpy(message, "Invalid Gateway Address");
			} else if (isIpValide(nameServer) == false) {
				strcpy(message, "Invalid Name Server");
			} else { // everthing is oK
				if (writeNetworkConfig()) {
					strcpy(message, "Network Configuration saved. Please reboot the device.");
				} else {
					if (message[0] == 0) {
						strcpy(message, "ERROR: Couldn't save Network Configuration");
					}
				}
			}
		}
	} else {
		readConfiguration();
	}

	readMacResult = readMac(&macAddress[0]);
	if (readMacResult == false) {
		strcpy(message, "ERROR: Couldn't read Mac Address");
	}
	//	setTxt(ezRoot, hostName, strlen(hostName), HOST_NAME);
	//	setTxt(ezRoot, ipAddress, strlen(ipAddress), IP_ADDRESS);
	//	setTxt(ezRoot, netMask, strlen(netMask), NET_MASK);
	//	setTxt(ezRoot, gateway, strlen(gateway), GATEWAY);
	//	setTxt(ezRoot, nameServer, strlen(nameServer), NAME_SERVER);
	//	setTxt(ezRoot, searchWord, strlen(searchWord), SEARCH_WORD);
	//	setTxt(ezRoot, message, strlen(message), MESSAGE);
	//	setTxt(ezRoot, remoteUser, strlen(remoteUser), "remoteUser");
	//	setTxt(ezRoot, macAddress, strlen(macAddress), "macAddress");
	//	sprintf(message, "%d", time(NULL));
	//	setTxt(ezRoot, message, strlen(message), EPOCH);

	fprintf(stdout, "Status: 200 Ok\r\n");
	printf("Content-type: application/xml\r\n\r\n");
	printf("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
	printf("<?xml-stylesheet type=\"text/xsl\" href=\"../netConfig.xsl\" ?><configuration>");
	writeXmlChar(stdout, HOST_NAME, hostName);
	writeXmlChar(stdout, IP_ADDRESS, ipAddress);
	writeXmlChar(stdout, NET_MASK, netMask);
	writeXmlChar(stdout, GATEWAY, gateway);
	writeXmlChar(stdout, NAME_SERVER, nameServer);
	writeXmlChar(stdout, SEARCH_WORD, searchWord);
	writeXmlChar(stdout, MESSAGE, message);
	writeXmlChar(stdout, MESSAGE, message);
	writeXmlChar(stdout, "remoteUser", remoteUser);
	writeXmlChar(stdout, "macAddress", macAddress);
	sprintf(message, "%d", time(NULL));
	writeXmlChar(stdout, EPOCH, message);

	contents = readFile(GATEWAYS_FILE, &length);
	if (contents != NULL) {
		printf("%s",contents);
		free(contents);
	} else {
		printf("<gateways></gateways>");
	}
	printf("</configuration>\n");

	//	xmlData = ezxml_toxml(ezRoot);
	//	printf("%s", xmlData);
	//	free(xmlData);
	//	ezxml_free(ezRoot);
	return 0;
}

