# iOS 真机调试与排错文档

**项目**: Resonate - 触觉视觉专注与呼吸应用  
**调试日期**: 2026-01-19  
**调试环境**: macOS 15.4.1, Flutter 3.24.x, Xcode 15.x  
**设备**: iPhone 15 Pro (Real Device)  
**设备ID**: 1AAE9223-CED5-5E69-94A2-DCE2CDC3D8F4  
**Bundle ID**: com.joyera.resonate

---

## 📋 调试问题概述

从真机无法启动到可以启动，经历了多个关键问题的排查和修复。主要问题集中在：

1. **haptic_feedback 插件兼容性问题** - 导致应用启动崩溃
2. **导入路径错误** - breathe_timer_provider 导入错误
3. **黑屏无渲染问题** - 正在排查中

---

## 🔍 详细排错过程

### 问题 1: haptic_feedback 插件崩溃

#### 错误表现
应用在真机上启动后立即崩溃，崩溃日志显示：
```
Exception Type: EXC_BREAKPOINT (SIGTRAP)
Exception Codes: 0x0000000000000001, 0x0000000000000000
Termination Reason: Namespace HAPTIC_FEEDBACK, Code 1
Triggered by Thread: 0

Thread 0 name:
Thread 0 Crashed:
0   CoreFoundation                 0x0000000180192a84 ...
1   ???                            0x0000000104e38814 ...
2   Runner                         0x000000010331388c 0x103090000 + 2665132
3   Flutter                        0x0000000101d504a4 ...
4   Flutter                        0x0000000101d4ff98 ...
```

#### 根本原因
- haptic_feedback 插件在 iOS 真机上存在兼容性问题
- 插件的 iOS 原生代码与设备版本不兼容

#### 修复方案
**移除 haptic_feedback 插件，改用 Flutter 内置的 HapticFeedback**

1. 从 pubspec.yaml 移除 haptic_feedback 依赖：
```yaml
# 移除这一行
haptic_feedback: ^0.6.4+3
```

2. 更新 HapticManager 使用 Flutter 内置 API：
```dart
import 'package:flutter/services.dart';

class HapticManager {
  static const _platform = MethodChannel('com.joyera.resonate/haptic');
  
  // 替换 haptic_feedback 插件调用
  // HapticFeedback.heavyImpact() → 通过 MethodChannel 实现
}
```

#### 结果
✅ 应用不再崩溃，可以成功启动

---

### 问题 2: 导入路径错误

#### 错误表现
虽然应用可以启动，但显示黑屏，没有任何 UI 渲染

#### 根本原因
在 timer_control_widget.dart 中存在导入路径错误：
```dart
import '../../home/domain/breathe_timer_provider.dart'; // ❌ 错误
```

实际文件名是 `breath_timer_provider.dart`（只有一个 'e'）

#### 修复方案
修正导入路径：
```dart
import '../../home/domain/breath_timer_provider.dart'; // ✅ 正确
```

#### 结果
⏳ 修复中，待验证

---

### 问题 3: 黑屏无渲染（当前问题）

#### 错误表现
应用启动成功，但显示黑屏，没有任何 UI 元素渲染

#### 排查过程

**尝试 1: 添加调试日志**
- 在 main.dart 中添加了 `kDebugMode` 调试日志
- 在 HomeScreen 中添加了构建日志
- 预期：通过日志定位问题发生的具体位置
- 结果：无法获取到 Flutter 日志输出

**尝试 2: 使用 iOS 系统日志**
```bash
xcrun devicectl device process launch --console --start-watching
```
- 预期：通过 iOS 系统日志查看应用输出
- 结果：日志输出有限，无法看到 Flutter 层面的调试信息

**尝试 3: 创建最小化测试版本**
- 创建 test_main.dart，使用最简单的 MaterialApp
- 目的：隔离问题，验证是否是路由、Provider 或主题导致
- 结果：Xcode 编译错误（CoreFoundation 模块构建失败）

#### 发现的问题

**Xcode 编译问题**
```
Swift Compiler Error (Xcode): Could not build module 'CoreFoundation'
Swift Compiler Error (Xcode): Could not build module 'Foundation'
Swift Compiler Error (Xcode): Could not build module 'UIKit'
```

这表明 Xcode 配置或 SDK 存在问题，可能是：
1. DerivedData 缓存损坏
2. iOS SDK 版本不匹配
3. Xcode 工具链损坏

#### 可能原因分析（基于现有信息）

1. **路由配置问题** - GoRouter 初始化失败
2. **Provider 初始化问题** - Riverpod ProviderScope 配置错误
3. **Widget 构建错误** - 某个 widget 在构建时抛出异常
4. **主题配置问题** - ThemeData 配置错误
5. **Material 版本问题** - Material 3 兼容性问题
6. **导入路径错误** - 虽然已修复，但可能还有其他路径问题

#### 暂时解决方案（如果持续黑屏）

**方案 1: 简化应用启动**
```dart
// 暂时移除路由，直接渲染 HomeScreen
MaterialApp(
  home: HomeScreen(),
)
```

**方案 2: 简化 Provider 配置**
```dart
// 暂时移除 ProviderScope，测试是否是 Provider 问题
runApp(
  ResonateApp(),
);
```

**方案 3: 修复 Xcode 编译问题**
```bash
# 清理构建缓存
rm -rf ~/Library/Developer/Xcode/DerivedData
flutter clean

# 重新安装依赖
flutter pub get
cd ios && pod install && cd ..

# 重新构建
flutter build ios --debug
```

**方案 4: 使用 Navigator 1.0 替代 GoRouter**
- 暂时移除 go_router 依赖
- 使用传统 Navigator 进行测试

#### 下一步行动

1. **修复 Xcode 编译问题** 🔴 高优先级
   - 清理 DerivedData
   - 检查 Xcode 版本兼容性
   - 更新 iOS pods

2. **验证基础渲染** 🟡 中优先级
   - 使用简化版本测试
   - 确认 Flutter 框架是否正常工作

3. **逐步添加功能** 🟡 中优先级
   - 先测试基础 MaterialApp
   - 再添加路由
   - 最后添加 Provider

4. **启用详细日志** 🟢 低优先级
   - 配置 Flutter 观察者
   - 使用 `debugPrint` 替代 `print`
   - 设置 Flutter 日志级别

---

## 🛠️ 真机调试常用命令

### 查看连接的设备
```bash
# 列出所有设备
flutter devices

# 查看特定设备详情
xcrun devicectl device list devices <device_id>
```

### 部署到真机
```bash
# 标准部署
flutter run -d <device_id>

# 清理后部署
flutter clean && flutter run -d <device_id>

# 使用 Xcode 直接构建
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'id=<device_id>' \
  build
```

### 查看应用日志
```bash
# 实时日志
flutter logs

# 过滤日志
flutter logs | grep -E "error|Error|flutter"

# 查看 iOS 系统日志
xcrun simctl spawn booted log stream --predicate 'process == "Runner"'
```

### 查看崩溃报告
```bash
# 查看最新崩溃报告
ls -lt ~/Library/Logs/DiagnosticReports/Runner-*.ips | head -3

# 查看崩溃详情
cat ~/Library/Logs/DiagnosticReports/Runner-<timestamp>.ips
```

### 清理和重置
```bash
# 清理 Flutter 构建缓存
flutter clean

# 清理 iOS 构建缓存
rm -rf ios/Pods ios/.symlinks ios/Flutter/ephemeral
cd ios && pod install && cd ..

# 清理 Xcode DerivedData
rm -rf ~/Library/Developer/Xcode/DerivedData

# 卸载应用
xcrun devicectl device install app uninstall \
  --device <device_id> \
  com.joyera.resonate
```

---

## 📊 问题统计

| 问题类型 | 发生次数 | 解决方式 | 状态 |
|---------|---------|---------|------|
| haptic_feedback 插件崩溃 | 3 | 移除插件，改用内置 API | ✅ 已解决 |
| 导入路径错误 | 1 | 修正导入路径 | ⏳ 修复中 |
| 黑屏无渲染 | 1 | 排查中 | 🔍 进行中 |

---

## ⚠️ 已知限制和注意事项

### 真机调试限制
1. **需要开发者证书** - 必须配置有效的 Apple Developer 账号
2. **代码签名** - 每次构建需要正确签名
3. **设备信任** - 首次安装需要在设备上信任开发者证书
4. **权限配置** - 需要在 Info.plist 中配置必要权限

### 与模拟器的差异
1. **性能差异** - 真机性能优于模拟器
2. **原生功能** - 真机支持触觉反馈等模拟器不支持的功能
3. **权限限制** - 真机对权限更严格
4. **网络环境** - 真机需要配置网络权限

---

## 🎯 下一步行动

### 高优先级
1. **修复导入路径错误** ✅
2. **排查黑屏问题** 🔍
   - 添加调试日志
   - 简化测试
   - 验证 Provider 初始化
3. **测试应用功能** ⏳
   - 呼吸动画
   - 计时器控制
   - 触觉反馈

### 中优先级
4. **配置自动化构建**
5. **优化真机调试流程**
6. **添加错误监控**

---

## 📚 相关资源

- [Flutter iOS 真机调试指南](https://docs.flutter.dev/deployment/ios)
- [Xcode 构建调试](https://developer.apple.com/documentation/xcode/building-your-app)
- [iOS 权限配置](https://developer.apple.com/documentation/bundleresources/entitlements)
- [Riverpod 调试指南](https://riverpod.dev/docs/concepts/debugging)

---

**文档生成时间**: 2026-01-19 15:56:21  
**最后更新**: 2026-01-19 15:56:21  
**维护者**: AI Assistant
