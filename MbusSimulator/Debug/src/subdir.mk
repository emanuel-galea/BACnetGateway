################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/ArrayList.c \
../src/MbusSimulator.c \
../src/ezxml.c 

C_DEPS += \
./src/ArrayList.d \
./src/MbusSimulator.d \
./src/ezxml.d 

OBJS += \
./src/ArrayList.o \
./src/MbusSimulator.o \
./src/ezxml.o 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c src/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -DX86 -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


clean: clean-src

clean-src:
	-$(RM) ./src/ArrayList.d ./src/ArrayList.o ./src/MbusSimulator.d ./src/MbusSimulator.o ./src/ezxml.d ./src/ezxml.o

.PHONY: clean-src

