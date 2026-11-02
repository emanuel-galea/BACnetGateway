################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/ArrayList.c \
../src/MbusSimulator.c \
../src/ezxml.c 

OBJS += \
./src/ArrayList.o \
./src/MbusSimulator.o \
./src/ezxml.o 

C_DEPS += \
./src/ArrayList.d \
./src/MbusSimulator.d \
./src/ezxml.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	arm-linux-gcc -DARTILA -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


