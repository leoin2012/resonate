# AIReference 目录

此目录包含 Resonate 项目的 AI 辅助开发相关文档和脚本。

## 📁 目录结构

```
AIReference/
├── ios_device_installation_guide.md  # iOS 真机安装完整流程文档
├── build_install_log.txt             # 构建和安装日志
└── execution_log.txt                 # 执行日志(用于记录命令执行过程)
```

## 📱 iOS 真机安装指南

详细的 iOS 真机安装流程请参考: [ios_device_installation_guide.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/AIReference/ios_device_installation_guide.md)

### 快速开始

使用自动化脚本安装到真机:

```bash
./scripts/install_to_device.sh
```

## 📊 构建和安装日志

- **build_install_log.txt**: 记录完整的构建和安装过程,包括错误和解决方案
- **execution_log.txt**: 记录命令执行过程(根据记忆配置)

## 🔧 相关脚本

- **scripts/install_to_device.sh**: 自动化构建和部署到 iOS 真机的脚本

## 📝 维护说明

- 每次修改代码或依赖后,建议重新执行安装流程
- 如遇到新问题,请更新本文档和日志
- 严格遵循 [ios_device_installation_guide.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/AIReference/ios_device_installation_guide.md) 中的步骤执行

---

**最后更新**: 2026-01-20
