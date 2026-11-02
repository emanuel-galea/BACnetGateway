#ifndef MBUS_H
#define MBUS_H


#include <stdint.h>
#include <time.h>

#include <termios.h>


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */


#define COMMAND_LIST_METERS '1'
#define COMMAND_START_SCAN  '2'
#define COMMAND_LIST_RECORDS '3'
#define COMMAND_EDIT_METER '4'
#define COMMAND_DELETE_METER '5'
#define COMMAND_EDIT_RECORDS '6'
#define COMMAND_STOP_SERVICE '7'
#define COMMAND_DELETE_ALL '8'
#define COMMAND_SAVE_ALL '9'
#define COMMAND_SCAN_INFO 'A'
#define COMMAND_METER_CHART 'B'
#define COMMAND_CONSUME 'C'
#define COMMAND_METER_CHART_DATA 'D'
#define COMMAND_SEND_IAM 'E'
#define COMMAND_LICENSE 'F'
#define COMMAND_ADD_METER 'G'


#define NAMED_PIPE_READ		"/tmp/kara_pipe_read"
#define NAMED_PIPE_WRITE		"/tmp/kara_pipe_write"



#define REC_BUFFER_LENGTH 256
#define SELECT_ADDRESS 0xFD

#define METER_STATUS_ACTIVE 0
#define METER_STATUS_INACTIVE 1
#define METER_STATUS_COMM_ERROR 2
#define METER_STATUS_COLLISION 3
#define METER_STATUS_SEND_ERROR 4

#define METER_STATUS_WRONG_COMMAND 5
#define METER_STATUS_WRONG_START_CHARACTER 6
#define METER_STATUS_TOO_SHORT 7
#define METER_STATUS_WRONG_LENGTH 8
#define METER_STATUS_WRONG_CHECKSUM 9
#define METER_STATUS_ERROR 10

#define METER_CONF_ADDRESS "address"
#define METER_CONF_SERIAL_NO "serialNo"
#define METER_CONF_BAUDRATE "baudrateIndex"
#define METER_CONF_RECORD_NO "recordNo"
#define METER_CONF_READ_INTERVAL "readInterval"

#define METER_CONF_MEDIUM  "medium"
#define METER_CONF_MANUFACTURE "manufacture"

#define RECORD_CONF_INSTANCE "bacnetInstance"
#define RECORD_CONF_VIF "vif"
#define RECORD_CONF_VIFPRIMARY "vifPrimary"
#define RECORD_CONF_VIFPRIMARY_EXT "vifPrimaryExt"

#define REPORT_UNDEFINED		0
#define REPORT_EDIT 		1
#define REPORT_TABLE 		2
#define REPORT_CHART 	3
#define REPORT_EXPORT  4
#define REPORT_CHART_DATA 	5

#define REPORT_TYPE_FROMTO		0
#define REPORT_TYPE_HOURLY		1
#define REPORT_TYPE_DAILY			2
#define REPORT_TYPE_MONTLY		3
#define REPORT_TYPE_YEARLY		4





enum VIF_TYPES {
	VIF_IGNORE = 0, VIF_PRIMARY = 1, VIF_PRIMARY_EXT = 2, VIF_EXT_FB = 3,
	VIF_EXT_FD = 4, VIF_PLAIN_TEXT = 5, VIF_MANUFACTURE=6
};

typedef struct _serialPort {
	int portFD;
	uint8_t mbusAddress; // current Address
	char * portName;
	struct termios portstate_orig;
	int baudrateIndex;
} SerialPort;

typedef struct _selectCommand {
	uint8_t start;
	uint8_t length;
	uint8_t length2;
	uint8_t start2;
	uint8_t cField;
	uint8_t aField;
	uint8_t ciField;
	uint8_t addressSel[4];
	uint8_t manufacture[2];
	uint8_t version;
	uint8_t medium;
	uint8_t checksum;
	uint8_t end;
} SelectCommand;

typedef struct _unitConversion {
	uint8_t mbusUnit;
	uint16_t bacnetUnit;
	uint8_t multiplier;
	uint8_t divider;
} UnitConversion;

typedef struct _scanTrace {
	uint8_t address;
	int  status;
	int  baudrate;
	int  dataLength;
	uint8_t * data;
} ScanTrace;


typedef struct _MBus {
	SerialPort * serialPort;
	uint32_t identificationNo;
	uint8_t identificationNoBCD [4];
	uint8_t address;
	int  baudrateIndex;
	uint16_t  manufacture;
	uint8_t version;
	uint8_t medium;
	uint8_t status;
	uint8_t dibLength;
	uint8_t meterState;
	int  readingInterval;
	int  readingCount;
	int recordNo;
	Arraylist mbusRecords;
} MBus;

typedef struct _MBusRecord {
	int recordNo;
	float value;
	int bacnetInstance;
	uint8_t subunitNumber;
	uint8_t viftype;
    uint8_t mbusUnitDescription;
	uint16_t storageNo;
	uint16_t tariff;
	char *  plainText;
	uint8_t vifPrimary;
	uint8_t vifPrimaryExt;
	uint8_t function;

} MBusRecord;

void mBusScan(SerialPort * pSerialPort, int section);
void enableTracer(bool value);
void setMBusBaudrate(char * baudrate, bool value);
MBus *  addMeter (uint8_t address, uint32_t identificationNo);
void readMetersConfiguration();


#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif
