# 🎮 UE4 SO Dumper

<div align="center">

![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
![Platform](https://img.shields.io/badge/platform-Android-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)
![NDK](https://img.shields.io/badge/NDK-r21+-red.svg)

**A professional tool for dumping UE4 SO files from Android process memory**

English | [简体中文](README.md)

</div>

---

## 📖 Introduction

UE4 SO Dumper is an efficient and reliable Android native tool specifically designed to extract Unreal Engine 4 (UE4) SO library files from running processes. This tool ensures that dumped SO files are **completely identical** to the original files in APK, making them seamlessly analyzable in reverse engineering tools like IDA Pro without worrying about file corruption or incomplete structures.

### ✨ Key Features

- 🎯 **Precise Dumping** - Ensures 100% identical dumped SO files to originals
- 🔧 **Auto ELF Fixing** - Automatically fixes ELF headers for perfect IDA Pro compatibility
- 📊 **Real-time Progress** - Visual dumping process with progress bar
- 🎨 **Colored Output** - User-friendly colored terminal interface
- 🏷️ **Auto Naming** - Filenames include base address and timestamp for easy management
- 🔧 **Flexible Configuration** - Support dumping any SO file, not limited to UE4
- 💪 **Multi-arch Support** - Supports ARMv7, ARM64, x86, x86_64
- 🚀 **High Performance** - Optimized memory reading algorithm
- 📝 **Detailed Logging** - Complete operation logging

## 🎯 Use Cases

- 🎮 **Game Security Analysis** - Analyze UE4 game code logic
- 🔍 **Reverse Engineering** - Provide complete SO files for IDA Pro
- 🛡️ **Security Research** - Study game protection mechanisms
- 📚 **Learning & Research** - Learn UE4 engine internal implementation
- 🐛 **Vulnerability Discovery** - Find potential security vulnerabilities

## 📋 Requirements

### Development Environment
- **OS**: Windows / Linux / macOS
- **NDK Version**: Android NDK r21+ 
- **Build Tool**: ndk-build (included in NDK)

### Runtime Environment
- **Android Version**: Android 5.0 (API 21) and above
- **Device Permission**: Root access (required)
- **ADB Tool**: For file transfer and command execution

## 🚀 Quick Start

### 1️⃣ Clone Project

```bash
git clone https://github.com/wwc-ai/UE4-SO-Dumper.git
cd UE4-SO-Dumper
```

### 2️⃣ Configure NDK Environment

Set NDK environment variable (choose one):

```bash
# Linux/macOS
export NDK_ROOT=/path/to/android-ndk
# or
export ANDROID_NDK_HOME=/path/to/android-ndk

# Windows (PowerShell)
$env:NDK_ROOT="C:\path\to\android-ndk"
```

### 3️⃣ Build Project

```bash
chmod +x build.sh
./build.sh
```

After successful build, executables will be generated in `libs/` directory:

```
libs/
├── armeabi-v7a/DumpUE4_SO  (32-bit ARM)
├── arm64-v8a/DumpUE4_SO    (64-bit ARM)
├── x86/DumpUE4_SO          (32-bit x86)
└── x86_64/DumpUE4_SO       (64-bit x86)
```

### 4️⃣ Push to Device

```bash
# Push executable (choose based on device architecture)
adb push libs/arm64-v8a/DumpUE4_SO /data/local/tmp/

# Set execute permission
adb shell chmod +x /data/local/tmp/DumpUE4_SO
```

### 5️⃣ Find Target Process

```bash
# Method 1: Find by package name
adb shell "ps -A | grep com.your.package"

# Method 2: List all processes
adb shell ps -A

# Example output:
# USER  PID   PPID  VSZ    RSS   WCHAN  PC         NAME
# u0_a123 12345 1234  2345678 234567 0  0000000000 com.tencent.tmgp.pubgmhd
```

Note the PID (Process ID), e.g., `12345` above

### 6️⃣ Execute Dump

```bash
# Enter device shell
adb shell

# Switch to root
su

# Execute dump (replace 12345 with actual PID)
cd /data/local/tmp
./DumpUE4_SO 12345

# Dump other SO files
./DumpUE4_SO 12345 libil2cpp.so
```

### 7️⃣ Retrieve Dumped Files

```bash
# Exit device shell (Ctrl+D or exit)
exit
exit

# Pull dumped files to local
adb pull /data/local/tmp/dump_output/ ./dumped_files/
```

## 📱 Usage Examples

### Automation Script

The project provides an automation example script `example.sh`:

```bash
chmod +x example.sh
./example.sh
```

The script will automatically:
1. ✅ Check device connection
2. ✅ Push executable
3. ✅ Find target process
4. ✅ Execute dump operation
5. ✅ Pull files to local

### Command Line Arguments

```
Usage: ./DumpUE4_SO <PID> [SO_NAME]

Arguments:
  PID      - Target process ID (required)
  SO_NAME  - SO file name to dump (optional, default: libUE4.so)

Examples:
  ./DumpUE4_SO 12345                # Dump libUE4.so
  ./DumpUE4_SO 12345 libUE4.so      # Same as above
  ./DumpUE4_SO 12345 libil2cpp.so   # Dump libil2cpp.so
```

## 📊 Output Example

```
╔══════════════════════════════════════════════════════════╗
║              UE4 SO Dumper v1.1.0                        ║
║              Author: wwc-ai                              ║
║       https://github.com/wwc-ai/UE4-SO-Dumper      ║
╚══════════════════════════════════════════════════════════╝

[Target] PID: 12345, SO: libUE4.so
[Info] Reading memory maps for process 12345...
[Found] 0x7f8a000000-0x7f8a100000 r-xp offset:0x0 /data/app/.../libUE4.so
[Found] 0x7f8a100000-0x7f8a200000 r--p offset:0x100000 /data/app/.../libUE4.so
[Found] 0x7f8a200000-0x7f8a300000 rw-p offset:0x200000 /data/app/.../libUE4.so
[Success] Found 3 memory regions
[Base] 0x7f8a000000
[Output] File path: ./dump_output/libUE4_dump_0x7f8a000000_20260122_143025.so
[Start] Dumping memory data...
[Progress] [████████████████████████████████████████████████] 100% (52428800/52428800 bytes)

[Fixing] Fixing ELF header...
[Info] Detected 64-bit ELF file
[Info] Original e_shoff: 0x3200000, e_shnum: 26, e_shstrndx: 25
[Success] ELF header fixed (Section Header info cleared)
[Complete] Dump successful!
[File] ./dump_output/libUE4_dump_0x7f8a000000_20260122_143025.so
[Size] 52428800 bytes (50.00 MB)
[Summary] Dump completed, time elapsed: 5 seconds

╔══════════════════════════════════════════════════════════╗
║  Dump complete! Now you can analyze SO file with IDA!   ║
╚══════════════════════════════════════════════════════════╝
```

## 🛠️ Technical Details

### Dump Process

1. **Read Memory Maps** - Read target SO's memory layout from `/proc/[pid]/maps`
2. **Locate Base Address** - Find first executable region as base address
3. **Open Memory File** - Access `/proc/[pid]/mem` to read memory data
4. **Dump by Region** - Write to file according to original offsets
5. **Fix ELF Header** - Automatically clear invalid Section Header Table info
6. **Integrity Assurance** - Ensure all regions are correctly dumped

### Key Technical Points

- **Memory Map Analysis** - Precisely parse maps file to get memory layout
- **Offset Preservation** - Maintain original SO's section offsets
- **Permission Handling** - Properly handle memory regions with different permissions
- **Error Recovery** - Fill zero values for unreadable regions
- **ELF Header Fixing** - Auto-fix ELF headers by clearing invalid Section Header Table info for perfect IDA Pro compatibility

#### ELF Header Fixing Principle

Dumped SO files from memory may have Section Header Table pointing to invalid memory addresses, causing IDA Pro to report: `SHT table size or offset is invalid`.

This tool automatically performs the following fixes after dumping:
1. Detect ELF file type (32-bit/64-bit)
2. Read original ELF header information
3. Clear the following fields to avoid IDA parsing invalid data:
   - `e_shoff` - Section Header Table offset
   - `e_shnum` - Number of Section Headers
   - `e_shstrndx` - Section Header string table index
4. IDA Pro will use Program Header Table to parse the file instead, ensuring perfect compatibility

## 📁 Project Structure

```
UE4-SO-Dumper/
├── jni/
│   ├── main.cpp           # Main program source
│   ├── Android.mk         # NDK build config
│   └── Application.mk     # NDK app config
├── libs/                  # Build output (auto-generated)
├── obj/                   # Build temp files (auto-generated)
├── dump_output/           # Dumped files directory
├── build.sh               # Build script
├── example.sh             # Usage example script
├── .gitignore            # Git ignore config
├── README.md             # Chinese documentation
├── README_EN.md          # English documentation
└── LICENSE               # MIT License
```

## ❓ FAQ

### Q1: "Permission denied" error?

**A:** Must run with root privileges. Ensure:
```bash
adb shell
su  # Get root access
./DumpUE4_SO <PID>
```

### Q2: "No such file or directory" error?

**A:** Possible reasons:
1. Process doesn't exist - Check if PID is correct
2. Wrong SO filename - Verify SO name is accurate
3. SO not loaded - Ensure game is fully launched

### Q3: Dumped file can't be opened in IDA?

**A:** This tool automatically fixes ELF headers to ensure perfect IDA Pro compatibility. The tool will:
- Clear invalid Section Header Table information
- Preserve valid Program Header Table
- Ensure file structure integrity

If you still get `SHT table size or offset is invalid` error:
1. Confirm you're using the latest version
2. Check if "Fixing ELF header" log appears during dump
3. Use `file` command to verify file type: `file dumped.so`
4. If issue persists, please submit an Issue

### Q4: NDK not found during build?

**A:** Set correct NDK environment variable:
```bash
export NDK_ROOT=/path/to/android-ndk
# or
export ANDROID_NDK_HOME=/path/to/android-ndk
```

### Q5: Which Android versions are supported?

**A:** Supports Android 5.0 (API 21) and above. Tested on:
- ✅ Android 7.0 - 14.0
- ✅ 32-bit and 64-bit devices

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork the project
2. Create feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details

## ⚠️ Disclaimer

This tool is for security research and learning purposes only. Please comply with local laws and regulations when using this tool, and do not use it for illegal purposes. The author is not responsible for any consequences caused by using this tool.

## 🔗 Links

- **Author**: [GitHub](https://github.com/wwc-ai)
- **Issues**: [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues)
- **Changelog**: [CHANGELOG.md](CHANGELOG.md)

## 🌟 Star History

If this project helps you, please give it a ⭐ Star!

[![Star History Chart](https://api.star-history.com/svg?repos=wwc-ai/UE4-SO-Dumper&type=Date)](https://star-history.com/#wwc-ai/UE4-SO-Dumper&Date)

> If the chart doesn't display properly, please click the chart to visit [Star History page](https://star-history.com/#wwc-ai/UE4-SO-Dumper&Date) for the full history.

## 💖 Acknowledgments

Thanks to all developers who contributed to this project!

---

<div align="center">

**Made with ❤️ by wwc-ai**

[⬆ Back to Top](#-ue4-so-dumper)

</div>
