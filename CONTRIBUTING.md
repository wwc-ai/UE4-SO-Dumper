# 贡献指南 / Contributing Guide

感谢您考虑为 UE4 SO Dumper 做出贡献！

Thank you for considering contributing to UE4 SO Dumper!

## 🌟 如何贡献 / How to Contribute

### 报告Bug / Reporting Bugs

如果您发现了bug，请通过以下步骤报告：

If you find a bug, please report it by following these steps:

1. 检查 [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues) 确认bug未被报告
   
   Check [Issues](https://github.com/wwc-ai/UE4-SO-Dumper/issues) to ensure the bug hasn't been reported

2. 创建新的Issue，包含以下信息：
   
   Create a new Issue with the following information:
   - 清晰的标题 / Clear title
   - 详细的问题描述 / Detailed description
   - 复现步骤 / Steps to reproduce
   - 预期行为 / Expected behavior
   - 实际行为 / Actual behavior
   - 系统环境（Android版本、设备型号等）/ System environment (Android version, device model, etc.)
   - 相关日志或截图 / Relevant logs or screenshots

### 提出新功能 / Suggesting Features

1. 检查是否已有类似的功能请求 / Check if similar feature request exists
2. 创建Issue，描述：
   
   Create an Issue describing:
   - 功能的使用场景 / Use case for the feature
   - 功能如何工作 / How the feature would work
   - 为什么这个功能有用 / Why this feature would be useful

### 提交代码 / Submitting Code

1. **Fork 仓库 / Fork the repository**
   ```bash
   git clone https://github.com/wwc-ai/UE4-SO-Dumper.git
   ```

2. **创建分支 / Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   # or
   git checkout -b fix/your-bug-fix
   ```

3. **编写代码 / Write code**
   - 遵循现有代码风格 / Follow existing code style
   - 添加必要的注释 / Add necessary comments
   - 确保代码可以编译 / Ensure code compiles
   - 测试您的更改 / Test your changes

4. **提交更改 / Commit changes**
   ```bash
   git add .
   git commit -m "feat: add new feature" 
   # or
   git commit -m "fix: fix bug description"
   ```

   提交信息格式 / Commit message format:
   - `feat`: 新功能 / New feature
   - `fix`: 错误修复 / Bug fix
   - `docs`: 文档更新 / Documentation update
   - `style`: 代码格式（不影响代码运行）/ Code formatting
   - `refactor`: 重构 / Refactoring
   - `test`: 测试相关 / Testing
   - `chore`: 构建过程或辅助工具的变动 / Build process or auxiliary tools

5. **推送到您的Fork / Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **创建 Pull Request / Create Pull Request**
   - 清晰描述您的更改 / Clearly describe your changes
   - 关联相关Issue / Link related issues
   - 确保所有测试通过 / Ensure all tests pass

## 📝 代码规范 / Code Standards

### C/C++ 代码规范 / C/C++ Code Style

- 使用4个空格缩进 / Use 4 spaces for indentation
- 变量命名使用下划线命名法 / Use snake_case for variables
- 函数命名使用下划线命名法 / Use snake_case for functions
- 常量使用全大写 / Use UPPER_CASE for constants
- 添加必要的注释 / Add necessary comments
- 每个函数前添加文档注释 / Add documentation comments before each function

示例 / Example:
```cpp
/**
 * 函数功能描述
 * @param param1 参数1描述
 * @param param2 参数2描述
 * @return 返回值描述
 */
int my_function(int param1, const char* param2) {
    // 实现代码
    return 0;
}
```

### Shell脚本规范 / Shell Script Style

- 使用bash / Use bash
- 添加错误检查 / Add error checking
- 添加详细的注释 / Add detailed comments
- 使用有意义的变量名 / Use meaningful variable names

## 🧪 测试 / Testing

在提交PR之前，请确保：

Before submitting a PR, please ensure:

1. 代码可以成功编译 / Code compiles successfully
   ```bash
   ./build.sh
   ```

2. 在真实设备上测试 / Test on real device
   - 测试不同的Android版本 / Test different Android versions
   - 测试不同的SO文件 / Test different SO files
   - 测试边界情况 / Test edge cases

3. 检查内存泄漏 / Check for memory leaks

## 📋 Pull Request 检查清单 / PR Checklist

在提交PR之前，请确认：

Before submitting PR, please confirm:

- [ ] 代码遵循项目规范 / Code follows project standards
- [ ] 已添加必要的注释和文档 / Added necessary comments and documentation
- [ ] 已在真实设备上测试 / Tested on real device
- [ ] 更新了相关文档 / Updated relevant documentation
- [ ] 提交信息清晰明确 / Commit messages are clear
- [ ] 没有引入新的警告或错误 / No new warnings or errors introduced

## 💬 交流 / Communication

- GitHub Issues - 报告bug和功能请求 / Report bugs and feature requests
- GitHub Discussions - 一般性讨论 / General discussions
- Email - 私密问题 / Private matters

## 📜 许可证 / License

通过贡献代码，您同意您的贡献将在 MIT 许可证下授权。

By contributing, you agree that your contributions will be licensed under the MIT License.

## 🙏 致谢 / Acknowledgments

感谢所有贡献者的付出！

Thanks to all contributors for their efforts!

---

再次感谢您的贡献！❤️

Thank you again for your contribution! ❤️
