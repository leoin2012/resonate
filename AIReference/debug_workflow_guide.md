# iOS 调试工作流使用指南

## 🎯 工作流概述

这套调试系统提供了一套完整的 iOS 应用调试解决方案，能够：
- 自动收集应用启动日志
- 监控应用运行状态
- 检测崩溃和异常
- 自动分析日志并生成报告
- 提供问题诊断和建议

---

## 📦 已添加的组件

### 1. 日志系统

#### AppLogger (`lib/src/core/utils/app_logger.dart`)
统一的日志管理器，提供：
- 多级别日志输出
- 控制台和文件双输出
- 彩色格式化
- 日志文件自动轮转

**使用示例：**
```dart
final logger = AppLogger();

// 初始化（通常在 main 函数中）
await logger.initialize();

// 记录不同级别的日志
logger.debug('Debug message');
logger.info('Info message');
logger.warning('Warning message');
logger.error('Error message', error, stackTrace);
logger.fatal('Fatal error message', error, stackTrace);

// 记录特定事件
logger.logLifecycle('App started');
logger.logWidgetBuild('HomeScreen');
logger.logStateChange('timerProvider', state);
logger.logUserAction('Button pressed', {'button': 'start'});
```

#### ErrorMonitor (`lib/src/core/utils/error_monitor.dart`)
错误监控和崩溃报告系统，提供：
- 全局异常捕获
- 设备信息收集
- 应用信息收集
- 崩溃报告生成

**使用示例：**
```dart
final errorMonitor = ErrorMonitor();

// 初始化（通常在 main 函数中）
await errorMonitor.initialize();

// 记录错误
errorMonitor.logError(error, stackTrace, 
    context: 'FunctionName',
    additionalInfo: {'key': 'value'}
);

// 生成崩溃报告
final report = await errorMonitor.generateCrashReport(
    error, 
    stackTrace, 
    context: 'AppLaunch'
);
```

### 2. 自动化脚本

#### debug_ios_app.sh
自动化调试脚本，自动执行以下操作：
1. 检测连接的 iOS 设备
2. 启动日志收集器（iOS 系统日志 + Flutter 日志）
3. 启动应用
4. 监控应用运行状态（60 秒）
5. 检测崩溃和异常
6. 自动生成崩溃报告

**使用方法：**
```bash
# 方式 1: 直接运行（自动检测设备）
./AIReference/debug_ios_app.sh

# 方式 2: 指定设备 ID
DEVICE_ID=00008120-000954A23408201E ./AIReference/debug_ios_app.sh

# 方式 3: 使用 bash 运行
bash AIReference/debug_ios_app.sh
```

**输出文件：**
- `AIReference/debug_logs/session_TIMESTAMP.log` - 会话日志
- `AIReference/debug_logs/ios_log_TIMESTAMP.log` - iOS 系统日志
- `AIReference/debug_logs/flutter_log_TIMESTAMP.log` - Flutter 日志
- `AIReference/debug_logs/build_TIMESTAMP.log` - 构建日志
- `AIReference/debug_reports/crash_report_TIMESTAMP.md` - 崩溃报告（如果检测到崩溃）

#### analyze_logs.py
日志分析脚本，自动执行以下操作：
1. 查找最新的日志文件
2. 分析日志内容，分类消息
3. 识别常见问题模式
4. 生成分析报告
5. 显示问题诊断和建议

**使用方法：**
```bash
# 运行分析
python3 AIReference/analyze_logs.py

# 或者
python AIReference/analyze_logs.py
```

**输出文件：**
- `AIReference/debug_reports/analysis_report_TIMESTAMP.md` - 分析报告

---

## 🚀 快速开始

### Step 1: 添加日志依赖

已经在 `pubspec.yaml` 中添加了以下依赖：
```yaml
dependencies:
  logger: ^2.0.2+1
  sentry_flutter: ^7.14.0
  device_info_plus: ^10.1.0
  package_info_plus: ^5.0.1
```

### Step 2: 安装依赖

```bash
flutter pub get
cd ios && pod install && cd ..
```

### Step 3: 连接 iOS 设备

确保：
- iOS 设备已连接到 Mac
- 设备已解锁并信任电脑
- Xcode 能识别设备

### Step 4: 运行调试脚本

```bash
./AIReference/debug_ios_app.sh
```

### Step 5: 查看日志

脚本会自动收集日志并生成报告。你可以：

1. **查看实时输出**：脚本运行时会显示彩色输出
2. **查看崩溃报告**：如果检测到崩溃，会自动生成崩溃报告
3. **运行分析脚本**：使用 `python3 AIReference/analyze_logs.py` 深入分析日志

---

## 📊 日志级别说明

| 级别 | 用途 | 示例场景 |
|------|------|----------|
| **Debug** | 详细的调试信息 | Widget 构建、状态变化、方法调用 |
| **Info** | 一般信息 | 用户操作、应用启动、生命周期事件 |
| **Warning** | 警告信息 | 非致命错误、需要注意的问题 |
| **Error** | 错误信息 | 功能失败、异常捕获 |
| **Fatal** | 致命错误 | 应用崩溃、无法恢复的错误 |

---

## 🔧 常见问题诊断

脚本会自动识别以下常见问题：

### 1. Xcode 模块错误
```
Could not build module 'CoreFoundation'
```
**自动建议：**
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### 2. 缺失插件错误
```
MissingPluginException
```
**自动建议：**
```bash
# 检查 pubspec.yaml
cd ios && pod install && cd ..
```

### 3. 链接错误
```
Symbol not found
Undefined symbol
```
**自动建议：**
```bash
flutter clean
flutter build ios
```

### 4. 构建失败
```
Build failed
Compilation failed
```
**自动建议：**
- 检查语法错误
- 检查依赖版本
- 运行 `flutter analyze`

---

## 📝 在代码中添加日志

### 在 main.dart 中

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化日志
  final logger = AppLogger();
  await logger.initialize();
  
  logger.info('🚀 Application Starting');
  
  // 初始化错误监控
  final errorMonitor = ErrorMonitor();
  await errorMonitor.initialize();
  
  runZonedGuarded(
    () {
      runApp(const ProviderScope(child: ResonateApp()));
    },
    (error, stack) {
      logger.fatal('Uncaught error', error, stack);
      errorMonitor.logError(error, stack, context: 'Main Zone');
    },
  );
}
```

### 在 Widget 中

```dart
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logger = AppLogger();
    
    logger.logWidgetBuild('HomeScreen');
    
    try {
      return Scaffold(
        // ...
      );
    } catch (e, stack) {
      logger.error('Error building HomeScreen', e, stack);
      rethrow;
    }
  }
}
```

### 在 Provider 中

```dart
class TimerNotifier extends StateNotifier<TimerState> {
  TimerNotifier() : super(TimerState.initial()) {
    final logger = AppLogger();
    logger.info('TimerNotifier initialized');
  }
  
  void start() {
    final logger = AppLogger();
    logger.logUserAction('Start timer');
    
    // ...
    
    logger.logStateChange('timerProvider', state);
  }
}
```

---

## 🎯 调试工作流程

### 场景 1: 应用崩溃

1. 运行调试脚本：
   ```bash
   ./AIReference/debug_ios_app.sh
   ```

2. 脚本会自动检测崩溃并生成崩溃报告

3. 查看崩溃报告：
   ```bash
   cat AIReference/debug_reports/crash_report_*.md
   ```

4. 根据报告中的建议修复问题

5. 重新运行调试脚本验证修复

### 场景 2: 应用黑屏

1. 运行调试脚本：
   ```bash
   ./AIReference/debug_ios_app.sh
   ```

2. 等待 60 秒监控期结束

3. 运行日志分析：
   ```bash
   python3 AIReference/analyze_logs.py
   ```

4. 查看分析报告，检查：
   - 是否有 widget 构建错误
   - 是否有路由配置错误
   - 是否有状态管理错误

5. 根据分析结果修复问题

### 场景 3: 查看详细日志

1. 运行调试脚本后，查看日志文件：
   ```bash
   # iOS 系统日志
   cat AIReference/debug_logs/ios_log_*.log
   
   # Flutter 日志
   cat AIReference/debug_logs/flutter_log_*.log
   
   # 构建日志
   cat AIReference/debug_logs/build_*.log
   ```

2. 使用 grep 搜索特定内容：
   ```bash
   # 搜索错误
   grep -i "error" AIReference/debug_logs/flutter_log_*.log
   
   # 搜索特定 widget
   grep "HomeScreen" AIReference/debug_logs/flutter_log_*.log
   
   # 搜索崩溃
   grep -i "crash\|fatal" AIReference/debug_logs/ios_log_*.log
   ```

---

## 🛠️ 高级用法

### 自定义日志级别

```dart
// 在生产环境中降低日志级别
_logger = Logger(
  level: kReleaseMode ? Level.warning : Level.debug,
  // ...
);
```

### 导出日志文件

```dart
final logger = AppLogger();
final logContent = await logger.getLogFileContent();
print(logContent);
```

### 手动生成崩溃报告

```dart
final errorMonitor = ErrorMonitor();
final report = await errorMonitor.generateCrashReport(
    error, 
    stackTrace, 
    context: 'ManualReport'
);
print(report);
```

---

## 📋 故障排查

### 脚本无法运行

**问题：** `bash: ./AIReference/debug_ios_app.sh: Permission denied`

**解决：**
```bash
chmod +x AIReference/debug_ios_app.sh
```

### 找不到设备

**问题：** `No iOS device found`

**解决：**
1. 检查设备是否连接
2. 检查设备是否解锁
3. 检查 Xcode 能否识别设备
4. 手动指定设备 ID：
   ```bash
   DEVICE_ID=your_device_id ./AIReference/debug_ios_app.sh
   ```

### Python 脚本无法运行

**问题：** `python3: command not found`

**解决：**
1. 安装 Python 3
2. 或者使用 `python` 而不是 `python3`

### 日志为空

**问题：** 日志文件没有内容

**解决：**
1. 确保应用已启动
2. 检查日志权限
3. 尝试手动收集日志：
   ```bash
   flutter logs -d your_device_id
   ```

---

## 📚 相关资源

- [iOS 真机部署指南](./ios_real_device_deployment_guide.md)
- [iOS 真机调试排错文档](./ios_real_device_troubleshooting.md)
- [Logger 包文档](https://pub.dev/packages/logger)
- [Sentry Flutter 包文档](https://pub.dev/packages/sentry_flutter)

---

## 🎉 下一步

现在你可以：

1. ✅ 运行调试脚本：`./AIReference/debug_ios_app.sh`
2. ✅ 查看日志文件：`cat AIReference/debug_logs/*.log`
3. ✅ 分析日志：`python3 AIReference/analyze_logs.py`
4. ✅ 根据分析结果修复问题
5. ✅ 重新运行验证修复

如果遇到问题，请查看生成的报告或运行分析脚本获取诊断信息。
