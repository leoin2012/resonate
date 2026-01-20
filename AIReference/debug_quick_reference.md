# iOS 调试快速参考

## 🚀 一键启动调试

```bash
./AIReference/debug_ios_app.sh
```

---

## 📊 查看日志分析

```bash
python3 AIReference/analyze_logs.py
```

---

## 🔍 手动查看日志

```bash
# iOS 系统日志
cat AIReference/debug_logs/ios_log_*.log

# Flutter 日志
cat AIReference/debug_logs/flutter_log_*.log

# 崩溃报告
cat AIReference/debug_reports/crash_report_*.md

# 分析报告
cat AIReference/debug_reports/analysis_report_*.md
```

---

## 🔧 搜索日志

```bash
# 搜索错误
grep -i "error" AIReference/debug_logs/flutter_log_*.log

# 搜索崩溃
grep -i "crash\|fatal" AIReference/debug_logs/ios_log_*.log

# 搜索特定 Widget
grep "HomeScreen" AIReference/debug_logs/flutter_log_*.log

# 搜索生命周期事件
grep "Lifecycle" AIReference/debug_logs/flutter_log_*.log
```

---

## 🛠️ 常见修复

### Xcode 模块错误
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### 清理并重新构建
```bash
flutter clean
flutter build ios --debug
```

### 重新安装所有依赖
```bash
flutter pub upgrade --major-versions
cd ios && pod install && cd ..
```

---

## 📱 指定设备调试

```bash
# 先列出设备
flutter devices

# 然后使用设备 ID
DEVICE_ID=your_device_id ./AIReference/debug_ios_app.sh
```

---

## 💡 在代码中添加日志

```dart
// 初始化
final logger = AppLogger();
await logger.initialize();

// 使用
logger.debug('Debug message');
logger.info('Info message');
logger.warning('Warning message');
logger.error('Error message', error, stackTrace);

// 记录特定事件
logger.logLifecycle('App started');
logger.logWidgetBuild('HomeScreen');
logger.logStateChange('timerProvider', state);
logger.logUserAction('Button pressed');
```

---

## 📚 详细文档

- [完整使用指南](./debug_workflow_guide.md)
- [真机部署指南](./ios_real_device_deployment_guide.md)
- [排错文档](./ios_real_device_troubleshooting.md)

---

## 🎯 调试流程

```
1. 运行调试脚本
   ↓
2. 等待 60 秒监控
   ↓
3. 检查输出或报告
   ↓
4. 运行分析脚本
   ↓
5. 根据建议修复
   ↓
6. 重新运行验证
```

---

## ⚡ 快速故障排查

| 症状 | 命令 |
|------|------|
| 应用崩溃 | `./AIReference/debug_ios_app.sh` |
| 应用黑屏 | `./AIReference/debug_ios_app.sh` && `python3 AIReference/analyze_logs.py` |
| 查看错误 | `grep -i "error" AIReference/debug_logs/*.log` |
| 构建失败 | `cat AIReference/debug_logs/build_*.log` |
| 无日志输出 | 检查设备连接和权限 |

---

**💡 提示：** 所有日志都会保存在 `AIReference/debug_logs/` 目录下，报告保存在 `AIReference/debug_reports/` 目录下。
