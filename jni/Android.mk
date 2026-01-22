LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := DumpUE4_SO
LOCAL_SRC_FILES := main.cpp
LOCAL_CFLAGS := -Wall -O2 -fPIE
LOCAL_LDFLAGS := -fPIE -pie
LOCAL_LDLIBS := -llog

include $(BUILD_EXECUTABLE)
