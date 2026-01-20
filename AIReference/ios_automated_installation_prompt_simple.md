# iOS 真机一键安装

## 🚀 自动触发条件

用户需求包含以下关键词时，立即执行安装：
```
"安装到真机" | "部署到 iPhone" | "在设备上运行" | "ios-deploy"
"安装失败" | "无法启动" | "一键安装" | "自动化部署"
```

---

## 📋 执行流程

```bash
# 1. 检查设备
idevice_id -l

# 2. 执行安装
./scripts/install_to_device.sh

# 3. 显示摘要
cat $(ls -t Saved/Logs/installation_summary_*.log | head -1)
```

---

## ⚠️ 重要提示

**必须提示用户手动信任开发者证书**（Apple 安全限制，无法自动化）：
```
设置 → 通用 → VPN 与设备管理 → 信任 [开发者名称]
```

99% 的"无法启动"都是因为未信任证书。

---

## 📁 日志位置

```
Saved/Logs/
├── build_*.log        # 构建日志
├── install_*.log      # 安装日志
└── installation_summary_*.log  # 摘要
```

（已配置 Git 排除）
