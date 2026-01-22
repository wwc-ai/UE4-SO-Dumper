# 详细使用指南 / Detailed Usage Guide

## 📖 目录 / Table of Contents

1. [基本使用](#基本使用--basic-usage)
2. [高级用法](#高级用法--advanced-usage)
3. [实战案例](#实战案例--real-world-examples)
4. [技巧和最佳实践](#技巧和最佳实践--tips--best-practices)
5. [故障排除](#故障排除--troubleshooting)

## 基本使用 / Basic Usage

### 完整工作流程 / Complete Workflow

```bash
# 1. 连接设备并检查
adb devices

# 2. 查找目标应用进程
adb shell "ps -A | grep <package_name>"
# 例如: adb shell "ps -A | grep com.tencent.tmgp.pubgmhd"

# 3. 记下PID（第二列的数字）
# 假设PID是: 12345

# 4. 进入设备Shell
adb shell

# 5. 获取root权限
su

# 6. 执行Dump
cd /data/local/tmp
./DumpUE4_SO 12345

# 7. 退出Shell
exit
exit

# 8. 拉取文件到本地
adb pull /data/local/tmp/dump_output/ ./
```

### 命令参数说明 / Command Parameters

```
./DumpUE4_SO <PID> [SO_NAME]

参数 / Parameters:
  PID       必需，目标进程的进程ID
            Required, target process ID
            
  SO_NAME   可选，要Dump的SO文件名
            Optional, SO filename to dump
            默认值 / Default: libUE4.so
```

### 示例命令 / Example Commands

```bash
# 示例1: Dump默认的libUE4.so
./DumpUE4_SO 12345

# 示例2: 明确指定libUE4.so
./DumpUE4_SO 12345 libUE4.so

# 示例3: Dump libil2cpp.so（Unity游戏）
./DumpUE4_SO 12345 libil2cpp.so

# 示例4: Dump其他自定义SO
./DumpUE4_SO 12345 libcocos2dcpp.so
./DumpUE4_SO 12345 libgame.so
```

## 高级用法 / Advanced Usage

### 1. 批量Dump多个SO

创建脚本 `batch_dump.sh`:

```bash
#!/bin/bash

PID=$1
SO_FILES=("libUE4.so" "libil2cpp.so" "libunity.so")

for SO in "${SO_FILES[@]}"; do
    echo "正在Dump: $SO"
    ./DumpUE4_SO $PID $SO
    echo "完成: $SO"
    echo "---"
done
```

使用方法：
```bash
chmod +x batch_dump.sh
./batch_dump.sh 12345
```

### 2. 自动查找并Dump

创建脚本 `auto_dump.sh`:

```bash
#!/bin/bash

PACKAGE_NAME=$1

# 查找PID
PID=$(ps -A | grep $PACKAGE_NAME | awk '{print $2}' | head -n 1)

if [ -z "$PID" ]; then
    echo "未找到进程: $PACKAGE_NAME"
    exit 1
fi

echo "找到进程PID: $PID"
./DumpUE4_SO $PID libUE4.so
```

使用方法：
```bash
adb shell "su -c 'cd /data/local/tmp && ./auto_dump.sh com.your.package'"
```

### 3. 定时Dump（监控SO变化）

```bash
#!/bin/bash

PID=$1
INTERVAL=60  # 每60秒Dump一次

while true; do
    echo "执行Dump - $(date)"
    ./DumpUE4_SO $PID libUE4.so
    sleep $INTERVAL
done
```

### 4. Dump后自动分析

```bash
#!/bin/bash

PID=$1
SO_NAME=$2

# 执行Dump
./DumpUE4_SO $PID $SO_NAME

# 查找最新的Dump文件
LATEST_DUMP=$(ls -t dump_output/*.so | head -n 1)

# 使用readelf分析
echo "=== ELF Header ==="
readelf -h $LATEST_DUMP

echo "=== Program Headers ==="
readelf -l $LATEST_DUMP

echo "=== Section Headers ==="
readelf -S $LATEST_DUMP

echo "=== Symbols ==="
readelf -s $LATEST_DUMP | head -n 50
```

## 实战案例 / Real-World Examples

### 案例1: Dump PUBG Mobile的UE4 SO

```bash
# 1. 启动游戏并等待完全加载

# 2. 查找进程
adb shell "ps -A | grep pubgmhd"
# 输出: u0_a123 12345 ... com.tencent.tmgp.pubgmhd

# 3. 执行Dump
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO 12345 libUE4.so'"

# 4. 拉取文件
adb pull /data/local/tmp/dump_output/ ./PUBG_dump/

# 5. 在IDA中加载
# File > Open > 选择dump出的SO文件
# IDA会自动识别ARM64架构并分析
```

### 案例2: 对比不同版本的SO

```bash
# Dump旧版本游戏的SO
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO 12345'"
adb pull /data/local/tmp/dump_output/*.so ./version_old/

# 更新游戏到新版本

# Dump新版本游戏的SO
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO 67890'"
adb pull /data/local/tmp/dump_output/*.so ./version_new/

# 使用diff或专业工具比较差异
diff <(readelf -s version_old/*.so) <(readelf -s version_new/*.so)
```

### 案例3: 监控运行时SO变化

```bash
# 游戏启动时Dump
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO 12345'"
adb pull /data/local/tmp/dump_output/*.so ./dump_startup/

# 游戏运行30分钟后Dump
sleep 1800
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO 12345'"
adb pull /data/local/tmp/dump_output/*.so ./dump_runtime/

# 比较内存中的SO是否被修改（反调试检测）
md5sum dump_startup/*.so
md5sum dump_runtime/*.so
```

## 技巧和最佳实践 / Tips & Best Practices

### 1. 确定最佳Dump时机

✅ **推荐时机：**
- 游戏完全启动后
- 加载完主菜单
- 进入游戏场景后
- SO已完全加载到内存

❌ **不推荐时机：**
- 游戏启动画面
- 资源加载过程中
- 游戏切换场景时

### 2. 验证Dump文件完整性

```bash
# 检查文件大小（应该在几十MB）
ls -lh dump_output/*.so

# 检查ELF头
readelf -h dump_output/*.so

# 检查是否有有效的段
readelf -l dump_output/*.so

# 使用file命令验证
file dump_output/*.so
# 应该显示: ELF 64-bit LSB shared object, ARM aarch64
```

### 3. 处理大型SO文件

```bash
# 对于超大SO文件（>500MB），建议：

# 1. 确保设备存储空间充足
adb shell df -h /data/local/tmp

# 2. 分段拉取（避免传输中断）
adb pull /data/local/tmp/dump_output/ ./ --sync

# 3. 使用压缩（节省空间和传输时间）
adb shell "su -c 'cd /data/local/tmp && tar -czf dump.tar.gz dump_output/'"
adb pull /data/local/tmp/dump.tar.gz ./
tar -xzf dump.tar.gz
```

### 4. 多设备管理

```bash
# 列出所有设备
adb devices

# 为特定设备执行命令
adb -s <device_serial> push libs/arm64-v8a/DumpUE4_SO /data/local/tmp/
adb -s <device_serial> shell "su -c '/data/local/tmp/DumpUE4_SO 12345'"

# 示例：
adb -s 192.168.1.100:5555 shell "su -c '/data/local/tmp/DumpUE4_SO 12345'"
```

### 5. 自动化完整流程

创建 `full_auto.sh`:

```bash
#!/bin/bash

PACKAGE_NAME="com.your.game.package"
SO_NAME="libUE4.so"
OUTPUT_DIR="./dumped_$(date +%Y%m%d_%H%M%S)"

echo "=== 自动Dump流程 ==="

# 1. 检查设备
echo "[1/6] 检查设备连接..."
adb devices | grep device || exit 1

# 2. 查找进程
echo "[2/6] 查找目标进程..."
PID=$(adb shell "ps -A | grep $PACKAGE_NAME" | awk '{print $2}' | head -n 1)
if [ -z "$PID" ]; then
    echo "错误：未找到进程 $PACKAGE_NAME"
    exit 1
fi
echo "找到PID: $PID"

# 3. 推送工具
echo "[3/6] 推送工具到设备..."
adb push libs/arm64-v8a/DumpUE4_SO /data/local/tmp/
adb shell chmod +x /data/local/tmp/DumpUE4_SO

# 4. 执行Dump
echo "[4/6] 执行Dump..."
adb shell "su -c 'cd /data/local/tmp && ./DumpUE4_SO $PID $SO_NAME'"

# 5. 拉取文件
echo "[5/6] 拉取文件到本地..."
mkdir -p $OUTPUT_DIR
adb pull /data/local/tmp/dump_output/ $OUTPUT_DIR/

# 6. 验证
echo "[6/6] 验证文件..."
file $OUTPUT_DIR/dump_output/*.so
ls -lh $OUTPUT_DIR/dump_output/*.so

echo ""
echo "=== 完成！==="
echo "文件位置: $OUTPUT_DIR"
```

## 故障排除 / Troubleshooting

### 问题1: "Permission denied"

```bash
# 症状：无法读取/proc/[pid]/mem

# 解决方案：
# 1. 确认root权限
adb shell
su
whoami  # 应显示 root

# 2. 检查SELinux状态
getenforce
# 如果是Enforcing，临时设置为Permissive
setenforce 0

# 3. 使用完整root路径
su -c '/data/local/tmp/DumpUE4_SO 12345'
```

### 问题2: "No such file or directory"

```bash
# 症状：找不到指定的SO文件

# 解决方案：
# 1. 查看进程的maps文件
cat /proc/[PID]/maps | grep ".so"

# 2. 找到实际的SO名称（可能带路径）
cat /proc/12345/maps | grep -i ue4

# 3. 使用完整的SO名称
./DumpUE4_SO 12345 "libUE4-Android-Shipping.so"
```

### 问题3: Dump的文件太小或为空

```bash
# 原因：
# - 进程已退出
# - SO未完全加载
# - 内存保护机制

# 解决方案：
# 1. 确认进程仍在运行
ps -A | grep [PID]

# 2. 检查maps中的大小
cat /proc/[PID]/maps | grep libUE4

# 3. 稍后重试（等待SO完全加载）
sleep 10
./DumpUE4_SO [PID]
```

### 问题4: IDA无法正确加载

```bash
# 症状：IDA显示"Invalid file"或分析异常

# 解决方案：
# 1. 验证ELF文件头
readelf -h dumped.so

# 2. 检查文件完整性
md5sum dumped.so
# 重新Dump并比较MD5

# 3. 尝试修复文件头（如果必要）
# 使用010 Editor或其他十六进制编辑器

# 4. 使用IDA的自动分析
# 在IDA中：Options > General > Analysis > Reanalyze program
```

## 📊 输出文件说明 / Output Files

### 文件命名规则

```
libUE4_dump_0x<BASE_ADDR>_<TIMESTAMP>.so

示例 / Example:
libUE4_dump_0x7f8a000000_20260122_143025.so

说明 / Explanation:
- 0x7f8a000000: SO在内存中的基址
- 20260122: 日期 (2026年1月22日)
- 143025: 时间 (14:30:25)
```

### 文件存储位置

```
设备上 / On Device:
/data/local/tmp/dump_output/

本地 / Local:
./dump_output/  (使用adb pull后)
```

---

## 📚 更多资源 / More Resources

- [安装指南](INSTALL.md)
- [贡献指南](../CONTRIBUTING.md)
- [FAQ](../README.md#❓-常见问题)
- [GitHub Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues)

---

有问题？欢迎在 [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues) 中提问！

Questions? Feel free to ask in [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues)!
