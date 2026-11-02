#ifndef MBUS_H
#define MBUS_H

#include <stdint.h>
#include <time.h>

#include "ArrayList.h"
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

#define NAMED_PIPE_READ		"/tmp/kara_pipe_read"
#define NAMED_PIPE_WRITE		"/tmp/kara_pipe_write"

#define SEM_NAME  "KARA_WEB"

#define REC_BUFFER_LENGTH 256
#define SELECT_ADDRESS 0xFD

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

#define 	SELECT_COMMAND_LENGTH 17
#define 	DEFAULT_READ_INTERVAL 5



enum VIF_TYPES {
	VIF_IGNORE = 0,
	VIF_PRIMARY = 1,
	VIF_PRIMARY_EXT = 2,
	VIF_EXT_FB = 3,
	VIF_EXT_FD = 4,
	VIF_PLAIN_TEXT = 5,
	VIF_MANUFACTURE = 6,
	VIF_FIXED = 7
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
	uint8_t addressSel;
	uint8_t addressSel1;
	uint8_t addressSel2;
	uint8_t addressSel3;
	uint8_t manufacture;
	uint8_t manufacture1;
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
	uint8_t identification [4];
	int status;
	int baudrate;
	int dataLength;
	uint8_t * data;
} ScanTrace;

typedef struct _MBus {
	SerialPort * serialPort;
	uint32_t identificationNo;
	uint8_t identificationNoBCD[4];
	uint8_t address;
	int baudrateIndex;
	uint16_t manufacture;
	uint8_t version;
	uint8_t medium;
	uint8_t status;
	uint8_t dibLength;
	uint8_t meterState;
	int readingInterval;
	int readingCount;
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
	char * plainText;
	uint8_t vifPrimary;
	uint8_t vifPrimaryExt;
	uint8_t function;

} MBusRecord;

void mBusScan(SerialPort * pSerialPort, int section);
void enableTracer(bool value);
void setMBusBaudrate(char * baudrate, bool value);
MBus * addMeter(uint8_t address, uint32_t identificationNo, bool lock);
void readMetersConfiguration();

#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif
