# 安装指南 / Installation Guide

## 📦 环境准备 / Environment Setup

### 1. 安装Android NDK / Install Android NDK

#### Windows

1. 下载 Android NDK / Download Android NDK:
   - 访问 [Android NDK 下载页](https://developer.android.com/ndk/downloads)
   - 下载最新版本（推荐 r21 或更高版本）

2. 解压到指定目录 / Extract to directory:
   ```
   例如: C:\android-ndk-r25c
   ```

3. 设置环境变量 / Set environment variables:
   ```powershell
   # PowerShell
   $env:NDK_ROOT="C:\android-ndk-r25c"
   
   # 永久设置 / Permanent setting
   [Environment]::SetEnvironmentVariable("NDK_ROOT", "C:\android-ndk-r25c", "User")
   ```

#### Linux / macOS

1. 下载 Android NDK / Download Android NDK:
   ```bash
   # 使用wget下载
   wget https://dl.google.com/android/repository/android-ndk-r25c-linux.zip
   
   # 或使用curl
   curl -O https://dl.google.com/android/repository/android-ndk-r25c-darwin.dmg
   ```

2. 解压 / Extract:
   ```bash
   unzip android-ndk-r25c-linux.zip
   sudo mv android-ndk-r25c /opt/
   ```

3. 设置环境变量 / Set environment variables:
   ```bash
   # 添加到 ~/.bashrc 或 ~/.zshrc
   export NDK_ROOT=/opt/android-ndk-r25c
   export PATH=$PATH:$NDK_ROOT
   
   # 使配置生效
   source ~/.bashrc
   ```

### 2. 安装ADB工具 / Install ADB Tools

#### Windows

1. 下载 [Android Platform Tools](https://developer.android.com/studio/releases/platform-tools)
2. 解压并添加到系统PATH
3. 验证安装 / Verify:
   ```powershell
   adb version
   ```

#### Linux

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install android-tools-adb

# Arch Linux
sudo pacman -S android-tools

# 验证安装 / Verify
adb version
```

#### macOS

```bash
# 使用Homebrew
brew install android-platform-tools

# 验证安装 / Verify
adb version
```

### 3. 验证环境 / Verify Environment

```bash
# 检查NDK
echo $NDK_ROOT
$NDK_ROOT/ndk-build --version

# 检查ADB
adb version
adb devices
```

## 🔨 编译项目 / Build Project

### 方法1: 使用构建脚本 / Using Build Script

```bash
# 克隆项目
git clone https://github.com/wwc-ai/UE4-SO-Dumper.git
cd UE4-SO-Dumper

# 赋予执行权限（Linux/macOS）
chmod +x build.sh

# 执行编译
./build.sh
```

### 方法2: 手动编译 / Manual Build

```bash
# 使用ndk-build直接编译
$NDK_ROOT/ndk-build NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=./jni/Android.mk

# Windows PowerShell
& "$env:NDK_ROOT\ndk-build.cmd" NDK_PROJECT_PATH=. APP_BUILD_SCRIPT=.\jni\Android.mk
```

### 编译输出 / Build Output

编译成功后，会在 `libs/` 目录生成以下文件：

After successful build, the following files will be generated in `libs/`:

```
libs/
├── armeabi-v7a/
│   └── DumpUE4_SO     # 32位ARM设备使用
├── arm64-v8a/
│   └── DumpUE4_SO     # 64位ARM设备使用（大多数现代设备）
├── x86/
│   └── DumpUE4_SO     # 32位x86设备/模拟器使用
└── x86_64/
    └── DumpUE4_SO     # 64位x86模拟器使用
```

## 📱 设备准备 / Device Preparation

### 1. 启用开发者选项 / Enable Developer Options

1. 进入 **设置** > **关于手机** / Go to **Settings** > **About phone**
2. 连续点击 **版本号** 7次 / Tap **Build number** 7 times
3. 返回设置，找到 **开发者选项** / Back to settings, find **Developer options**

### 2. 启用USB调试 / Enable USB Debugging

1. 进入 **开发者选项** / Go to **Developer options**
2. 启用 **USB调试** / Enable **USB debugging**
3. 连接设备时选择 **允许** / Choose **Allow** when connecting device

### 3. 获取Root权限 / Get Root Access

#### Magisk（推荐）

1. 下载并安装 [Magisk](https://github.com/topjohnwu/Magisk/releases)
2. 刷入Magisk并获取root权限
3. 授予Shell超级用户权限

#### 其他Root方案

- SuperSU
- KernelSU
- 设备厂商提供的解锁方案

### 4. 验证Root权限 / Verify Root Access

```bash
adb shell
su
# 如果成功进入root shell，会显示 # 提示符
whoami
# 应该显示: root
```

## 🚀 部署到设备 / Deploy to Device

### 1. 确定设备架构 / Determine Device Architecture

```bash
adb shell getprop ro.product.cpu.abi
```

常见输出 / Common outputs:
- `arm64-v8a` - 64位ARM（大多数现代手机）
- `armeabi-v7a` - 32位ARM
- `x86_64` - 64位x86（模拟器）
- `x86` - 32位x86（老旧模拟器）

### 2. 推送可执行文件 / Push Executable

```bash
# 根据架构选择对应文件
# For arm64-v8a
adb push libs/arm64-v8a/DumpUE4_SO /data/local/tmp/

# For armeabi-v7a
adb push libs/armeabi-v7a/DumpUE4_SO /data/local/tmp/
```

### 3. 设置权限 / Set Permissions

```bash
adb shell chmod +x /data/local/tmp/DumpUE4_SO
```

### 4. 测试运行 / Test Run

```bash
adb shell
su
/data/local/tmp/DumpUE4_SO
```

如果看到帮助信息，说明安装成功！

If you see help information, installation is successful!

## ❓ 常见问题 / Troubleshooting

### 编译错误 / Build Errors

**错误：找不到ndk-build**
```
解决方案：检查NDK_ROOT环境变量是否正确设置
Solution: Check if NDK_ROOT environment variable is set correctly
```

**错误：No toolchains found**
```
解决方案：更新到NDK r21或更高版本
Solution: Update to NDK r21 or higher
```

### 设备连接问题 / Device Connection Issues

**adb devices显示unauthorized**
```
解决方案：
1. 拔掉USB重新连接
2. 手机上点击"允许USB调试"
3. 必要时勾选"总是允许"

Solution:
1. Unplug and reconnect USB
2. Tap "Allow USB debugging" on phone
3. Check "Always allow" if needed
```

**找不到设备**
```
解决方案：
1. 检查USB线是否支持数据传输
2. 更换USB接口
3. 安装设备驱动（Windows）
4. 重启adb服务：adb kill-server && adb start-server

Solution:
1. Check if USB cable supports data transfer
2. Try different USB port
3. Install device driver (Windows)
4. Restart adb: adb kill-server && adb start-server
```

### Root权限问题 / Root Permission Issues

**su命令不存在**
```
解决方案：设备未获取root权限，需要先root设备
Solution: Device is not rooted, need to root first
```

**Permission denied**
```
解决方案：
1. 确保已授予Magisk/SuperSU权限
2. 在Magisk中启用Shell的超级用户权限

Solution:
1. Ensure Magisk/SuperSU permission granted
2. Enable Shell superuser in Magisk
```

## 📚 下一步 / Next Steps

环境配置完成后，请查看：

After environment setup, please check:

- [使用指南](../README.md#🚀-快速开始) / [Usage Guide](../README.md#🚀-quick-start)
- [示例脚本](../example.sh) / [Example Script](../example.sh)
- [FAQ](../README.md#❓-常见问题) / [FAQ](../README.md#❓-faq)

---

如有问题，请查看 [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues) 或提交新的Issue。

For issues, please check [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues) or submit a new one.
