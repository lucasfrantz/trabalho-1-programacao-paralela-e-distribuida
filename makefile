CC=gcc

CLANG=clang-13

OPEN_MP=-fopenmp
OPEN_MP_CLANG=-fopenmp=libomp
N_THREAD=3

COMPILE_OPEN_MP=-DOPEN_MP
COMPILE_PTHREAD=-DPTHREAD

PERMISSIVE=-fpermissive

C_FLAGS=-I/usr/lib/gcc/x86_64-linux-gnu/11/include/omp.h

APP_ROOT = .
CMSIS_DIR = ../CMSIS_5
DSP_DIR = $(CMSIS_DIR)/CMSIS/DSP
NN_DIR = $(CMSIS_DIR)/CMSIS/NN
CORE_DIR = $(CMSIS_DIR)/CMSIS/Core/Include

APPINCLUDE:=-I$(APP_ROOT) \
-I$(APP_ROOT)/Include \
-I$(CORE_DIR) \
-I$(DSP_DIR)/Include \
-I$(NN_DIR)/Include \

#FILES:= $(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast.c \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c \
$(NN_DIR)/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c \
$(NN_DIR)/Source/SoftmaxFunctions/arm_softmax_q7.c \
$(NN_DIR)/Source/PoolingFunctions/arm_pool_q7_HWC.c \


FILES:= $(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \
$(APP_ROOT)/arm_convolve_HWC_q7_fast.cpp \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c \
$(NN_DIR)/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c \
$(NN_DIR)/Source/SoftmaxFunctions/arm_softmax_q7.c \
$(NN_DIR)/Source/PoolingFunctions/arm_pool_q7_HWC.c \

FILES_PTHREAD:= $(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \
$(APP_ROOT)/arm_convolve_HWC_q7_fast_pthread.cpp \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c \
$(NN_DIR)/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c \
$(NN_DIR)/Source/SoftmaxFunctions/arm_softmax_q7.c \
$(NN_DIR)/Source/PoolingFunctions/arm_pool_q7_HWC.c \

#-I$(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \

#APPINCLUDE:=-I$(CORE_DIR) \
-I$(DSP_DIR)/Include \
-I$(NN_DIR)/Include \

sequencial:
	$(CC) cifar10.c -D NUM_THREADS=$(N_THREAD) -lm $(OPEN_MP) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_1_gcc:
	$(CC) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=1 -lm $(OPEN_MP) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_2_gcc:
	$(CC) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=2 -lm $(OPEN_MP) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_3_gcc:
	$(CC) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=3 -lm $(OPEN_MP) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_4_gcc:
	$(CC) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=4 -lm $(OPEN_MP) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_1_clang:
	$(CLANG) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=1 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_2_clang:
	$(CLANG) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=2 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_3_clang:
	$(CLANG) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=3 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES) $(APPINCLUDE) -o sequencial.run

open_mp_4_clang:
	$(CLANG) cifar10.c $(COMPILE_OPEN_MP) -D NUM_THREADS=4 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES) $(APPINCLUDE) -o sequencial.run

pthread_1_gcc:
	$(CC) cifar10.c $(COMPILE_PTHREAD) $(PERMISSIVE) -D NUM_THREADS=1 -lm $(OPEN_MP) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_2_gcc:
	$(CC) cifar10.c $(COMPILE_PTHREAD) $(PERMISSIVE) -D NUM_THREADS=2 -lm $(OPEN_MP) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_3_gcc:
	$(CC) cifar10.c $(COMPILE_PTHREAD) $(PERMISSIVE) -D NUM_THREADS=3 -lm $(OPEN_MP) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_4_gcc:
	$(CC) cifar10.c $(COMPILE_PTHREAD) $(PERMISSIVE) -D NUM_THREADS=4 -lm $(OPEN_MP) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_1_clang:
	$(CLANG) cifar10.c $(COMPILE_PTHREAD) -D NUM_THREADS=1 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_2_clang:
	$(CLANG) cifar10.c $(COMPILE_PTHREAD) -D NUM_THREADS=2 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_3_clang:
	$(CLANG) cifar10.c $(COMPILE_PTHREAD) -D NUM_THREADS=3 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run

pthread_4_clang:
	$(CLANG) cifar10.c $(COMPILE_PTHREAD) -D NUM_THREADS=4 -lm $(C_FLAGS) $(OPEN_MP) $(OPEN_MP_CLANG) $(FILES_PTHREAD) $(APPINCLUDE) -o sequencial.run
