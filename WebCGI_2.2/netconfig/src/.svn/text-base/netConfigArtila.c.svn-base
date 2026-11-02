/*+-------------------------------------------------------------------------+*/
/*| include local headers                                                   |*/
/*+-------------------------------------------------------------------------+*/

#include <errno.h>
#include <signal.h>
#include <sys/poll.h>
#include "Parser.h"
#include "netConfigArtila.h"

/*+-------------------------------------------------------------------------+*/
/*| defines:                                                                |*/
/*+-------------------------------------------------------------------------+*/
// output messages:
#define MESS_EN_NETWORK "Changing Network Configuration failed"
#define MESS_EN_SUCCESS	"Your Network Configuration has changed."
#define FAILURE_RDVPN 	1
#define FAILURE_NETWORK 2
#define FAILURE_PPP     3
#define SUCCESS_PPP     4
#define SUCCESS		    0
#define IP_ADDR			"WSP_IP"

// config files:
#define NET_CONF        "/etc/rc"
#define NET_CONF_BAC    "/etc/rc_backup"
#define RESOLV_CONF     "/etc/resolv.conf"
#define RESOLV_CONF_BAC "/etc/resolv.conf_backup"

#define DEBIAN_INTERFACE    "/etc/network/interfaces"
#define DEBIAN_RESOLV_CONF   "/etc/resolv.conf"
#define DEBIAN_HOSTNAME   "/etc/hostname"

#define BACKUP_ENDING   "_backup"

// net configuration commands:
#define C_HOSTNAME      "hostname "
#define C_IFCONFIG      "ifconfig eth0 "
#define C_ROUTE         "route add default gw "
#define C_NAMESERVER    "nameserver "
#define C_SEARCH        "search "
// ppp config commands:
#define C_PPP_IP		"local ip"
#define C_PPP_RANGE     "ip range"

/*+---------------------------------------------------------------------+*/
/*| defines for dforkExec:                                           |*/
/*+---------------------------------------------------------------------+*/
#ifndef HL_UNIX
#define HL_UNIX
#endif
#define EXEC_FORK_PIPES_DATA_LEN             (2*sizeof(int)) // child communication
#define EXEC_WAIT_DELAY                      200             // in ms, premature death check time
#define NB13_OP_OK                           0
#define NB13_NULL_PTR                       -1
#define NB13_EXEC_GEN_PIPE1_FAILED          -100
#define NB13_EXEC_FSETFL_PIPE1_FAILED       -101
#define NB13_EXEC_FORK1_FAILED              -102
#define NB13_EXEC_WAIT1_FAILED              -103
#define NB13_EXEC_READ1_INVALID             -104
#define NB13_EXEC_READ1_FAILED              -105
#define NB13_EXEC_GEN_PIPE2_FAILED          -106
#define NB13_EXEC_FSETFL_PIPE2_FAILED       -107
#define NB13_EXEC_SETSID1_FAILED            -108
#define NB13_EXEC_BLOCK_SIGHUP1_FAILED      -109
#define NB13_EXEC_FORK2_FAILED              -110
#define NB13_EXEC_READ2_INVALID             -111
#define NB13_EXEC_READ2_FAILED              -112
#define NB13_EXEC_REREAD2_INVALID           -113
#define NB13_EXEC_REREAD2_FAILED            -114
#define NB13_EXEC_UNBLOCK_SIGNALS2_FAILED   -115
#define NB13_EXEC_CHDIR2_FAILED             -116
#define NB13_EXEC_OPEN_DEVNULL_RO_FAILED    -117
#define NB13_EXEC_REDIR_STDIN_FAILED        -118
#define NB13_EXEC_OPEN_DEVNULL_RDWR_FAILED  -119
#define NB13_EXEC_REDIR_STDERR_FAILED       -120
#define NB13_EXEC_OPEN_DEVNULL_WR_FAILED    -121
#define NB13_EXEC_REDIR_STDOUT_FAILED       -122
#define NB13_EXEC_START_EXEC2_FAILED        -123
#define NB13_EXEC_CHECK_PID_FAILED          -124
#define NB13_EXEC_STARTED_EXEC_DIED         -125

extern char hostName[128];
extern char ipAddress[128];
extern char netMask[128];
extern char gateway[128];
extern char nameServer[128];
//extern char searchWord[128];
extern char message[256];
extern int deviceType;

char debianNetworkFile[] = "# The loopback network interface\n"
		"auto lo\n"
		"iface lo inet loopback\n"
		"\n"
		"auto eth0\n"
//		"allow-hotplug eth0\n"
		"iface eth0 inet static\n"
		"address %s\n"
		"netmask %s\n"
		"gateway %s\n"
		"dns-nameservers %s\n";

// char debianResolvFile[] = "search %s\nnameserver %s\n";

bool writeNetworkConfigDebian();
bool writeNetworkConfigArtilla();

//====================================================================
// Show/Log error message
//
// Input parameters: char * achp_msg    Message to show/log
//           int  inp_errno associated errno, -1 don't use
//           int  inp_writelog  if != 0, write to log, else stdout
// returns: nothing
//====================================================================
void showError(char * achp_msg, int inp_errno, int inp_writelog) {
	if (inp_writelog == 0) {
		printf("NBIPGW13: %s ", achp_msg);
		if (inp_errno != -1) {
			errno = inp_errno;
			perror(NULL);
		} else
			printf("\n");
	}
}
/**
 * function netConfigArtila::m_backup
 *
 * make a backup copy from existing file with name "ach_filename"
 * this routine must be improved, not to use system calls!!!
 *
 */
void m_backup(const char* ach_filename) {
	char buffer[64];
	sprintf(buffer, "cp %s %s%s", ach_filename, ach_filename, BACKUP_ENDING);
	system(buffer);
} // end of netConfigArtila::m_backup

/*+-------------------------------------------------------------------------+*/
/*| private functions:                                                      |*/
/*+-------------------------------------------------------------------------+*/
/**
 * function netConfigArtila::getMessage
 * 	get language depending messages
 * @param[in] int   in_mess      message keynumber
 * @return    char* 			 message itself
 */
char* getMessage(int messageNumber) {
	// intialize some variables:
	char* strMessage = "";

	switch (messageNumber) {
	case SUCCESS:
		strMessage = MESS_EN_SUCCESS;
		break;

	case FAILURE_NETWORK:
		strMessage = MESS_EN_NETWORK;
		break;

	}
	return strMessage;
} // end of netConfigArtila::getMessage

/**
 * function displayMessage
 *
 * @param[in/out]   ds_hstring*     ads_out
 * @param[in]       int 			in_mess
 */
void displayMessage(int in_mess) {

	strcpy(message, getMessage(in_mess));

} // end of netConfigArtila::m_display_conf

/**
 *
 */
bool readConfigurationArtilla() {
	// initialize some variables:
	char rch_buffer[1024]; // buffer for reading in files
	char* achr_search_word[7]; // search word list
	FILE* file = NULL; // file pointer
	int in_pos = 0; // reading position in buffer
	int in_1;
	int inputLength;
	char* ach_word = NULL; // actual found word
	int in_len_word = 0; // length of ach_word
	achr_search_word[0] = C_HOSTNAME;
	achr_search_word[1] = C_IFCONFIG;
	achr_search_word[2] = C_ROUTE;
	achr_search_word[3] = C_NAMESERVER;
	achr_search_word[4] = C_SEARCH;

	//------------------------------------------
	// get config from "/etc/rc" file:
	//------------------------------------------
	file = fopen(NET_CONF, "r");
	if (file == NULL) {
		sprintf(message, "ERROR: Couldn't read configuration file '%s'. Error No: %d", NET_CONF, errno);
		return false;
	}

	for (;;) {
		if (feof(file)) {
			break;
		}
		// init with zeros ( strlen will work then )
		memset(rch_buffer, 0, 1024);
		fgets(rch_buffer, 1024, file);
		inputLength = strlen(rch_buffer);

		// search for our first three search words in data:
		for (in_1 = 0; in_1 < 3; in_1++) {
			in_pos = lineStartsWith(rch_buffer, achr_search_word[in_1]);
			if (in_pos > -1) {
				getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
				switch (in_1) {
				case 0:
					strncpy(hostName, ach_word, in_len_word);
					break;
				case 1:
					strncpy(ipAddress, ach_word, in_len_word);
					getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
					strncpy(netMask, ach_word, in_len_word);
					break;
				case 2:
					strncpy(gateway, ach_word, in_len_word);
					break;
				}
			}
		}
	}
	fclose(file);

	//------------------------------------------
	// get config from "/etc/resolv.conf" file:
	//------------------------------------------
	file = fopen(RESOLV_CONF, "r");
	if (file == NULL) {
		return false;
	}

	for (;;) {
		if (feof(file)) {
			break;
		}
		// init with zeros ( strlen will work then )
		memset(rch_buffer, 0, 1024);
		fgets(rch_buffer, 1024, file);
		inputLength = strlen(rch_buffer);
		// search for our last two search words in data:
		for (in_1 = 3; in_1 < 5; in_1++) {
			in_pos = lineStartsWith(rch_buffer, achr_search_word[in_1]);
			if (in_pos > -1) {
				getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
				switch (in_1) {
				case 3:
					strncpy(nameServer, ach_word, in_len_word);
					break;
//				case 4:
//					strncpy(searchWord, ach_word, in_len_word);
//					break;
				}
			}
		}
	}
	fclose(file);
	return true;
} // end of readConfiguration()

/**
 *
 * function ds_net_config::m_read_conf
 * read net config from configuration files
 *
 * @return bool true = success, false otherwise
 *
 */
//------------------------------------------
// read net config from ifconfig command:
//------------------------------------------
bool readConfigurationDebian(char * interfaces) {

	// initialize some variables:
	int in_1;
	int inputLength;
	char rch_buffer[1024]; // buffer for reading in files
	char* achr_search_word[7]; // search word list
	FILE* file = NULL; // file pointer
	FILE* a_pipe = NULL; // pipe pointer
	int in_pos = 0; // reading position in buffer
	int in_found = 0; // reading position in buffer
	char* ach_word = NULL; // actual found word
	int in_len_word = 0; // length of ach_word
	achr_search_word[0] = (char*) "address"; // C_HOSTNAME;
	achr_search_word[1] = (char*) "netmask"; // C_IFCONFIG;
	achr_search_word[2] = (char*) "gateway"; // C_ROUTE;
	achr_search_word[3] = (char*) C_NAMESERVER;
	achr_search_word[4] = (char*) C_SEARCH;

	nameServer[0] = 0x0;
//	searchWord[0] = 0x0;

//	a_pipe = popen("/sbin/ifconfig eth0", "r");
//	if (a_pipe == NULL) {
//		sprintf(message, "ERROR: Couldn't read configuration file /sbin/ifconfig eth0. Error No: %d", errno);
//		return false;
//	}
//	in_pos = 0;
//	for (;;) {
//		if (feof(a_pipe)) {
//			break;
//		}
//		// init with zeros ( strlen will work then )
//		memset(rch_buffer, 0, 1024);
//		fgets(rch_buffer, 1024, a_pipe);
//		inputLength = strlen(rch_buffer);
//		// search for our search words:
//		passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \n\r\t", true);
//		in_found = lineStartsWith(&rch_buffer[in_pos], "inet addr:");
//		if (in_found > -1) {
//			in_pos += in_found;
//			getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
//			strncpy(ipAddress, ach_word, in_len_word);
//			getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
//
//			passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \n\r\t", true);
//			in_found = lineStartsWith(&rch_buffer[in_pos], "Mask:");
//			if (in_found > -1) {
//				in_pos += in_found;
//				getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
//				strncpy(netMask, ach_word, in_len_word);
//			}
//		}
//	}
//	pclose(a_pipe);

	//------------------------------------------
	// read gateway from route command:
	//------------------------------------------
//	a_pipe = popen("cat /tmp/interfaces", "r");
	a_pipe = popen(interfaces, "r");
	if (a_pipe == NULL) {
		return false;
	}
	in_pos = 0;
	for (;;) {
		if (feof(a_pipe)) {
			break;
		}
		// init with zeros ( strlen will work then )
		memset(rch_buffer, 0, 1024);
		fgets(rch_buffer, 1024, a_pipe);
		in_pos = 0;
		inputLength = strlen(rch_buffer);
		in_found = lineStartsWith(rch_buffer, "gateway");
		if (in_found > -1) {
			in_pos += in_found;
			passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \t", true);
			getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
			strncpy(gateway, ach_word, in_len_word);
			gateway[in_len_word - 1] = 0x0;
		} else {
			in_found = lineStartsWith(rch_buffer, "address");
			if (in_found > -1) {
				in_pos += in_found;
				passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \t", true);
				getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
				strncpy(ipAddress, ach_word, in_len_word);
				ipAddress[in_len_word - 1] = 0x0;
			} else {
				in_found = lineStartsWith(rch_buffer, "netmask");
				if (in_found > -1) {
					in_pos += in_found;
					passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \t", true);
					getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
					strncpy(netMask, ach_word, in_len_word);
					netMask[in_len_word - 1] = 0x0;
				} else {
					in_found = lineStartsWith(rch_buffer, "dns-nameservers");
					if (in_found > -1) {
						in_pos += in_found;
						passSigns(rch_buffer, strlen(rch_buffer), &in_pos, " \t", true);
						getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
						strncpy(nameServer, ach_word, in_len_word);
						nameServer[in_len_word - 1] = 0x0;
					}
				}
			}
		}
	}

	pclose(a_pipe);

	//------------------------------------------
	// read hostname from hostname command:
	//------------------------------------------
	a_pipe = popen("/bin/hostname", "r");
	if (a_pipe == NULL) {
		return false;
	}
	for (;;) {
		if (feof(a_pipe)) {
			break;
		}
		// init with zeros ( strlen will work then )
		memset(rch_buffer, 0, 1024);
		fgets(rch_buffer, 1024, a_pipe);

		if (strlen(rch_buffer) > 0) {
			strncpy(hostName, rch_buffer, strlen(rch_buffer));
		}
	}

	pclose(a_pipe);

	//------------------------------------------
	// get config from "/etc/resolv.conf" file:
	//------------------------------------------
//	file = fopen("/etc/resolv.conf", "r");
//	if (file == NULL) {
//		return false;
//	}
//
//	for (;;) {
//		if (feof(file)) {
//			break;
//		}
//		// init with zeros ( strlen will work then )
//		memset(rch_buffer, 0, 1024);
//		fgets(rch_buffer, 1024, file);
//		inputLength = strlen(rch_buffer);
//
//		// search for our last two search words in data:
//		for (in_1 = 3; in_1 < 5; in_1++) {
//			in_pos = lineStartsWith(rch_buffer, achr_search_word[in_1]);
//			if (in_pos > -1) {
//				getNextWord(rch_buffer, &in_pos, &ach_word, &in_len_word, inputLength);
//				switch (in_1) {
//				case 3:
//					strncpy(nameServer, ach_word, in_len_word);
//					break;
//				case 4:
//					strncpy(searchWord, ach_word, in_len_word);
//					break;
//				}
//			}
//		}
//	}
//	fclose(file);

	return true;
} // end of ds_net_config::m_read_conf()

/**
 *
 * function netConfigArtila::readConfiguration
 * read net config from configuration files
 *
 * @return bool true = success, false otherwise
 *
 */
bool readConfiguration() {

	if (deviceType == DEVICE_ARTILA) {
		return readConfigurationArtilla();
	} else {
		readConfigurationDebian("cat /etc/network/interfaces");
	}
	return false;
}

/**
 *
 * function netConfigArtila::readConfiguration
 * read net config from configuration files
 *
 * @return bool true = success, false otherwise
 *
 */bool writeNetworkConfig() {

	if (deviceType == DEVICE_ARTILA) {
		return writeNetworkConfigArtilla();
	} else {
		return writeNetworkConfigDebian();
	}
	return false;
}
/**
 *
 */bool writeNetworkConfigDebian() {
	// initialize some variables:
	int in_1;
	char buffer[1024]; // buffer for reading in files
	char* achr_search_word[5]; // search word list
	FILE* new_file = NULL; // new file pointer
	FILE* bac_file = NULL; // backup file pointer
	int in_pos = 0; // reading position in buffer

	//------------------------------------------
	// write config to "/etc/network/interfaces":
	//------------------------------------------

	// open original and backup file:
	new_file = fopen(DEBIAN_INTERFACE, "w");
	if (new_file == NULL) {
		sprintf(message, "Couldn't open file '%s'. Error: %s", DEBIAN_INTERFACE, strerror(errno));
		return false;
	}
	fprintf(new_file, debianNetworkFile, ipAddress, netMask, gateway, nameServer);
	fclose(new_file);

//	new_file = fopen(DEBIAN_RESOLV_CONF, "w");
//	if (new_file == NULL) {
//		sprintf(message, "Couldn't open file '%s' error=%d", , errno);
//		return false;
//	}
//	fprintf(new_file, debianResolvFile, searchWord, nameServer);
//	fclose(new_file);

	new_file = fopen(DEBIAN_HOSTNAME, "w");
	if (new_file == NULL) {
		sprintf(message, "Couldn't open file '%s' error=%d", DEBIAN_HOSTNAME, errno);
		return false;
	}
	fprintf(new_file, "%s\n", hostName);
	fclose(new_file);
	return true;
}

/**
 *
 * function netConfigArtila::m_write_net_conf
 * write net config to configuration files
 *
 * @return bool true = success, false otherwise
 *
 */bool writeNetworkConfigArtilla() {
	// initialize some variables:
	int in_1;
	char rch_buffer[1024]; // buffer for reading in files
	char* achr_search_word[5]; // search word list
	FILE* new_file = NULL; // new file pointer
	FILE* bac_file = NULL; // backup file pointer
	int in_pos = 0; // reading position in buffer
	achr_search_word[0] = C_HOSTNAME;
	achr_search_word[1] = C_IFCONFIG;
	achr_search_word[2] = C_ROUTE;
	achr_search_word[3] = C_NAMESERVER;
	achr_search_word[4] = C_SEARCH;

	//------------------------------------------
	// write config to "/etc/rc":
	//------------------------------------------

	// make backup of existing file:
	m_backup(NET_CONF);

	// open original and backup file:
	new_file = fopen(NET_CONF, "w");
	if (new_file == NULL) {
		sprintf(message, "Couldn't open file '%s' error=%d", NET_CONF, errno);
		return false;
	}
	bac_file = fopen(NET_CONF_BAC, "r");
	if (bac_file == NULL) {
		fclose(new_file);
		return false;
	}

	for (;;) {
		if (feof(bac_file)) {
			break;
		}
		// init with zeros
		memset(rch_buffer, 0, 1024);
		fgets(rch_buffer, 1024, bac_file);

		// search for our first three search words in data:
		for (in_1 = 0; in_1 < 3; in_1++) {
			in_pos = lineStartsWith(rch_buffer, achr_search_word[in_1]);
			if (in_pos > -1) {
				switch (in_1) {
				case 0:
					if (strlen(hostName) > 0) {
						fprintf(new_file, "%s%s\n", C_HOSTNAME, hostName);
					}
					break;
				case 1:
					if (strlen(ipAddress) > 0 && strlen(netMask) > 0) {
						fprintf(new_file, "%s%s %s\n", C_IFCONFIG, ipAddress, netMask);
					}
					break;
				case 2:
					if (strlen(gateway) > 0) {
						fprintf(new_file, "%s%s\n", C_ROUTE, gateway);
					}
					break;
				}
				break;
			}
		}
		if (in_pos < 0) {
			fprintf(new_file, "%s", rch_buffer);
		}
	}
	fclose(new_file);
	fclose(bac_file);

	//------------------------------------------
	// write config to "/etc/resolv.conf":
	//------------------------------------------

	// make backup of existing file:
	m_backup(RESOLV_CONF);

	// create new resolv file:
	char resolv[64];

	if (strlen(nameServer) > 0) {
		strcpy(resolv, C_NAMESERVER);
		strcat(resolv, nameServer);
		strcat(resolv, "\n");
	}
//	if (strlen(searchWord)) {
//		strcat(resolv, C_SEARCH);
//		strcat(resolv, searchWord);
//		strcat(resolv, "\n");
//	}

	// open original and backup file:
	new_file = fopen(RESOLV_CONF, "w");
	if (new_file == NULL) {
		return false;
	}

	// write to "/etc/resolv.conf":
	if (strlen(resolv) > 0) {
		fprintf(new_file, "%s", resolv);
	} else {
		fprintf(new_file, " ");
	}

	fclose(new_file);
	return true;
} // end of netConfigArtila::m_write_net_conf()

//===============================================================
// Read from a pipe/file, restart on EINTR
//
// Input parameters: int  inp_fd    Filedescriptor
//           char * abyp_buf    buffer
//           int  inp_buflen    size of buffer
// Returns: int - datalen, in case of error -1
//===============================================================
int readfd(int inp_fd, char * abyp_buf, int inp_buflen) {
	int inl_i; // read data length

	for (;;) {
		if (((inl_i = read(inp_fd, abyp_buf, inp_buflen)) != -1) || (errno != EINTR))
			return (inl_i);
	}
}
//===============================================================
// Write to a pipe/file, restart on EINTR
//
// Input parameters: int  inp_fd    Filedescriptor
//           char * abyp_buf    buffer
//           int  inp_datalen   data size
// Returns: int - writtenlen, in case of error -1
//===============================================================
int writefd(int inp_fd, char * abyp_buf, int inp_datalen) {
	int inl_i; // written data count

	for (;;) {
		if (((inl_i = write(inp_fd, abyp_buf, inp_datalen)) != -1) || (errno != EINTR))
			return (inl_i);
	}
}

