CC = g++

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

FILES:= $(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_fast.c \
$(NN_DIR)/Source/ConvolutionFunctions/arm_convolve_HWC_q7_RGB.c \
$(NN_DIR)/Source/FullyConnectedFunctions/arm_fully_connected_q7_opt.c \
$(NN_DIR)/Source/SoftmaxFunctions/arm_softmax_q7.c \
$(NN_DIR)/Source/PoolingFunctions/arm_pool_q7_HWC.c \

#-I$(NN_DIR)/Source/ActivationFunctions/arm_relu_q7.c \

#APPINCLUDE:=-I$(CORE_DIR) \
-I$(DSP_DIR)/Include \
-I$(NN_DIR)/Include \

sequencial:
	$(CC) cifar10.cpp $(FILES) $(APPINCLUDE) -o sequencial.run
# cd .. && ls