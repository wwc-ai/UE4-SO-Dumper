#!/bin/bash

# 设备检查脚本 - 检查设备是否满足运行要求
# Device check script - Check if device meets requirements

echo "╔══════════════════════════════════════════════════════════╗"
echo "║            UE4 SO Dumper - 设备检查工具                   ║"
echo "║          UE4 SO Dumper - Device Check Tool               ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

ERROR_COUNT=0

# 1. 检查ADB
echo "[1/7] 检查ADB工具..."
which adb > /dev/null 2>&1
if [ $? -eq 0 ]; then
    ADB_VERSION=$(adb version | head -n 1)
    echo "  ✓ ADB已安装: $ADB_VERSION"
else
    echo "  ✗ 未找到ADB工具"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 2. 检查设备连接
echo "[2/7] 检查设备连接..."
DEVICE_COUNT=$(adb devices | grep -w device | wc -l)
if [ $DEVICE_COUNT -gt 0 ]; then
    echo "  ✓ 已连接 $DEVICE_COUNT 个设备"
    adb devices | grep -w device
else
    echo "  ✗ 未检测到设备"
    echo "    请确保："
    echo "    - USB调试已开启"
    echo "    - 设备已授权"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 3. 检查设备架构
echo "[3/7] 检查设备架构..."
ARCH=$(adb shell getprop ro.product.cpu.abi 2>/dev/null)
if [ ! -z "$ARCH" ]; then
    echo "  ✓ 设备架构: $ARCH"
    
    # 检查是否有对应的编译产物
    if [ -f "libs/$ARCH/DumpUE4_SO" ]; then
        echo "  ✓ 找到对应的可执行文件"
    else
        echo "  ⚠ 未找到对应架构的可执行文件"
        echo "    需要的文件: libs/$ARCH/DumpUE4_SO"
        echo "    请先运行: ./build.sh"
    fi
else
    echo "  ✗ 无法获取设备架构"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 4. 检查Android版本
echo "[4/7] 检查Android版本..."
SDK_VERSION=$(adb shell getprop ro.build.version.sdk 2>/dev/null)
ANDROID_VERSION=$(adb shell getprop ro.build.version.release 2>/dev/null)
if [ ! -z "$SDK_VERSION" ]; then
    echo "  ✓ Android版本: $ANDROID_VERSION (API $SDK_VERSION)"
    
    if [ $SDK_VERSION -lt 21 ]; then
        echo "  ⚠ 警告: Android版本过低（需要API 21+）"
        ERROR_COUNT=$((ERROR_COUNT + 1))
    fi
else
    echo "  ✗ 无法获取Android版本"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 5. 检查Root权限
echo "[5/7] 检查Root权限..."
ROOT_CHECK=$(adb shell "su -c 'whoami'" 2>/dev/null | tr -d '\r')
if [ "$ROOT_CHECK" = "root" ]; then
    echo "  ✓ 设备已获取Root权限"
    
    # 检查su版本
    SU_VERSION=$(adb shell "su -v" 2>/dev/null | head -n 1)
    if [ ! -z "$SU_VERSION" ]; then
        echo "  ✓ Su版本: $SU_VERSION"
    fi
else
    echo "  ✗ 设备未获取Root权限"
    echo "    本工具需要Root权限才能运行"
    echo "    请先Root设备（推荐使用Magisk）"
    ERROR_COUNT=$((ERROR_COUNT + 1))
fi
echo ""

# 6. 检查SELinux状态
echo "[6/7] 检查SELinux状态..."
SELINUX_STATUS=$(adb shell "su -c 'getenforce'" 2>/dev/null | tr -d '\r')
if [ ! -z "$SELINUX_STATUS" ]; then
    echo "  ✓ SELinux状态: $SELINUX_STATUS"
    
    if [ "$SELINUX_STATUS" = "Enforcing" ]; then
        echo "  ⚠ 警告: SELinux处于强制模式"
        echo "    如果遇到权限问题，可能需要临时关闭："
        echo "    adb shell \"su -c 'setenforce 0'\""
    fi
fi
echo ""

# 7. 检查存储空间
echo "[7/7] 检查存储空间..."
STORAGE_INFO=$(adb shell "df -h /data/local/tmp" 2>/dev/null | tail -n 1)
if [ ! -z "$STORAGE_INFO" ]; then
    echo "  ✓ /data/local/tmp 存储信息:"
    echo "    $STORAGE_INFO"
    
    # 提取可用空间
    AVAILABLE=$(echo $STORAGE_INFO | awk '{print $(NF-2)}')
    echo "  ℹ 可用空间: $AVAILABLE"
else
    echo "  ⚠ 无法获取存储空间信息"
fi
echo ""

# 总结
echo "════════════════════════════════════════════════════════════"
if [ $ERROR_COUNT -eq 0 ]; then
    echo "✓ 所有检查通过！设备已准备就绪。"
    echo "✓ All checks passed! Device is ready."
    echo ""
    echo "下一步："
    echo "1. 推送可执行文件到设备："
    echo "   adb push libs/$ARCH/DumpUE4_SO /data/local/tmp/"
    echo ""
    echo "2. 查找目标进程："
    echo "   adb shell \"ps -A | grep <package_name>\""
    echo ""
    echo "3. 执行Dump："
    echo "   adb shell \"su -c '/data/local/tmp/DumpUE4_SO <PID>'\""
else
    echo "✗ 发现 $ERROR_COUNT 个问题，请先解决这些问题。"
    echo "✗ Found $ERROR_COUNT issue(s), please fix them first."
fi
echo "════════════════════════════════════════════════════════════"
