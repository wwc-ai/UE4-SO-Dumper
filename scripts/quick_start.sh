#!/bin/bash

# 快速开始脚本 - 一键完成所有操作
# Quick start script - One command for everything

set -e  # 遇到错误立即退出

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║          UE4 SO Dumper - 快速开始                         ║"
echo "║          UE4 SO Dumper - Quick Start                     ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${GREEN}[步骤 $1]${NC} $2"
}

print_info() {
    echo -e "${YELLOW}[信息]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

# 默认配置
PACKAGE_NAME=""
SO_NAME="libUE4.so"
ARCH="arm64-v8a"

# 解析参数
while [[ $# -gt 0 ]]; do
    case $1 in
        -p|--package)
            PACKAGE_NAME="$2"
            shift 2
            ;;
        -s|--so)
            SO_NAME="$2"
            shift 2
            ;;
        -a|--arch)
            ARCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "使用方法:"
            echo "  $0 [选项]"
            echo ""
            echo "选项:"
            echo "  -p, --package <包名>    目标应用包名（必需）"
            echo "  -s, --so <SO名称>       要Dump的SO文件名（默认: libUE4.so）"
            echo "  -a, --arch <架构>       设备架构（默认: arm64-v8a）"
            echo "  -h, --help             显示帮助信息"
            echo ""
            echo "示例:"
            echo "  $0 -p com.tencent.tmgp.pubgmhd"
            echo "  $0 -p com.game.example -s libil2cpp.so -a armeabi-v7a"
            exit 0
            ;;
        *)
            print_error "未知选项: $1"
            echo "使用 -h 或 --help 查看帮助"
            exit 1
            ;;
    esac
done

# 检查必需参数
if [ -z "$PACKAGE_NAME" ]; then
    print_error "未指定包名！"
    echo "使用方法: $0 -p <包名> [-s <SO名称>] [-a <架构>]"
    echo "使用 -h 查看完整帮助"
    exit 1
fi

echo "配置信息:"
echo "  目标包名: $PACKAGE_NAME"
echo "  SO文件: $SO_NAME"
echo "  设备架构: $ARCH"
echo ""

# 步骤1: 检查编译产物
print_step "1/7" "检查编译产物..."
cd "$PROJECT_ROOT"
if [ ! -f "libs/$ARCH/DumpUE4_SO" ]; then
    print_info "未找到编译产物，开始编译..."
    ./build.sh
    if [ $? -ne 0 ]; then
        print_error "编译失败！"
        exit 1
    fi
fi
print_info "✓ 编译产物已就绪"
echo ""

# 步骤2: 检查设备连接
print_step "2/7" "检查设备连接..."
adb devices | grep -w device > /dev/null
if [ $? -ne 0 ]; then
    print_error "未检测到设备！"
    echo "请确保："
    echo "  1. 设备已通过USB连接"
    echo "  2. 已开启USB调试"
    echo "  3. 已授权电脑调试"
    exit 1
fi
print_info "✓ 设备已连接"
echo ""

# 步骤3: 检查Root权限
print_step "3/7" "检查Root权限..."
ROOT_CHECK=$(adb shell "su -c 'whoami' 2>/dev/null" | tr -d '\r\n')
if [ "$ROOT_CHECK" != "root" ]; then
    print_error "设备未获取Root权限！"
    echo "本工具需要Root权限才能运行"
    exit 1
fi
print_info "✓ Root权限正常"
echo ""

# 步骤4: 推送可执行文件
print_step "4/7" "推送可执行文件到设备..."
adb push "libs/$ARCH/DumpUE4_SO" /data/local/tmp/ > /dev/null 2>&1
adb shell "chmod +x /data/local/tmp/DumpUE4_SO"
print_info "✓ 文件已推送"
echo ""

# 步骤5: 查找目标进程
print_step "5/7" "查找目标进程..."
PID=$(adb shell "ps -A | grep $PACKAGE_NAME" | awk '{print $2}' | head -n 1)

if [ -z "$PID" ]; then
    print_error "未找到进程！"
    echo "请确保应用 $PACKAGE_NAME 正在运行"
    echo ""
    echo "提示: 手动查找进程"
    echo "  adb shell \"ps -A | grep <关键字>\""
    exit 1
fi

print_info "✓ 找到进程 PID: $PID"
echo ""

# 步骤6: 执行Dump
print_step "6/7" "执行Dump操作..."
echo "════════════════════════════════════════════════════════════"
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO $PID $SO_NAME'"
DUMP_STATUS=$?
echo "════════════════════════════════════════════════════════════"
echo ""

if [ $DUMP_STATUS -ne 0 ]; then
    print_error "Dump失败！"
    exit 1
fi

# 步骤7: 拉取文件到本地
print_step "7/7" "拉取Dump文件到本地..."
OUTPUT_DIR="./dumped_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$OUTPUT_DIR"
adb pull /data/local/tmp/dump_output/ "$OUTPUT_DIR/" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_info "✓ 文件已保存到: $OUTPUT_DIR"
    echo ""
    echo "Dump的文件:"
    ls -lh "$OUTPUT_DIR/dump_output/"*.so 2>/dev/null
else
    print_error "拉取文件失败！"
    echo "请手动拉取："
    echo "  adb pull /data/local/tmp/dump_output/ ./"
fi
echo ""

# 完成
echo "╔══════════════════════════════════════════════════════════╗"
echo "║                  全部完成！                               ║"
echo "║                All Done!                                 ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""
echo "下一步："
echo "  1. 使用IDA Pro打开Dump的SO文件"
echo "  2. 文件位置: $OUTPUT_DIR/dump_output/"
echo ""
echo "清理设备上的文件:"
echo "  ./scripts/cleanup.sh"
echo ""
