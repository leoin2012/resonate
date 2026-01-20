# iOS 调试系统搭建完成

## ✅ 已完成的工作

### 1. 添加日志依赖
已在 `pubspec.yaml` 中添加以下依赖：
- `logger: ^2.0.2+1` - 结构化日志
- `sentry_flutter: ^7.14.0` - 崩溃捕获和监控
- `device_info_plus: ^10.1.0` - 设备信息
- `package_info_plus: ^9.0.0` - 应用信息

### 2. 创建日志系统

#### AppLogger (`lib/src/core/utils/app_logger.dart`)
统一的日志管理器，提供：
- 多级别日志输出
- 控制台和文件双输出
- 彩色格式化
- 日志文件自动轮转
- 专用日志方法（生命周期、Widget构建、状态变化、用户操作等）

#### ErrorMonitor (`lib/src/core/utils/error_monitor.dart`)
错误监控和崩溃报告系统，提供：
- 全局异常捕获
- 设备信息收集
- 应用信息收集
- 崩溃报告生成

### 3. 集成到应用

#### 修改 `main.dart`
- 初始化 AppLogger
- 初始化 ErrorMonitor
- 设置全局错误处理器
- 使用 runZonedGuarded 捕获未处理异常

#### 修改 `HomeScreen`
- 集成 AppLogger
- 记录 Widget 构建事件
- 记录用户操作
- 添加错误捕获

### 4. 创建自动化脚本

#### `AIReference/debug_ios_app.sh`
自动化调试脚本，功能包括：
- 自动检测连接的 iOS 设备
- 启动 iOS 系统日志收集器
- 启动 Flutter 日志收集器
- 启动应用
- 监控应用运行状态（60 秒）
- 检测崩溃和异常
- 自动生成崩溃报告

#### `AIReference/analyze_logs.py`
日志分析脚本，功能包括：
- 查找最新的日志文件
- 分析日志内容并分类
- 识别常见问题模式
- 生成分析报告
- 提供问题诊断和建议

### 5. 创建文档

#### `AIReference/debug_workflow_guide.md`
完整的使用指南，包含：
- 工作流概述
- 组件说明
- 快速开始指南
- 日志级别说明
- 常见问题诊断
- 在代码中添加日志的示例
- 调试工作流程
- 高级用法
- 故障排查

#### `AIReference/debug_quick_reference.md`
快速参考卡，包含：
- 一键启动调试命令
- 查看日志分析命令
- 手动查看日志命令
- 搜索日志命令
- 常见修复命令
- 在代码中添加日志示例
- 快速故障排查表

### 6. 安装依赖
```bash
flutter pub get  ✅
cd ios && pod install && cd ..  ✅
```

---

## 📂 创建的文件

| 文件 | 用途 |
|------|------|
| `lib/src/core/utils/app_logger.dart` | 日志管理器 |
| `lib/src/core/utils/error_monitor.dart` | 错误监控器 |
| `AIReference/debug_ios_app.sh` | 自动化调试脚本 |
| `AIReference/analyze_logs.py` | 日志分析脚本 |
| `AIReference/debug_workflow_guide.md` | 完整使用指南 |
| `AIReference/debug_quick_reference.md` | 快速参考卡 |

## 🔄 修改的文件

| 文件 | 修改内容 |
|------|----------|
| `pubspec.yaml` | 添加日志和调试依赖 |
| `lib/main.dart` | 集成日志系统和错误监控 |
| `lib/src/features/home/presentation/home_screen.dart` | 添加日志记录 |

---

## 🚀 如何使用

### 快速开始

1. **连接 iOS 设备**
   ```bash
   # 检查设备是否连接
   flutter devices
   ```

2. **运行调试脚本**
   ```bash
   ./AIReference/debug_ios_app.sh
   ```

3. **查看日志分析**
   ```bash
   python3 AIReference/analyze_logs.py
   ```

### 手动操作

如果需要更细粒度的控制，可以：

1. **查看 iOS 系统日志**
   ```bash
   cat AIReference/debug_logs/ios_log_*.log
   ```

2. **查看 Flutter 日志**
   ```bash
   cat AIReference/debug_logs/flutter_log_*.log
   ```

3. **搜索错误**
   ```bash
   grep -i "error" AIReference/debug_logs/flutter_log_*.log
   ```

---

## 📊 日志输出位置

所有日志文件都保存在 `AIReference/debug_logs/` 目录下：
- `session_TIMESTAMP.log` - 会话日志
- `ios_log_TIMESTAMP.log` - iOS 系统日志
- `flutter_log_TIMESTAMP.log` - Flutter 日志
- `build_TIMESTAMP.log` - 构建日志

所有报告文件都保存在 `AIReference/debug_reports/` 目录下：
- `crash_report_TIMESTAMP.md` - 崩溃报告（如果检测到崩溃）
- `analysis_report_TIMESTAMP.md` - 分析报告

---

## 🎯 调试流程

```
1. 运行 ./AIReference/debug_ios_app.sh
   ↓
2. 脚本自动：
   - 检测设备
   - 启动日志收集器
   - 启动应用
   - 监控运行（60秒）
   - 检测崩溃
   - 生成报告
   ↓
3. 查看 AIReference/debug_reports/ 中的报告
   ↓
4. 运行 python3 AIReference/analyze_logs.py 进行深入分析
   ↓
5. 根据报告中的建议修复问题
   ↓
6. 重新运行调试脚本验证修复
```

---

## 💡 下一步建议

### 对于当前的崩溃/黑屏问题

1. **立即执行调试脚本**
   ```bash
   ./AIReference/debug_ios_app.sh
   ```

2. **查看生成的报告**
   - 如果检测到崩溃：查看 `AIReference/debug_reports/crash_report_*.md`
   - 如果黑屏：运行 `python3 AIReference/analyze_logs.py`

3. **根据报告诊断问题**
   - 报告会包含：
     - 设备信息
     - 日志内容
     - 错误分析
     - 修复建议

4. **修复问题后重新验证**
   ```bash
   ./AIReference/debug_ios_app.sh
   ```

### 对于未来的开发

1. **在代码中添加更多日志**
   ```dart
   final logger = AppLogger();
   logger.logWidgetBuild('YourWidget');
   logger.logUserAction('User clicked button');
   logger.logStateChange('providerName', state);
   ```

2. **使用 ErrorMonitor 记录错误**
   ```dart
   final errorMonitor = ErrorMonitor();
   errorMonitor.logError(error, stackTrace, context: 'FunctionName');
   ```

3. **定期运行分析脚本**
   ```bash
   python3 AIReference/analyze_logs.py
   ```

---

## ⚠️ 注意事项

1. **设备必须连接**
   - 确保 iOS 设备已连接到 Mac
   - 设备必须解锁并信任电脑

2. **权限要求**
   - 脚本需要执行权限（已设置）
   - 需要访问设备日志权限

3. **日志存储**
   - 日志文件会占用磁盘空间
   - AppLogger 会自动清理旧日志（保留最近 5 个）

4. **监控时长**
   - 默认监控 60 秒
   - 可以修改脚本中的 `monitoring_duration` 变量调整

---

## 📚 相关文档

- [完整使用指南](./debug_workflow_guide.md) - 详细的使用说明和示例
- [快速参考](./debug_quick_reference.md) - 常用命令和快速查找
- [真机部署指南](./ios_real_device_deployment_guide.md) - iOS 真机部署说明
- [排错文档](./ios_real_device_troubleshooting.md) - 常见问题和解决方案

---

## 🎉 总结

调试系统已经完全搭建完成！你现在拥有：

✅ **完整的日志系统** - AppLogger 和 ErrorMonitor  
✅ **自动化调试脚本** - debug_ios_app.sh  
✅ **智能日志分析** - analyze_logs.py  
✅ **详细的文档** - 使用指南和快速参考  
✅ **依赖已安装** - 所有必要的包都已配置  

**现在你可以运行 `./AIReference/debug_ios_app.sh` 来诊断应用的崩溃和黑屏问题了！**

如果遇到任何问题，请查看生成的报告或运行分析脚本获取诊断信息。
