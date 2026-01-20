# iOS 白屏问题排查与修复

## 问题描述

应用在 iPhone 6s (iOS 15.8.4) 上启动后显示白屏，无法看到 Flutter 应用界面。

## 问题分析

### 可能原因

1. **LaunchScreen 背景色问题**
   - 默认的 LaunchScreen.storyboard 背景为白色
   - 如果 Flutter 应用未正常加载或启动慢，用户会看到白屏

2. **Flutter 应用启动失败**
   - 依赖未正确加载
   - 代码错误导致崩溃
   - 权限问题

3. **应用启动延迟**
   - 首次加载 Flutter 引擎需要时间
   - 大量初始化代码阻塞主线程

### 排查步骤

#### Step 1: 检查 LaunchScreen 背景色

```bash
# 查看当前背景色配置
cat ios/Runner/Base.lproj/LaunchScreen.storyboard | grep "backgroundColor"
```

**修复方法**：
将背景色从白色改为深黑色：

```xml
<!-- 修改前 -->
<color key="backgroundColor" red="1" green="1" blue="1" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>

<!-- 修改后 -->
<color key="backgroundColor" red="0.0392156862745098" green="0.0392156862745098" blue="0.0392156862745098" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

#### Step 2: 检查 Flutter 应用代码

确保 `main.dart` 有正确的初始界面：

```dart
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Resonate',
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: Colors.black, // 黑色背景
        body: Center(
          child: Text(
            'Resonate App',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
```

#### Step 3: 查看设备日志

使用 `idevicesyslog` 查看实时日志：

```bash
# 监听特定应用的日志
idevicesyslog -u d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f 2>&1 | grep -i -E "(runner|flutter|resonate|error|crash|exception)"
```

#### Step 4: 使用 flutter run 调试

获取详细的启动信息：

```bash
flutter run -d d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f --debug --verbose
```

## 已实施的修复

### 修复 1: 更改 LaunchScreen 背景色

**文件**：`ios/Runner/Base.lproj/LaunchScreen.storyboard`

**修改内容**：
```xml
<!-- Line 22 -->
<color key="backgroundColor" red="0.0392156862745098" green="0.0392156862745098" blue="0.0392156862745098" alpha="1" colorSpace="custom" customColorSpace="sRGB"/>
```

**效果**：
- 启动画面背景为黑色（`#0A0A0A`）
- 即使 Flutter 应用未立即加载，也不会显示白屏

### 修复 2: 简化应用代码

**文件**：`lib/main.dart`

**当前代码**：
- 基础的 MaterialApp
- 黑色背景
- 白色文字 "Resonate App"

**目的**：
- 排除复杂逻辑导致的启动问题
- 快速验证应用能否正常显示

## 重新构建与安装

### 清理与重新构建

```bash
# 清理构建缓存
flutter clean

# 获取依赖
flutter pub get

# 更新 CocoaPods
cd ios
pod install

# 构建
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'id=d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f' \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=93M3ENDGKH \
  install

# 安装到设备
ios-deploy -b "/Users/shuchangliu/Library/Developer/Xcode/DerivedData/Runner-bbkvzlhbqtuvsmfliwnyxbnemwrv/Build/Intermediates.noindex/ArchiveIntermediates/Runner/InstallationBuildProductsLocation/Applications/Runner.app" \
  -i d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f
```

### 验证安装

```bash
# 检查应用是否存在
ios-deploy -1 com.joyera.resonate -i d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f --exists

# 应该返回: true
```

## 测试步骤

### 在设备上测试

1. **删除旧应用**（如有）
   - 在 iPhone 上长按应用图标
   - 点击 "删除应用"

2. **启动新应用**
   - 在主屏幕找到 "Runner" 图标
   - 点击启动应用

3. **观察显示效果**
   - **情况 A**：看到黑色背景 + "Resonate App" 文字 → ✅ 修复成功
   - **情况 B**：仍然白屏 → ❌ 需要进一步排查
   - **情况 C**：应用崩溃 → ❌ 查看崩溃日志

## 进一步排查建议

### 如果仍然白屏

#### 1. 检查 Info.plist 配置

```bash
# 查看 LaunchScreen 配置
grep -A 2 "UILaunchStoryboardName" ios/Runner/Info.plist
```

应该显示：
```xml
<key>UILaunchStoryboardName</key>
<string>LaunchScreen</string>
```

#### 2. 验证 Flutter 引擎是否正常

```bash
# 使用 flutter run 查看详细输出
flutter run -d d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f --debug
```

关键输出：
```
Launching lib/main.dart on iPhone 6s in debug mode...
Running pod install...
Running Xcode build...
...
Flutter run key commands.
r Hot reload
R Hot restart
h List all available interactive commands
q Quit
```

#### 3. 检查依赖冲突

```bash
# 运行静态分析
flutter analyze

# 检查依赖版本
flutter pub deps
```

#### 4. 查看崩溃日志

```bash
# 监听崩溃日志
idevicesyslog -u d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f 2>&1 | grep -i "crash"
```

## 常见问题与解决方案

| 问题 | 原因 | 解决方案 |
|------|------|---------|
| 启动画面一直显示 | Flutter 引擎未加载 | 检查依赖是否正确安装 |
| 应用立即崩溃 | 代码错误或依赖冲突 | 运行 `flutter analyze` 检查 |
| 白屏但应用在后台运行 | 视图控制器问题 | 检查 AppDelegate 配置 |
| 应用图标显示但无法打开 | 签名或权限问题 | 检查 Code Signing 配置 |

## 相关文档

- [iOS 设备部署最佳实践](./ios_device_deployment_best_practices.md)
- [iOS 调试故障排除](./ios_debug_troubleshooting.md)

## 更新记录

- **2026-01-19**：首次创建文档，记录白屏问题分析与修复过程
  - 修复了 LaunchScreen 背景色
  - 简化了应用代码
  - 重新构建并安装应用
