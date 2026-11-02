
###OS_TYPE_PARAM = OS_TYPE=ARM_LINUX
##OS_TYPE_PARAM = OS_TYPE=LINUX_X86
##CPUTYPE = CPUTYPE=-Dx86

##CC = CC=gcc
CC = CC=arm-linux-gcc
STRIP=arm-linux-strip /mnt/disk/webbox/bacnet/bacserv

all: buildbac buildbaccgi buildnet buildpass buildupdate buildupcgi buildindex
	@echo "ALL Ready"

clean: bacconfig/Makefile netconfig/Makefile \
	passconfig/Makefile readmeters/Makefile backdoor/Makefile
	( cd bacconfig ; make clean )
	( cd netconfig ; make clean )
	( cd passconfig ; make clean )
	( cd update ; make clean )
	( cd upcgi ; make clean )
#	( cd backdoor ; make clean )
	( cd index ; make clean )
	( cd baccgi ; make clean )


buildbac: 
	( cd bacconfig ; make $(ARCH_PARAM) $(DEBUG_PARAM))
	@echo manny

buildnet: netconfig/Makefile
	( cd netconfig ; make $(ARCH_PARAM) $(DEBUG_PARAM))
	
buildpass: passconfig/Makefile
	( cd passconfig ; make $(ARCH_PARAM) $(DEBUG_PARAM))	

buildupdate: update/Makefile
	( cd update ; make $(ARCH_PARAM) $(DEBUG_PARAM))	
	
buildbackdoor: backdoor/Makefile
	( cd backdoor ; make $(ARCH_PARAM) $(DEBUG_PARAM))
		
buildbaccgi: baccgi/Makefile
	( cd baccgi ; make $(ARCH_PARAM) $(DEBUG_PARAM))
	
buildindex: index/Makefile
	( cd index ; make $(ARCH_PARAM) $(DEBUG_PARAM))
	
buildupcgi: upcgi/Makefile
	( cd upcgi ; make $(ARCH_PARAM) $(DEBUG_PARAM))

		




