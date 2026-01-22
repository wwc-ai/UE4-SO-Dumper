# 🚀 快速参考卡 / Quick Reference Card

## ⚡ 一分钟上手 / One Minute Start

```bash
# 1. 编译
./build.sh

# 2. 推送
adb push libs/arm64-v8a/DumpUE4_SO /data/local/tmp/
adb shell chmod +x /data/local/tmp/DumpUE4_SO

# 3. 查找进程
adb shell "ps -A | grep <包名>"

# 4. Dump
adb shell "su -c '/data/local/tmp/DumpUE4_SO <PID>'"

# 5. 获取文件
adb pull /data/local/tmp/dump_output/ ./
```

## 📋 常用命令 / Common Commands

### 编译项目
```bash
# Linux/macOS
./build.sh

# Windows
build.bat
```

### 设备检查
```bash
# 全面检查
./scripts/check_device.sh

# 快速检查
adb devices && adb shell "su -c 'whoami'"
```

### 查找进程
```bash
# 通过包名
adb shell "ps -A | grep com.example.game"

# 查看所有进程
adb shell ps -A

# 获取PID
adb shell "pidof com.example.game"
```

### 执行Dump
```bash
# 基本用法
adb shell "su -c '/data/local/tmp/DumpUE4_SO <PID>'"

# Dump libUE4.so
adb shell "su -c '/data/local/tmp/DumpUE4_SO 12345'"

# Dump其他SO
adb shell "su -c '/data/local/tmp/DumpUE4_SO 12345 libil2cpp.so'"
```

### 一键操作
```bash
# 快速开始（自动化）
./scripts/quick_start.sh -p com.example.game

# 完整示例
./example.sh
```

### 清理
```bash
# 清理设备文件
./scripts/cleanup.sh

# 清理本地编译产物
rm -rf libs/ obj/
```

## 🎯 架构选择 / Architecture Selection

### 查看设备架构
```bash
adb shell getprop ro.product.cpu.abi
```

### 常见架构
| 输出 | 说明 | 使用文件 |
|------|------|----------|
| arm64-v8a | 64位ARM（大多数现代手机） | libs/arm64-v8a/DumpUE4_SO |
| armeabi-v7a | 32位ARM（老旧设备） | libs/armeabi-v7a/DumpUE4_SO |
| x86_64 | 64位x86（模拟器） | libs/x86_64/DumpUE4_SO |
| x86 | 32位x86（老旧模拟器） | libs/x86/DumpUE4_SO |

## 📱 常见游戏包名 / Common Game Packages

```bash
# PUBG Mobile
adb shell "ps -A | grep com.tencent.tmgp.pubgmhd"

# Call of Duty Mobile
adb shell "ps -A | grep com.activision.callofduty.shooter"

# Genshin Impact
adb shell "ps -A | grep com.miHoYo.GenshinImpact"

# Arena of Valor
adb shell "ps -A | grep com.tencent.tmgp.sgame"
```

## 🛠️ 故障排查 / Troubleshooting

### Permission denied
```bash
# 检查root
adb shell "su -c 'whoami'"

# 关闭SELinux（临时）
adb shell "su -c 'setenforce 0'"
```

### 找不到SO
```bash
# 查看进程加载的SO
adb shell "su -c 'cat /proc/<PID>/maps | grep .so'"

# 查看特定SO
adb shell "su -c 'cat /proc/<PID>/maps | grep -i ue4'"
```

### 设备未连接
```bash
# 重启ADB
adb kill-server && adb start-server

# 检查连接
adb devices -l
```

## 📊 输出文件 / Output Files

### 文件位置
```
设备: /data/local/tmp/dump_output/
本地: ./dump_output/ (adb pull后)
```

### 文件命名
```
格式: libUE4_dump_0x<基址>_<时间戳>.so
示例: libUE4_dump_0x7f8a000000_20260122_143025.so
```

### 验证文件
```bash
# 查看文件信息
file dump_output/*.so

# ELF头信息
readelf -h dump_output/*.so

# 文件大小
ls -lh dump_output/*.so
```

## 🎓 环境变量 / Environment Variables

### NDK配置
```bash
# Linux/macOS
export NDK_ROOT=/path/to/android-ndk
export ANDROID_NDK_HOME=/path/to/android-ndk

# Windows (PowerShell)
$env:NDK_ROOT="C:\path\to\android-ndk"
```

### 添加到PATH
```bash
# Linux/macOS (.bashrc 或 .zshrc)
export PATH=$PATH:$NDK_ROOT
export PATH=$PATH:~/Android/Sdk/platform-tools  # ADB

# Windows 系统环境变量
# NDK_ROOT = C:\android-ndk-r25c
# PATH += %NDK_ROOT%
```

## 🔗 快速链接 / Quick Links

- **完整文档**: [README.md](README.md)
- **安装指南**: [docs/INSTALL.md](docs/INSTALL.md)
- **使用指南**: [docs/USAGE.md](docs/USAGE.md)
- **项目结构**: [docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)
- **问题反馈**: [GitHub Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues)

## ⌨️ 键盘快捷键 / Shortcuts

```bash
# 在ADB Shell中
Ctrl+D    # 退出当前Shell
Ctrl+C    # 终止当前命令
Ctrl+Z    # 暂停当前进程

# 在终端中
Ctrl+R    # 搜索历史命令
↑/↓       # 浏览历史命令
Tab       # 自动补全
```

## 💡 专业技巧 / Pro Tips

1. **批量Dump**: 创建循环脚本处理多个SO
2. **版本对比**: 保存不同版本的Dump便于比较
3. **自动化**: 使用quick_start.sh节省时间
4. **备份**: 及时备份重要的Dump文件
5. **命名规范**: 使用有意义的目录名组织文件

## 📞 获取帮助 / Get Help

```bash
# 工具帮助
adb shell "/data/local/tmp/DumpUE4_SO"

# 设备检查
./scripts/check_device.sh

# 查看日志
adb logcat | grep DumpUE4
```

---

<div align="center">

**保存本页面以便快速查阅！** 📌

[⬆ 返回顶部](#-快速参考卡--quick-reference-card)

</div>
