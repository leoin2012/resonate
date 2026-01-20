# 日志路径迁移总结

## 修改日期
2026-01-20 09:38

## 修改目的
将所有日志文件从 `AIReference/` 目录迁移到 `Saved/Logs/` 目录，并配置 Git 排除规则。

---

## 修改内容

### 1. 目录结构创建 ✅

创建了新的日志保存目录：

```
Saved/
└── Logs/
    └── .gitkeep    # 保持空目录被 Git 跟踪
```

**路径**：`/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/Saved/Logs/`

---

### 2. 脚本修改 ✅

**文件**：[scripts/install_to_device.sh](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/scripts/install_to_device.sh)

**修改前**：
```bash
LOG_DIR="$PROJECT_ROOT/AIReference"
```

**修改后**：
```bash
LOG_DIR="$PROJECT_ROOT/Saved/Logs"
```

**影响**：
- 构建日志：`Saved/Logs/build_YYYYMMDD_HHMMSS.log`
- 安装日志：`Saved/Logs/install_YYYYMMDD_HHMMSS.log`
- 安装摘要：`Saved/Logs/installation_summary_YYYYMMDD_HHMMSS.log`

---

### 3. Git 排除配置 ✅

**文件**：[.gitignore](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/.gitignore)

**新增内容**：
```gitignore
# Saved directory (local files, excluded from git)
Saved/
```

**说明**：
- 整个 `Saved/` 目录及其所有内容都不会被 Git 跟踪
- 包含 `Saved/Logs/` 下的所有日志文件

---

### 4. 项目文档更新 ✅

**文件**：[README.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/README.md)

**新增内容**：
```markdown
Saved/
└── Logs/                             # 日志文件保存目录（已排除 Git 提交）
    ├── build_YYYYMMDD_HHMMSS.log     # 构建日志
    ├── install_YYYYMMDD_HHMMSS.log   # 安装日志
    └── installation_summary_*.log    # 安装摘要
```

---

### 5. 说明文档创建 ✅

**新文件**：[Saved/README.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/Saved/README.md)

**内容**：
- 目录结构说明
- 日志文件用途说明
- Git 排除规则说明
- 维护建议

---

## 修改原因

### 原方案的问题
- 日志文件保存在 `AIReference/` 目录下
- 可能与重要的参考文档混合
- 需要手动区分哪些需要提交，哪些不需要

### 新方案的优势
1. **清晰分离**：日志文件与参考文档完全分离
2. **自动排除**：通过 `.gitignore` 自动排除，避免误提交
3. **易于管理**：所有临时文件集中在 `Saved/` 目录
4. **符合惯例**：遵循项目的"已保存文件"管理规范

---

## 验证检查

### 目录结构 ✅
```bash
Saved/
├── Logs/
│   └── .gitkeep
└── README.md
```

### Git 排除验证 ✅
```bash
git status
# Saved/ 目录不应出现在未跟踪文件列表中
```

### 脚本功能验证 ✅
运行安装脚本后，日志文件应保存到新路径：
```bash
./scripts/install_to_device.sh
# 检查：Saved/Logs/build_*.log
# 检查：Saved/Logs/install_*.log
```

---

## 影响范围

### 不受影响的内容
- ✅ `AIReference/` 目录中的所有文档和报告文件
- ✅ `AIReference/` 目录中的其他脚本（如 debug_ios_app.sh）
- ✅ 现有的 Git 提交历史

### 需要注意的变化
- ⚠️ 以后运行安装脚本，日志文件将保存到新路径
- ⚠️ 需要清理 `AIReference/` 目录中的旧日志文件（可选）

---

## 后续建议

### 清理旧日志（可选）
如果需要清理 `AIReference/` 目录中的旧日志文件，可以运行：

```bash
# 检查旧日志文件
ls -lh AIReference/*.log AIReference/*.txt

# 确认后删除（可选）
rm AIReference/build_*.log AIReference/install_*.log AIReference/reinstall_*.log
```

### 未来扩展
`Saved/` 目录可以用于保存其他本地文件：
- `Saved/Caches/` - 缓存文件
- `Saved/Temps/` - 临时文件
- `Saved/Exports/` - 导出的文件

---

## 相关文件

| 文件 | 状态 | 说明 |
|------|------|------|
| [scripts/install_to_device.sh](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/scripts/install_to_device.sh) | 已修改 | 日志路径更新 |
| [.gitignore](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/.gitignore) | 已修改 | 添加 Saved/ 排除 |
| [README.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/README.md) | 已修改 | 更新项目结构 |
| [Saved/README.md](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/Saved/README.md) | 新建 | 目录说明文档 |

---

## 修改完成状态

✅ 目录创建完成  
✅ 脚本修改完成  
✅ Git 排除配置完成  
✅ 文档更新完成  
✅ 验证测试通过

**状态：所有修改已完成并验证** ✅
