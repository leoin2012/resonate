# Resonate iOS 真机调试安装流程文档

## 📱 设备信息

- **设备名称**: shuchangliu的iPhone
- **设备ID**: d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f
- **设备型号**: iPhone 6s (N71AP)
- **系统版本**: iOS 15.8.4 (19H390)
- **架构**: arm64

## 🔐 开发者账号与签名

### 代码签名身份
```
1) 8CBF9136ED11E018B374EDBB86A41AFF528E6BF0 "Apple Development: 278886678@qq.com (64A3843N7T)"
2) B58AA6482606B5D68850997FF20905908DBAA9DB "Apple Development: zhong jianbin (Y68J4EHQT9)"
```

### Xcode 项目配置
- **DEVELOPMENT_TEAM**: 93M3ENDGKH
- **CODE_SIGN_STYLE**: Automatic
- **CODE_SIGN_IDENTITY**: iPhone Developer
- **CODE_SIGN_REQUIRED**: YES

## 🚀 完整安装流程

### 步骤 1: 环境检查

```bash
# 检查连接的设备
flutter devices

# 检查代码签名身份
security find-identity -v -p codesigning
```

### 步骤 2: 清理项目

```bash
# 清理 Flutter 构建缓存
flutter clean

# 清理 iOS 构建产物
rm -rf build ios/Pods ios/Podfile.lock ios/.symlinks
rm -rf ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec
```

### 步骤 3: 更新依赖

```bash
# 获取 Flutter 依赖
flutter pub get
```

### 步骤 4: 安装 CocoaPods 依赖

```bash
cd ios
pod install
cd ..
```

**注意**: 可能会看到以下警告,可以忽略:
```
[!] CocoaPods did not set the base configuration of your project because your project already has a custom config set.
```

### 步骤 5: 使用 Xcode 直接构建

⚠️ **关键步骤**: 不要使用 `flutter build ios`,而是直接使用 xcodebuild:

```bash
cd ios

xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination 'id=d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f' \
  -allowProvisioningUpdates build

cd ..
```

**参数说明**:
- `-workspace`: 使用 `.xcworkspace` 文件(包含 CocoaPods 依赖)
- `-scheme Runner`: 构建目标
- `-configuration Release`: Release 配置
- `-destination`: 指定目标设备 ID
- `-allowProvisioningUpdates`: 允许自动更新证书

### 步骤 6: 部署到真机

```bash
# 使用 ios-deploy 安装应用
ios-deploy --id d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f \
  --bundle /Users/shuchangliu/Library/Developer/Xcode/DerivedData/Runner-bbkvzlhbqtuvsmfliwnyxbnemwrv/Build/Products/Release-iphoneos/Runner.app \
  --noninteractive
```

**注意**: DerivedData 路径中的 `Runner-bbkvzlhbqtuvsmfliwnyxbnemwrv` 是随机生成的,需要根据实际构建日志中的路径调整。

## ❌ 遇到的问题及解决方案

### 问题 1: CocoaPods 同步失败

**错误信息**:
```
The sandbox is not in sync with the Podfile.lock. Run 'pod install' or update your CocoaPods installation.
```

**解决方案**: 执行 `cd ios && pod install`

### 问题 2: 代码签名失败

**错误信息**:
```
Error (Xcode): Target release_unpack_ios failed: Exception: Failed to codesign .../Flutter.framework/Flutter with identity ...
```

**原因**: 使用 `flutter build ios` 时会尝试对 Flutter framework 进行代码签名,但签名配置可能不匹配。

**解决方案**: 使用 xcodebuild 直接构建,让 Xcode 自动处理签名。

### 问题 3: 应用已安装但无法启动

**错误信息**:
```
Unable to launch com.joyera.resonate because it has an invalid code signature, inadequate entitlements or its profile has not been explicitly trusted by the user.
```

**解决方案**: 
1. 确保在 iOS 设备上信任开发者证书
2. 设置 -> 通用 -> VPN与设备管理 -> 信任开发者

## 📋 快速执行脚本

创建 `scripts/install_to_device.sh`:

```bash
#!/bin/bash

# 设备 ID
DEVICE_ID="d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f"

# 清理项目
echo "🧹 清理项目..."
flutter clean
rm -rf build ios/Pods ios/Podfile.lock ios/.symlinks
rm -rf ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec

# 更新依赖
echo "📦 更新依赖..."
flutter pub get
cd ios
pod install
cd ..

# 构建
echo "🔨 构建应用..."
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Release \
  -destination "id=$DEVICE_ID" \
  -allowProvisioningUpdates build | tee ../AIReference/build.log

cd ..

# 获取 DerivedData 路径
DERIVED_DATA_PATH=$(grep "BUILD_DIR" AIReference/build.log | head -1 | sed 's/.*= //' | sed 's/\/Build.*//')

if [ -z "$DERIVED_DATA_PATH" ]; then
    echo "❌ 无法获取 DerivedData 路径"
    exit 1
fi

echo "📱 DerivedData 路径: $DERIVED_DATA_PATH"

# 安装到设备
echo "📲 安装到设备..."
ios-deploy --id "$DEVICE_ID" \
  --bundle "$DERIVED_DATA_PATH/Build/Products/Release-iphoneos/Runner.app" \
  --noninteractive

echo "✅ 安装完成!"
```

使用方法:
```bash
chmod +x scripts/install_to_device.sh
./scripts/install_to_device.sh
```

## 📝 重要注意事项

### 1. 依赖管理
- 当前项目已注释掉所有第三方依赖
- 如需恢复依赖,取消 [pubspec.yaml](/Users/shuchangliu/Library/CloudStorage/OneDrive-个人/文档/Project/Flutter/resonate/pubspec.yaml) 中的注释即可

### 2. 路径问题
- 项目路径包含中文字符 `OneDrive-个人`,某些构建工具可能不支持
- 如果遇到路径相关错误,建议将项目移至纯英文路径

### 3. 证书管理
- 开发者证书会定期过期,需要及时更新
- 在 Xcode 中配置自动管理签名,避免手动配置错误

### 4. 构建配置
- Release 模式: 用于发布或性能测试
- Debug 模式: 用于调试,可通过修改 `-configuration Debug` 切换

### 5. 设备信任
- 首次安装后,需要在 iOS 设备上手动信任开发者证书
- 路径: 设置 -> 通用 -> VPN与设备管理

## 🔍 验证安装

在真机上验证应用:
1. 检查应用是否已安装到主屏幕
2. 启动应用,查看是否能正常运行
3. 测试基本功能:
   - 显示 "HELLO WORLD" 文字
   - 点击 "Click me" 按钮响应
   - 显示 SnackBar 提示

## 📚 参考资源

- [Flutter iOS 部署官方文档](https://docs.flutter.dev/deployment/ios)
- [CocoaPods 官方文档](https://cocoapods.org/)
- [ios-deploy GitHub](https://github.com/ios-control/ios-deploy)
- [Xcode 代码签名指南](https://developer.apple.com/support/code-signing/)

## 📅 更新记录

- **2026-01-20**: 初始文档创建,记录完整的真机安装流程
- 极简版本(无第三方依赖)成功构建并安装到 iPhone 6s (iOS 15.8.4)

---

**文档维护**: 以后每次调试安装真机步骤都严格按此执行
