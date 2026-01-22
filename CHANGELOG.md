# 更新日志 / Changelog

All notable changes to this project will be documented in this file.

## [1.1.0] - 2026-01-22

### ✨ Added / 新增
- 🔧 **Auto ELF Header Fixing** / 自动修复ELF文件头功能
  - Automatically detects and fixes invalid Section Header Table information / 自动检测并修复无效的Section Header Table信息
  - Ensures perfect compatibility with IDA Pro and other analysis tools / 确保与IDA Pro等分析工具完美兼容
  - Supports both 32-bit and 64-bit ELF files / 支持32位和64位ELF文件
  - Clears `e_shoff`, `e_shnum`, and `e_shstrndx` fields / 清除 `e_shoff`、`e_shnum` 和 `e_shstrndx` 字段

### 🐛 Fixed / 修复
- ❌ Fixed "SHT table size or offset is invalid" error in IDA Pro / 修复IDA Pro中"SHT table size or offset is invalid"错误
- ❌ Removed unused variable warning in compilation / 移除编译时未使用变量的警告

### 🔧 Changed / 变更
- 📝 Updated documentation with ELF fixing details / 更新文档，添加ELF修复详情
- 🎨 Simplified build script for easier usage / 简化编译脚本，更易使用

---

## [1.0.0] - 2026-01-22

### ✨ Added / 新增
- 🎉 Initial release / 首次发布
- ✅ Support dumping UE4 SO files from Android process memory / 支持从Android进程内存Dump UE4 SO文件
- ✅ Multi-architecture support (ARMv7, ARM64, x86, x86_64) / 多架构支持
- ✅ Real-time progress display with colored output / 实时进度显示和彩色输出
- ✅ Auto-generate filenames with base address and timestamp / 自动生成包含基址和时间戳的文件名
- ✅ Comprehensive error handling and logging / 完善的错误处理和日志记录
- ✅ Support dumping arbitrary SO files, not limited to UE4 / 支持Dump任意SO文件，不限于UE4
- ✅ Build automation script / 自动化编译脚本
- ✅ Usage example script / 使用示例脚本
- ✅ Complete documentation (Chinese and English) / 完整文档（中英文）

### 🎯 Features / 特性
- Ensure dumped SO files are 100% identical to originals / 确保Dump的SO文件与原始文件100%一致
- Optimized memory reading algorithm / 优化的内存读取算法
- Memory region offset preservation / 保持内存区域偏移量
- Graceful handling of unreadable memory regions / 优雅处理不可读内存区域

### 📚 Documentation / 文档
- README.md (Chinese) / 中文文档
- README_EN.md (English) / 英文文档
- Comprehensive usage examples / 完整使用示例
- FAQ section / 常见问题解答

---

## [Unreleased] / 未来计划

### 🚀 Planned Features / 计划特性
- [ ] GUI version / GUI版本
- [ ] Batch dumping support / 批量Dump支持
- [ ] SO file analysis features / SO文件分析功能
- [ ] Symbol restoration / 符号恢复
- [ ] Automatic IDA script generation / 自动生成IDA脚本

### 🔧 Improvements / 改进
- [ ] Performance optimization for large SO files / 大型SO文件性能优化
- [ ] Better error recovery mechanism / 更好的错误恢复机制
- [ ] Support for more game engines / 支持更多游戏引擎

---

## Version Format / 版本格式

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

版本格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)，
本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/spec/v2.0.0.html)。

### Version Categories / 版本类别
- **Added** / 新增 - 新功能
- **Changed** / 变更 - 已有功能的变更
- **Deprecated** / 弃用 - 即将删除的功能
- **Removed** / 删除 - 已删除的功能
- **Fixed** / 修复 - 错误修复
- **Security** / 安全 - 安全漏洞修复
