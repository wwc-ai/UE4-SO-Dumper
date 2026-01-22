# 项目结构说明 / Project Structure

## 📁 目录树 / Directory Tree

```
UE4-SO-Dumper/
│
├── jni/                          # JNI源代码目录
│   ├── main.cpp                  # 主程序（核心Dump逻辑）
│   ├── Android.mk                # NDK编译配置
│   └── Application.mk            # NDK应用配置
│
├── libs/                         # 编译产物目录（自动生成）
│   ├── armeabi-v7a/
│   │   └── DumpUE4_SO           # 32位ARM可执行文件
│   ├── arm64-v8a/
│   │   └── DumpUE4_SO           # 64位ARM可执行文件
│   ├── x86/
│   │   └── DumpUE4_SO           # 32位x86可执行文件
│   └── x86_64/
│       └── DumpUE4_SO           # 64位x86可执行文件
│
├── obj/                          # 编译临时文件（自动生成）
│
├── docs/                         # 文档目录
│   ├── INSTALL.md               # 详细安装指南
│   ├── USAGE.md                 # 详细使用指南
│   └── PROJECT_STRUCTURE.md     # 项目结构说明（本文件）
│
├── scripts/                      # 实用脚本目录
│   ├── cleanup.sh               # 清理脚本
│   ├── check_device.sh          # 设备检查脚本
│   └── quick_start.sh           # 快速开始脚本
│
├── dump_output/                  # Dump文件输出目录（运行时生成）
│
├── build.sh                      # Linux/macOS编译脚本
├── build.bat                     # Windows编译脚本
├── example.sh                    # 使用示例脚本
│
├── README.md                     # 项目说明（中文）
├── README_EN.md                  # 项目说明（英文）
├── LICENSE                       # MIT许可证
├── CHANGELOG.md                  # 更新日志
├── CONTRIBUTING.md               # 贡献指南
└── .gitignore                   # Git忽略配置
```

## 📄 核心文件说明 / Core Files

### jni/main.cpp

**功能**: 主程序源代码

**关键功能模块**:
- `read_maps()` - 读取进程内存映射
- `dump_so()` - 执行SO文件Dump
- `print_progress()` - 显示进度条
- `print_log()` - 彩色日志输出
- `main()` - 主入口函数

**核心数据结构**:
```cpp
typedef struct {
    unsigned long start;      // 内存区域起始地址
    unsigned long end;        // 内存区域结束地址
    unsigned long offset;     // 文件偏移量
    char perms[5];           // 权限（r-xp等）
    char path[256];          // SO文件路径
} MemoryRegion;
```

### jni/Android.mk

**功能**: NDK编译配置文件

**主要配置**:
```makefile
LOCAL_MODULE := DumpUE4_SO      # 模块名称
LOCAL_SRC_FILES := main.cpp     # 源文件
LOCAL_CFLAGS := -Wall -O2 -fPIE # 编译选项
LOCAL_LDFLAGS := -fPIE -pie     # 链接选项
```

### jni/Application.mk

**功能**: NDK应用级配置

**主要配置**:
```makefile
APP_ABI := armeabi-v7a arm64-v8a x86 x86_64  # 目标架构
APP_PLATFORM := android-21                    # 最低Android版本
APP_STL := c++_static                         # C++标准库
```

## 🔧 脚本文件说明 / Scripts

### build.sh / build.bat

**功能**: 编译脚本

**流程**:
1. 检查NDK环境变量
2. 验证ndk-build可用性
3. 清理旧的编译产物
4. 执行编译
5. 显示编译结果

### example.sh

**功能**: 完整使用示例

**演示内容**:
- 设备连接检查
- 进程查找
- 文件推送
- Dump执行
- 文件拉取

### scripts/check_device.sh

**功能**: 设备环境检查

**检查项**:
- ADB工具安装
- 设备连接状态
- 设备架构
- Android版本
- Root权限
- SELinux状态
- 存储空间

### scripts/cleanup.sh

**功能**: 清理设备上的文件

**清理内容**:
- 可执行文件
- Dump输出目录
- 临时文件和日志

### scripts/quick_start.sh

**功能**: 一键自动化Dump

**自动化流程**:
1. 检查编译产物
2. 验证设备连接
3. 检查Root权限
4. 推送可执行文件
5. 查找目标进程
6. 执行Dump
7. 拉取文件到本地

**使用示例**:
```bash
./scripts/quick_start.sh -p com.tencent.tmgp.pubgmhd
./scripts/quick_start.sh -p com.game.example -s libil2cpp.so
```

## 📚 文档文件说明 / Documentation

### README.md

**内容**: 项目主文档（中文）

**包含**:
- 项目简介
- 核心特性
- 快速开始
- 使用示例
- FAQ
- 贡献指南

### README_EN.md

**内容**: 项目主文档（英文）

**目的**: 为国际用户提供英文文档

### docs/INSTALL.md

**内容**: 详细安装指南

**涵盖**:
- NDK环境配置
- ADB工具安装
- 设备准备
- 编译步骤
- 部署流程
- 常见问题

### docs/USAGE.md

**内容**: 详细使用指南

**涵盖**:
- 基本用法
- 高级技巧
- 实战案例
- 最佳实践
- 故障排除

### CHANGELOG.md

**内容**: 版本更新记录

**格式**: 遵循 [Keep a Changelog](https://keepachangelog.com/)

### CONTRIBUTING.md

**内容**: 贡献者指南

**包含**:
- 贡献流程
- 代码规范
- 提交规范
- Pull Request要求

## 🎨 配置文件说明 / Configuration Files

### .gitignore

**功能**: Git版本控制忽略规则

**忽略内容**:
```
libs/                # 编译产物
obj/                 # 临时文件
dump_output/         # Dump输出
.vscode/            # IDE配置
*.log               # 日志文件
```

### LICENSE

**许可证**: MIT License

**特点**:
- 允许商业使用
- 允许修改
- 允许分发
- 需保留版权声明

## 🔄 运行时生成的文件 / Runtime Generated Files

### libs/ 目录

**生成时机**: 执行 `build.sh` 后

**内容**: 各架构的可执行文件

### obj/ 目录

**生成时机**: 编译过程中

**内容**: 编译临时文件和对象文件

### dump_output/ 目录

**生成时机**: 执行Dump后（在设备上）

**内容**: Dump出的SO文件

**命名格式**:
```
libUE4_dump_0x<BASE_ADDR>_<TIMESTAMP>.so
```

**示例**:
```
libUE4_dump_0x7f8a000000_20260122_143025.so
```

## 🏗️ 架构设计 / Architecture

### 编译流程

```
源代码 (main.cpp)
    ↓
Android.mk 配置
    ↓
ndk-build 编译
    ↓
生成多架构可执行文件
    ↓
libs/[arch]/DumpUE4_SO
```

### 运行流程

```
1. 读取 /proc/[pid]/maps
    ↓
2. 解析内存映射信息
    ↓
3. 定位SO基址
    ↓
4. 打开 /proc/[pid]/mem
    ↓
5. 按区域读取内存
    ↓
6. 写入输出文件（保持offset）
    ↓
7. 生成完整SO文件
```

### 数据流

```
目标进程内存
    ↓
/proc/[pid]/mem
    ↓
DumpUE4_SO 工具
    ↓
dump_output/libUE4_dump_*.so
    ↓
本地计算机（通过adb pull）
    ↓
IDA Pro 分析
```

## 🔍 关键技术点 / Key Technologies

1. **内存映射读取**: 通过 `/proc/[pid]/maps` 获取内存布局
2. **内存数据读取**: 通过 `/proc/[pid]/mem` 读取实际数据
3. **偏移量保持**: 使用 `lseek64()` 保持原始文件结构
4. **错误处理**: 不可读区域填充零值
5. **进度显示**: 实时计算并显示Dump进度

## 📦 依赖关系 / Dependencies

### 编译时依赖

- Android NDK (r21+)
- C++ 编译器（NDK自带）
- Make工具（NDK自带）

### 运行时依赖

- Android系统（API 21+）
- Root权限
- Linux内核特性（/proc文件系统）

### 开发工具依赖

- ADB (Android Debug Bridge)
- Git（版本控制）
- 文本编辑器

## 🎯 设计原则 / Design Principles

1. **简单易用**: 一个命令完成Dump
2. **完整性保证**: 确保Dump文件与原始文件一致
3. **友好输出**: 彩色日志和进度显示
4. **错误处理**: 优雅处理各种异常情况
5. **跨平台**: 支持多种架构和Android版本
6. **开源友好**: MIT许可证，欢迎贡献

---

## 📖 更多信息 / More Information

- [安装指南](INSTALL.md)
- [使用指南](USAGE.md)
- [主文档](../README.md)
- [贡献指南](../CONTRIBUTING.md)
