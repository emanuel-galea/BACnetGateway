# Makefile for mini_httpd

# CONFIGURE: If you are using a SystemV-based operating system, such as
# Solaris, you will need to uncomment this definition.
#SYSV_LIBS =    -lnsl -lsocket

# CONFIGURE: Some systems don't need -lcrypt, and indeed they get an
# error if you try to link with it.  If you get an error about libcrypt
# not found, try commenting out this definition.
###CRYPT_LIB =    -lcrypt

# CONFIGURE: If you want to compile in support for https, uncomment these
# definitions.  You will need to have already built OpenSSL, available at
# http://www.openssl.org/  Make sure the SSL_TREE definition points to the
# tree with your OpenSSL installation - depending on how you installed it,
# it may be in /usr/local instead of /usr/local/ssl.
#SSL_TREE =	/usr/local/ssl
#SSL_DEFS =	-DUSE_SSL
#SSL_INC =	-I${SSL_TREE}/include
#SSL_LIBS =	-L${SSL_TREE}/lib -lssl -lcrypto

#----------------------------------------------------------
# General Directories and name definitions
#----------------------------------------------------------
##OS_TYPE = ARM5
OS_TYPE = LINUX_X86
##OS_TYPE = ARM_LINUX

DEBUG = YES
BASEDIR    = ./src
SRCDIR     = $(BASEDIR)
OBJDIRBASE = .

TARGET = mini_httpd
EXE_FNAME = mini_httpd
COPY_DIR = /mnt/disk/bin/



#----------------------------------------------------------
# Linux X86/X64, GCC, 32 Bit
#----------------------------------------------------------
ifeq ($(OS_TYPE),LINUX_X86_X64)
OS_TYPE = LINUX_X86
endif

ifeq ($(OS_TYPE),LINUX_X86)

OSDEF = Linux
EXEDIRBASE = ./output/linux

ifneq ($(DEBUG),)
DBGDEF   = -g 
MESSAGE = Building LINUX DEBUG Version ...
OBJDIR   = $(OBJDIRBASE)
EXE_NAME = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building LINUX RELEASEs Version ...
OBJDIR   = $(OBJDIRBASE)
EXE_NAME = $(EXEDIRBASE)/release/$(EXE_FNAME)
endif

CC =		gcc
CDEFS =		${SSL_DEFS} ${SSL_INC}
##CFLAGS =	-O ${CDEFS}
CFLAGS = -Wall -pthread -lcrypt
#CFLAGS =	-g ${CDEFS}
#LDFLAGS =	-g
LDFLAGS =	-Wl,-lcrypt,-lnsl,-ldl,-lpthread
LDLIBS =	${SSL_LIBS} ${SYSV_LIBS} ${CRYPT_LIB}

endif

#----------------------------------------------------------
# Arm Linux, arm_linux_gcc, 32 Bit
#----------------------------------------------------------
ifeq ($(OS_TYPE),ARM_LINUX)

OSDEF = Arm_Linux

EXEDIRBASE = ./output/arm_linux
COPY_NAME  = $(COPY_DIR)$(EXE_FNAME)

ifeq ($(DEBUG),YES)
MESSAGE = Building ARM-LINUX DEBUG Version ...
DBGDEF     = -g
OBJDIR     = $(OBJDIRBASE)/debug
EXE_NAME   = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building ARM-LINUX RELEASE Version ...
OBJDIR     = $(OBJDIRBASE)/release
EXE_NAME   = $(EXEDIRBASE)/release/$(EXE_FNAME)
DBGDEF=-O2 -DNDEBUG
endif

CC = arm-linux-gcc
CFLAGS     = -Wall -pthread
LDFLAGS =	-Wl,-lcrypt,-lnsl,-ldl,-lpthread
###LINKSTDCPP = $(HOME)/arm_gw22_cc/lib32/libstdc++.a 
OSINC      = -I/usr/local/arm-linux/include -I/usr/include -I/usr/local/include
CDEFS      = -DHL_LINUX_ARM -DHL_UNIX
SYSLIBS    = -lnsl -ldl -lpthread -lcrypt
LNKFLAGS   = -mt -pthread

endif

#----------------------------------------------------------
# Arm5 
#----------------------------------------------------------
ifeq ($(OS_TYPE),ARM5)

OSDEF = Arm5

EXEDIRBASE = ./output/arm5
COPY_NAME  = $(COPY_DIR)$(EXE_FNAME)

ifneq ($(DEBUG),)
MESSAGE = Building ARM5 DEBUG Version ...
DBGDEF     = -g
OBJDIR     = $(OBJDIRBASE)/debug
EXE_NAME   = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building ARM5 RELEASE Version ...
OBJDIR     = $(OBJDIRBASE)/release
EXE_NAME   = $(EXEDIRBASE)/release/$(EXE_FNAME)
endif

CC = arm-none-linux-gnueabi-gcc
CFLAGS     = -Wall -pthread
LDFLAGS =	 -Wl,-lcrypt,-lnsl,-ldl,-lpthread
###LINKSTDCPP = $(HOME)/arm_gw22_cc/lib32/libstdc++.a 
OSINC      = -I/usr/local/arm-none-linux-gnueabi/include -I/usr/include -I/usr/local/include
CDEFS      = -DHL_LINUX_ARM -DHL_UNIX
#SSL_LIBS =	-L${SSL_TREE}/lib -lssl -lcrypto
SYSLIBS    = -L/usr/local/arm-none-linux-gnueabi/arm-none-linux-gnueabi/lib -lnsl -ldl -lpthread -lcrypt
LNKFLAGS   = -mt -pthread

endif

ifeq ($(OSDEF),)
$(error OS-System not supported, STOP)
endif


all:	mini_httpd htpasswd
ifeq ($(OS_TYPE),ARM_LINUX)
	@echo "Copy executable to $(COPY_NAME)"
	@cp $(EXE_NAME) $(COPY_NAME)
	@arm-linux-strip $(COPY_NAME)
	@cp ./htpasswd $(COPY_DIR)htpasswd
	@cp $(EXE_NAME) $(COPY_DIR)	
endif

ifeq ($(OS_TYPE),ARM5)
	@echo "Copy executable to $(COPY_NAME)"
	@cp $(EXE_NAME) $(COPY_NAME)
	@arm-none-linux-gnueabi-strip $(COPY_NAME)
	@cp ./htpasswd $(COPY_DIR)htpasswd	
endif

mini_httpd:	mini_httpd.o match.o tdate_parse.o
	${CC} ${CFLAGS} ${DBGDEF} ${LDFLAGS} mini_httpd.o match.o tdate_parse.o ${LDLIBS} -o $(EXE_NAME)


mini_httpd.o:	mini_httpd.c version.h port.h match.h tdate_parse.h mime_encodings.h mime_types.h
	${CC} ${CFLAGS} ${DBGDEF} -c mini_httpd.c

match.o:	match.c match.h
	${CC} ${CFLAGS} ${DBGDEF} -c match.c

tdate_parse.o:	tdate_parse.c tdate_parse.h
	${CC} ${CFLAGS} ${DBGDEF} -c tdate_parse.c

mime_encodings.h: mime_encodings.txt
	rm -f mime_encodings.h
	sed < mime_encodings.txt > mime_encodings.h \
	  -e 's/#.*//' -e 's/[ 	]*$$//' -e '/^$$/d' \
	  -e 's/[ 	][ 	]*/", 0, "/' -e 's/^/{ "/' -e 's/$$/", 0 },/'

mime_types.h: mime_types.txt
	rm -f mime_types.h
	sed < mime_types.txt > mime_types.h \
	  -e 's/#.*//' -e 's/[ 	]*$$//' -e '/^$$/d' \
	  -e 's/[ 	][ 	]*/", 0, "/' -e 's/^/{ "/' -e 's/$$/", 0 },/'


htpasswd:	htpasswd.o
	${CC} ${CFLAGS} ${DBGDEF} ${LDFLAGS} htpasswd.o ${LDLIBS} -o htpasswd

htpasswd.o:	htpasswd.c
	${CC} ${CFLAGS} ${DBGDEF} -c htpasswd.c


cert:		mini_httpd.pem
mini_httpd.pem:	mini_httpd.cnf
	openssl req -new -x509 -days 365 -nodes -config mini_httpd.cnf -out mini_httpd.pem -keyout mini_httpd.pem
	openssl x509 -subject -dates -fingerprint -noout -in mini_httpd.pem
	chmod 600 mini_httpd.pem


install:	all
	rm -f ${BINDIR}/mini_httpd ${BINDIR}/htpasswd
	-mkdir -p ${BINDIR}
	cp mini_httpd htpasswd ${BINDIR}
	rm -f ${MANDIR}/man8/mini_httpd.8 ${MANDIR}/man1/htpasswd.1
	-mkdir -p ${MANDIR}/man8
	cp mini_httpd.8 ${MANDIR}/man8
	-mkdir -p ${MANDIR}/man1
	cp htpasswd.1 ${MANDIR}/man1

clean:
	rm -f $(EXE_NAME) mime_encodings.h mime_types.h htpasswd mini_httpd.rnd *.o core core.* *.core

tar:
	@name=`sed -n -e '/SERVER_SOFTWARE/!d' -e 's,.*mini_httpd/,mini_httpd-,' -e 's, .*,,p' version.h` ; \
	  rm -rf $$name ; \
	  mkdir $$name ; \
	  tar cf - `cat FILES` | ( cd $$name ; tar xfBp - ) ; \
	  chmod 644 $$name/Makefile $$name/mime_encodings.txt $$name/mime_types.txt ; \
	  chmod 755 $$name/contrib $$name/contrib/redhat-rpm ; \
	  tar cf $$name.tar $$name ; \
	  rm -rf $$name ; \
	  gzip $$name.tar
