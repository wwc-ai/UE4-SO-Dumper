#!/bin/bash

# UE4 SO Dumper 使用示例脚本
# 此脚本展示了如何在Android设备上使用DumpUE4_SO工具

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          UE4 SO Dumper - 使用示例                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# 配置变量
PACKAGE_NAME="com.tencent.tmgp.pubgmhd"  # 目标应用包名
BINARY_NAME="DumpUE4_SO"                  # 可执行文件名
DEVICE_PATH="/data/local/tmp"             # 设备上的存放路径
LOCAL_BINARY="libs/arm64-v8a/DumpUE4_SO"  # 本地编译产物路径

echo "[步骤1] 检查设备连接..."
adb devices | grep -w device
if [ $? -ne 0 ]; then
    echo "[错误] 未检测到Android设备，请确保："
    echo "  1. 设备已通过USB连接"
    echo "  2. 已开启USB调试"
    echo "  3. 已授权电脑调试"
    exit 1
fi
echo "[完成] 设备已连接"
echo ""

echo "[步骤2] 推送可执行文件到设备..."
adb push "$LOCAL_BINARY" "$DEVICE_PATH/" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "[错误] 推送失败，请先编译项目："
    echo "  ./build.sh"
    exit 1
fi
echo "[完成] 文件已推送"
echo ""

echo "[步骤3] 设置执行权限..."
adb shell "chmod +x $DEVICE_PATH/$BINARY_NAME"
echo "[完成] 权限已设置"
echo ""

echo "[步骤4] 查找目标进程..."
PID=$(adb shell "ps -A | grep $PACKAGE_NAME" | awk '{print $2}' | head -n 1)

if [ -z "$PID" ]; then
    echo "[错误] 未找到进程，请确保应用正在运行："
    echo "  包名: $PACKAGE_NAME"
    echo ""
    echo "您可以手动查找进程："
    echo "  adb shell ps -A | grep <包名关键字>"
    exit 1
fi

echo "[完成] 找到进程 PID: $PID"
echo ""

echo "[步骤5] 开始Dump SO文件..."
echo "════════════════════════════════════════════════════════════"
echo ""
adb shell "su -c '$DEVICE_PATH/$BINARY_NAME $PID libUE4.so'"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

echo "[步骤6] 拉取Dump文件到本地..."
mkdir -p ./dumped_files
adb pull "$DEVICE_PATH/dump_output/" "./dumped_files/" 2>/dev/null

if [ $? -eq 0 ]; then
    echo "[完成] 文件已保存到 ./dumped_files/"
    echo ""
    echo "现在您可以使用IDA Pro分析Dump出的SO文件："
    ls -lh ./dumped_files/dump_output/*.so 2>/dev/null
    echo ""
else
    echo "[提示] 如需拉取文件，请手动执行："
    echo "  adb pull $DEVICE_PATH/dump_output/ ./dumped_files/"
    echo ""
fi

echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  完成！                                   ║"
echo "╚══════════════════════════════════════════════════════════╝"
