#*******************************************************************
#
# Make file for generating the REad Meters CGI Executable
#       -- 32 Bit version --
#
# The following MACROS must be defined when called:
# -------------------------------------------------
# ARCH  - Operating system used
# HOME     - User Home
#
# The following Macros will affect the build when defined:
# --------------------------------------------------------
# DEBUG     - Generate a DEBUG version of the programs
#
#*******************************************************************


#----------------------------------------------------------
# undefine predefined defaults and suffixes
#----------------------------------------------------------
.DEFAULT:
.SUFFIXES:
.SUFFIXES: .c .o

#----------------------------------------------------------
# General Directories and name definitions
#----------------------------------------------------------
ARCH = LINUX_X86
##ARCH=ARM_LINUX
##ARCH=ARM5
DEBUG=YES

include ../props.mk

EXE_FNAME = update
BASEDIR    = ./src
SRCDIR     = $(BASEDIR)
COMMON_SRCDIR=../common/src 
COPY_NAME  = $(COPY_DIR)/$(EXE_FNAME)
OBJDIR = .


# use only for arm build:
LINKSTDCPP = 


#----------------------------------------------------------
# Compiler settings system independent
#----------------------------------------------------------
USRINC  = -I.

#==========================================================
# Compiler/Linker settings, system dependent
#==========================================================

ifeq ($(ARCH),)
$(error OS-System not defined, STOP)
endif

OSDEF  =

ifeq ($(DEBUG),YES)
DBGDEF   = -g -DDEBUG
else
DBGDEF=-O2 -DNDEBUG
endif


#----------------------------------------------------------
# Linux X86/X64, GCC, 32 Bit
#----------------------------------------------------------
ifeq ($(ARCH),LINUX_X86_X64)
ARCH = LINUX_X86
endif

ifeq ($(ARCH),LINUX_X86)

OSDEF = Linux


EXEDIRBASE = ../output/linux


ifneq ($(DEBUG),)
MESSAGE = Building LINUX DEBUG Version ...
EXE_NAME = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building LINUX RELEASE Version ...
EXE_NAME = $(EXEDIRBASE)/release/$(EXE_FNAME)
endif

OSINC    = -I/usr/local/include -I/usr/include
CDEFS    = -DHL_UNIX -D$(ARCH)
CPPFLAGS = $(INCLUDES) -c -pthread -fsigned-char -fPIC -D$(ARCH)
CPP      = gcc $(CPPFLAGS) $(DBGDEF) $(CDEFS) $(USRINC) $(OSINC)
SYSLIBS  = -lHtmlParser
LINK   = gcc 
LFLAGS = -Wl,-lc,-lgcc,-L$(HTMLPARSER_LIB_DIR),$(SYSLIBS) 

endif

#----------------------------------------------------------
# Arm Linux, arm_linux_gcc, 32 Bit
#----------------------------------------------------------
ifeq ($(ARCH),ARM_LINUX)

OSDEF = Arm_Linux

EXEDIRBASE = ../output/arm_linux

ifneq ($(DEBUG),)
MESSAGE = Building ARM-LINUX DEBUG Version ...
EXE_NAME   = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building ARM-LINUX RELEASE Version ...
EXE_NAME   = $(EXEDIRBASE)/release/$(EXE_FNAME)
endif

LINKSTDCPPXXX = $(HOME)/arm_gw22_cc/lib32/libstdc++.a 
OSINCXXXX      = -I/usr/local/arm-linux/include -I/usr/include -I/usr/local/include
CDEFSXXX      = -DHL_LINUX_ARM -DHL_UNIX
CPPFLAGS   = $(INCLUDES) -c -pthread -fsigned-char -fPIC -D$(ARCH)
CPP        = arm-linux-gcc -DARM_LINUX=1 $(CPPFLAGS) $(DBGDEF) $(CDEFS) $(USRINC) $(OSINC)
SYSLIBS    = -lHtmlParser
LNKFLAGS   = -mt -pthread
LINK       = arm-linux-gcc
LFLAGS = -Wl,-lc,-lgcc,-L$(HTMLPARSER_LIB_DIR),$(SYSLIBS) 

endif



#----------------------------------------------------------
# Arm5 Sheeva Plug
#----------------------------------------------------------
ifeq ($(ARCH),ARM5)

OSDEF = Arm5

EXEDIRBASE = ../output/arm5

ifneq ($(DEBUG),)
MESSAGE = Building Sheeva DEBUG Version ...
EXE_NAME   = $(EXEDIRBASE)/debug/$(EXE_FNAME)
else
MESSAGE = Building ARM-LINUX RELEASE Version ...
EXE_NAME   = $(EXEDIRBASE)/release/$(EXE_FNAME)
endif

OSINCXXXX      = -I/usr/local/arm-linux/include -I/usr/include -I/usr/local/include
CDEFS     = -DHL_LINUX_ARM -DHL_UNIX -D$(ARCH)
CPPFLAGS   = $(INCLUDES) -c -pthread -fsigned-char -fPIC -D$(ARCH)
CPP        = arm-none-linux-gnueabi-gcc $(CPPFLAGS) $(DBGDEF) $(CDEFS) $(USRINC) $(OSINC)
SYSLIBS    = -lHtmlParser
LNKFLAGS   = -mt -pthread
LINK       = arm-none-linux-gnueabi-gcc 
LFLAGS = -Wl,-lc,-lgcc,-L$(HTMLPARSER_LIB_DIR),$(SYSLIBS) 

endif




ifeq ($(OSDEF),)
$(error OS-System not supported, STOP)
endif

#==========================================================
#
# Main dependency rule
#
#==========================================================
all: clean $(EXE_NAME)

#--------------------------------------------------------
# Names of object modules for building the executable
#--------------------------------------------------------
EXE_OBJNAMES= $(OBJDIR)/update.o

#----------------------------------------------------------------------
# Build rule for the WebServer Library
#----------------------------------------------------------------------
$(EXE_NAME): $(EXE_OBJNAMES)
	@echo $(MESSAGE)
	@echo LINKER COMMNAD $(LINK) $(EXE_OBJNAMES)  $(LFLAGS) -o $(EXE_NAME) 
	@echo "Linking 32 bit CGI Executable $(EXE_NAME)"
	@$(LINK) $(EXE_OBJNAMES)  $(LFLAGS) -o $(EXE_NAME) 
ifneq ($(COPY_NAME),)
	@echo "Copy executable to $(COPY_NAME)"
	@cp $(EXE_NAME) $(COPY_NAME)
ifeq ($(ARCH),ARM_LINUX)
	arm-linux-strip $(COPY_NAME)
endif
ifeq ($(ARCH),ARM5)
	arm-none-linux-gnueabi-strip $(COPY_NAME)
endif
	
	
endif
	@echo


#----------------------------------------------------------------------
# Build rules for the object modules
#----------------------------------------------------------------------

# Files from 'src' directory

# string class
SUBDIR=
NAME=parser
$(OBJDIR)/$(NAME).o: ../common/src/$(NAME).c
	$(COMPILE)
	
SUBDIR=
NAME=ezxml
$(OBJDIR)/$(NAME).o: ../common/src/$(SUBDIR)/$(NAME).c
	$(COMPILE)	


# main interface
NAME=update
$(OBJDIR)/$(NAME).o: $(SRCDIR)/$(SUBDIR)/$(NAME).c
	$(COMPILE)


#----------------------------------------------------------------------
# General Build Commands for the object modules
#----------------------------------------------------------------------
define COMPILE
@echo "compiling $(?F)"
@$(CPP) -o $@ $?
endef



#===================================================================
# Assure a clean build
# - delete object modules
# - delete executables
#===================================================================

.PHONY: clean
clean:
	@echo
	@echo "Cleaning CGI Executable 32 Bit project"
	@echo "    Delete object modules"
	@rm -f $(EXE_OBJNAMES)
	@echo "    Delete executable $(EXE_NAME)"
	@rm -f $(EXE_NAME)
ifneq ($(COPY_NAME),)
	@echo "    Delete executable copy $(COPY_NAME)"
	@rm -f $(COPY_NAME)
endif
	@echo "Done."
	@echo
