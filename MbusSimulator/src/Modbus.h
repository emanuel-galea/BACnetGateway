#ifndef MBUS_H
#define MBUS_H

#include <stdint.h>
#include <time.h>

#include "ArrayList.h"
#include <termios.h>


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

/* Internal using */
#define MSG_LENGTH_UNDEFINED -1


/* Function codes */
#define FC_READ_COIL_STATUS          0x01  /* discretes inputs */
#define FC_READ_INPUT_STATUS         0x02  /* discretes outputs */
#define FC_READ_HOLDING_REGISTERS    0x03
#define FC_READ_INPUT_REGISTERS      0x04
#define FC_WRITE_SINGLE_COIL         0x05
#define FC_PRESET_SINGLE_REGISTER    0x06
#define FC_READ_EXCEPTION_STATUS     0x07
#define FC_FORCE_MULTIPLE_COILS      0x0F
#define FC_PRESET_MULTIPLE_REGISTERS 0x10
#define FC_REPORT_SLAVE_ID           0x11
#define FC_READ_DEVICE_IDENTIFICATION   0x2B



#define EXCEPTION_RESPONSE_LENGTH_RTU  5



#define MODBUS_MAX_OBJECT_ID 3

#define REC_BUFFER_LENGTH 256
#define SELECT_ADDRESS 0xFD


#define 	SELECT_COMMAND_LENGTH 17
#define 	DEFAULT_READ_INTERVAL 5

#define MAX_BUF_SIZE 2048

/* Local ERROR*/
#define INVALID_DATA            -0x10
#define INVALID_CRC             -0x3
#define INVALID_EXCEPTION_CODE  -0x12

#define SELECT_TIMEOUT          -0x6
#define SELECT_FAILURE          -0x4
#define SEND_FAILURE          -1
#define RECEIVE_FAILURE          -2
#define CONNECTION_CLOSED       -0x16
#define MB_EXCEPTION             -0x5

#define MAX_PDU_LENGTH            253
#define MAX_ADU_LENGTH_RTU        256
#define MAX_ADU_LENGTH_TCP        260

#define MIN_QUERY_LENGTH           12
#define MAX_MESSAGE_LENGTH        260

/* Slave index */
#define HEADER_LENGTH_RTU           1
#define PRESET_QUERY_LENGTH_RTU     6
#define PRESET_RESPONSE_LENGTH_RTU  2
#define HEADER_LENGTH_TCP           7
#define PRESET_QUERY_LENGTH_TCP    12
#define PRESET_RESPONSE_LENGTH_TCP  8

#define CHECKSUM_LENGTH_RTU         2
#define CHECKSUM_LENGTH_TCP         0

/* Time out between trames in microsecond */
#define TIME_OUT_BEGIN_OF_TRAME 500000
#define TIME_OUT_END_OF_TRAME   500000

typedef enum {
		SORTBY_NAME , SORTBY_ADDRESS ,  SORTBY_BAUDRATE , SORTBY_STATUS, SORTBY_DEVICE,
		SORTBY_TYPE, SORTBY_CONNECTION
} SORTBY;

typedef enum  {
MODBUS_OBJECT_ID_VENDOR=0, MODBUS_OBJECT_ID_PRODCUT=1, MODBUS_OBJECT_ID_REVISION= 2
} MODBUS_OBJEXT_ID;

#define 	MODBUS_CONF_NAME  "name"
#define MODBUS_CONF_ADDRESS  "address"
#define 	MODBUS_CONF_BAUD  "baud"
#define MODBUS_CONF_PARITY  "parity"
#define MODBUS_CONF_CONN  "connType"
#define MODBUS_CONF_PORT  "port"
#define MODBUS_CONF_SERIALPORT  "serialPort"
#define MODBUS_CONF_READINTERVAL  "readInterval"
#define MODBUS_CONF_BACINST_READ  "bacInstRead"
#define MODBUS_CONF_BACINST_WRITE  "bacInstWrite"
#define MODBUS_CONF_MULTIPLIER "multiplier"
#define MODBUS_CONF_POINT "point"
#define MODBUS_CONF_UNIT "unit"
#define MODBUS_DEFAULT_PORT 502
#define 	MODBUS_DEFAULT_INTERVAL  60
#define 	MODBUS_DEFAULT_BAUD 5

#define 	MODBUS_CONF_OBJECT_TYPE  "type"


typedef enum {
		COMMAND_LIST_DEVICES = 0,
		COMMAND_LIST_OBJECTS= 1,
		COMMAND_EDIT_DEVICE = 2,
		COMMAND_EDIT_OBJECT= 3,
		COMMAND_ADD_DEVICE= 4,
		COMMAND_ADD_OBJECT= 5,
		COMMAND_DELETE_DEVICE= 6,
		COMMAND_DELETE_OBJECT= 7,
		COMMAND_READ_ALL= 8,
} COMMANDS;


typedef enum {
	CONNECTION_TCP = 0,
	CONNECTION_SERIAL = 1,
} CONNECTION_TYPE;

typedef enum {
	PARITY_NONE = 0,
	PARITY_ODD = 1,
	PARITY_EVEN
} PARITY;

typedef enum {
	MODBUS_STATUS_OK,
	MODBUS_STATUS_INACTIVE,
	MODBUS_COMM_ERROR,
} MODBUS_SATUS;

typedef enum {
	PROTOCOL_TCP = 0,
	PROTOCAOL_ASCII = 1,
} PROTOCOL;

typedef enum {
	OBJECT_TYPE_COILS = 0,
	OBJECT_TYPE_DISCRETES_INPUT = 1,
	OBJECT_TYPE_INPUT_REGISTER = 2,
	OBJECT_TYPE_HOLDING_REGISTER = 3,
	OBJECT_TYPE_INPUT_FLOAT = 4,
	OBJECT_TYPE_HOLDING_FLOAT = 5,
} OBJECT_TYPE;

typedef struct _scanTrace {
	char address [32];
	int status;
	int dataLength;
	uint8_t * data;
} ScanTrace;

//
//typedef struct _serialPort {
//	int fd;
//	uint8_t serialAddress; // current Address
//	char * portName;
//	struct termios portstate_orig;
//	int baudrateIndex;
//	int parity;
//} SerialPort;

typedef struct _ModbusDevice {
	int slaveAddress;
	struct termios portstate_orig;
	int baudrateIndex;
	int parity;
	unsigned serialPortIndex;
	int fd;
	char * name;
	int connectionType;
	uint8_t transMode;
	int port;
	char * address;
	int debug;
	uint8_t status;
	char * ids [MODBUS_MAX_OBJECT_ID];
//	int readingInterval;
//	int readingCount;
	Arraylist modbusObjects;
	time_t connectedSince;

} ModbusDevice;

typedef struct _ModbusObject {
	ModbusDevice * parent;
	char * name;
	int objectType;
	int address;
	int bacnetInstanceRead;
	int bacnetInstanceWrite;
	int point;
	float multiplier;
	int unit;
	int status;
	int readingInterval;
	int readingCount;
	union {
			float real;
			uint16_t unsignedInt;
			bool Boolean;
		};
} ModbusObject;


void setModbusBaudrate(char * baudrate, bool value);
char * checkDeviceSettings(ModbusDevice * pModbusDevice, int deviceNo);
char * checkObjectSettings(ModbusObject * pModbusObject,  int objectNo, char * address);

ModbusDevice * getEmptyDevice ();
ModbusObject * getEmptyObject();

static void freeModbusDevice(ModbusDevice * pModbusDevice);
void addModbusBacnet(ModbusObject * pModbusObject);
static void freeModbusObject(ModbusObject * pModbusObject);



#ifdef __cplusplus
}
#endif /* __cplusplus */
#endif
