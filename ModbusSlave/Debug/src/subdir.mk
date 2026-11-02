################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
O_SRCS += \
../src/commun.o \
../src/mbdialer.o \
../src/mbm.o \
../src/mbs.o 

C_SRCS += \
../src/commun.c \
../src/mbs.c \
../src/slave-example.c 

OBJS += \
./src/commun.o \
./src/mbs.o \
./src/slave-example.o 

C_DEPS += \
./src/commun.d \
./src/mbs.d \
./src/slave-example.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c
	@echo 'Building file: $<'
	@echo 'Invoking: GCC C Compiler'
	gcc -I"/home/emanuel/workspace/ModbusSlave/include" -O0 -g3 -Wall -c -fmessage-length=0 -MMD -MP -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o"$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


