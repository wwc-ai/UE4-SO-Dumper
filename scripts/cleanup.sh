#!/bin/bash

# 清理脚本 - 清理设备上的Dump文件和工具
# Cleanup script - Clean dump files and tools on device

echo "╔══════════════════════════════════════════════════════════╗"
echo "║            UE4 SO Dumper - 清理工具                       ║"
echo "║            UE4 SO Dumper - Cleanup Tool                  ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# 检查设备连接
echo "[检查] 检查设备连接..."
adb devices | grep -w device > /dev/null
if [ $? -ne 0 ]; then
    echo "[错误] 未检测到设备"
    echo "[Error] No device detected"
    exit 1
fi
echo "[完成] 设备已连接"
echo ""

# 清理设备上的文件
echo "[清理] 正在清理设备上的文件..."
echo "[Cleanup] Cleaning files on device..."

# 删除可执行文件
adb shell "su -c 'rm -f /data/local/tmp/DumpUE4_SO'" 2>/dev/null
echo "  ✓ 已删除可执行文件 / Removed executable"

# 删除Dump输出目录
adb shell "su -c 'rm -rf /data/local/tmp/dump_output'" 2>/dev/null
echo "  ✓ 已删除Dump文件 / Removed dump files"

# 删除临时文件
adb shell "su -c 'rm -f /data/local/tmp/*.log'" 2>/dev/null
adb shell "su -c 'rm -f /data/local/tmp/dump.tar.gz'" 2>/dev/null
echo "  ✓ 已删除临时文件 / Removed temp files"

echo ""
echo "[完成] 清理完成！"
echo "[Done] Cleanup completed!"
echo ""

# 显示剩余文件
echo "[信息] 检查剩余文件..."
echo "[Info] Checking remaining files..."
adb shell "su -c 'ls -la /data/local/tmp/ | grep -E \"(Dump|dump)\"'" 2>/dev/null || echo "  无相关文件 / No related files"

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  清理完成！                               ║"
echo "║                Cleanup Complete!                         ║"
echo "╚══════════════════════════════════════════════════════════╝"
