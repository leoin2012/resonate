# Resonate 项目清理建议

## 📊 项目现状分析

根据README.md的项目规划：
- **主要平台**：Windows（开发调试）、Chrome Web（当前已运行）
- **未来平台**：iOS（Mac编译部署）
- **不需要的平台**：Linux、macOS（桌面应用）

## 🗑️ 可以安全删除的文件/目录

### 1. 构建缓存（推荐删除）
这些是Flutter运行时生成的缓存文件，删除后会自动重新生成：

```
✅ .dart_tool/          - Dart工具缓存（约70MB+）
✅ build/               - Flutter构建输出（约100MB+）
✅ .dart_tool/chrome-device/  - Chrome设备运行时缓存
```

**删除后影响**：下次运行项目时会自动重新生成，首次编译会稍慢。

---

### 2. 不需要的平台配置（推荐删除）

```
✅ linux/               - 不在项目规划中的Linux平台
✅ macos/               - 不需要macOS桌面应用（只在Mac上编译iOS）
```

**删除后影响**：完全不影响当前项目运行，节省大量文件。

---

### 3. 错误/临时文件（推荐删除）

```
✅ nul                  - 空文件或错误生成的文件（0字节）
```

---

## ⚠️ 建议保留的文件/目录

### 必须保留
```
✓ android/              - 虽然当前用Chrome，但可能需要测试
✓ ios/                  - 项目规划需要iOS编译
✓ web/                  - Chrome版本正在使用
✓ windows/              - Windows开发调试必需
✓ lib/                  - 源代码
✓ assets/               - 资源文件
✓ pubspec.yaml          - 项目配置
✓ pubspec.lock          - 依赖锁定
```

### 可选保留
```
? resonate.code-workspace - VS Code工作区配置（如使用VS Code则保留）
? test/                  - 测试文件（当前没有测试，但未来可能需要）
```

---

## 🚀 清理脚本

### Windows PowerShell 执行：
```powershell
# 清理构建缓存
Remove-Item -Recurse -Force .dart_tool
Remove-Item -Recurse -Force build

# 删除不需要的平台
Remove-Item -Recurse -Force linux
Remove-Item -Recurse -Force macos

# 删除错误文件
Remove-Item -Force nul

Write-Host "清理完成！预计节省约 150MB+ 空间"
```

### Git Bash / Linux:
```bash
# 清理构建缓存
rm -rf .dart_tool build

# 删除不需要的平台
rm -rf linux macos

# 删除错误文件
rm -f nul

echo "清理完成！预计节省约 150MB+ 空间"
```

---

## 📈 清理效果预估

| 删除内容 | 大小 | 说明 |
|---------|------|------|
| .dart_tool | ~70 MB | Dart工具缓存 |
| build | ~80 MB | Flutter构建输出 |
| linux/ | ~5 MB | Linux平台配置 |
| macos/ | ~10 MB | macOS桌面应用配置 |
| 其他 | ~1 MB | 临时文件 |
| **总计** | **~166 MB** | **节省空间** |

---

## ⚡ 清理后如何验证

清理完成后，运行以下命令验证项目仍然正常：

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

如果一切正常，说明清理成功！

---

## 📝 清理日志

**清理时间**：2026-01-18
**清理原因**：删除冗余文件，保持项目结构整洁
**清理范围**：构建缓存、不需要的平台配置、临时文件
