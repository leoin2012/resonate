# iOS 真机安装最佳实践

## 概述

本文档记录了在 Mac 环境下将 Flutter 应用成功构建并安装到 iOS 真机的完整流程。

## 前提条件

- 已安装 Xcode
- 已配置开发者账号（Apple Developer）
- iOS 设备已连接并信任
- Xcode 中已配置 Code Signing

## 设备信息

**测试设备**：
- 设备：iPhone 6s
- iOS 版本：15.8.4
- 设备 ID：`d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f`

**签名配置**：
- 开发团队 ID：`93M3ENDGKH`
- 签名身份：`Apple Development: 278886678@qq.com`
- 配置文件：`iOS Team Provisioning Profile`

---

## 成功安装步骤

### 方法一：使用 xcodebuild + ios-deploy（推荐）

这是经过验证的最可靠方法，避免了 flutter run 可能遇到的问题。

#### Step 1: 构建 Debug 版本

```bash
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'id=d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f' \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=93M3ENDGKH \
  install
```

**关键参数说明**：
- `-workspace Runner.xcworkspace`：使用工作区（包含 CocoaPods）
- `-scheme Runner`：指定构建方案
- `-configuration Debug`：使用 Debug 配置
- `-destination 'id=...'`：指定目标设备 ID
- `-allowProvisioningUpdates`：允许自动更新配置文件
- `CODE_SIGN_STYLE=Automatic`：自动签名
- `DEVELOPMENT_TEAM=93M3ENDGKH`：指定开发团队

#### Step 2: 安装 .app 文件到设备

构建完成后，使用 `ios-deploy` 直接安装应用包：

```bash
ios-deploy \
  -b "/Users/shuchangliu/Library/Developer/Xcode/DerivedData/Runner-bbkvzlhbqtuvsmfliwnyxbnemwrv/Build/Intermediates.noindex/ArchiveIntermediates/Runner/InstallationBuildProductsLocation/Applications/Runner.app" \
  -i d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f
```

**关键点**：
- `.app` 文件路径需根据实际 DerivedData 路径调整
- 确保使用 `ios-deploy -b` 命令直接安装
- 不要仅依赖 xcodebuild 的 install 目标

#### Step 3: 验证安装

```bash
# 检查应用是否存在
ios-deploy -1 com.joyera.resonate -i d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f --exists

# 查看已安装应用列表
ios-deploy -l -i d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f
```

---

### 方法二：使用 flutter run（备选）

如果方法一失败，可以尝试使用 Flutter 官方命令：

```bash
flutter run -d d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f --debug
```

**注意事项**：
- 可能遇到超时问题
- 需要较长的构建时间
- 建议添加 `--timeout 600` 延长超时时间

---

## 常见问题排查

### 问题 1：xcodebuild 显示安装成功但设备上没有应用

**原因**：xcodebuild 的 `install` 目标可能不会真正将应用推送到设备

**解决方案**：使用 `ios-deploy -b` 明确安装 `.app` 文件

### 问题 2：签名错误

**错误信息**：`Code signing is required`

**解决方案**：
1. 在 Xcode 中打开项目：`open ios/Runner.xcworkspace`
2. 在 "Signing & Capabilities" 中配置 Team
3. 设置 `CODE_SIGN_STYLE=Automatic`
4. 设置 `DEVELOPMENT_TEAM` 为你的 Team ID

### 问题 3：设备未连接或未信任

**检查命令**：
```bash
# 查看连接的设备
idevice_id -l

# 查看设备详细信息
ideviceinfo -u d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f
```

### 问题 4：找不到 DerivedData 路径

**解决方案**：
1. 构建完成后，Xcode 会输出实际路径
2. 使用以下命令查找：
   ```bash
   find ~/Library/Developer/Xcode/DerivedData -name "Runner.app" 2>/dev/null
   ```

---

## 快速安装脚本

创建一个自动化脚本 `AIReference/install_to_ios_device.sh`：

```bash
#!/bin/bash

DEVICE_ID="d53ae895c9e8e460719de6e4f9dde63b7cbd1a9f"
TEAM_ID="93M3ENDGKH"
BUNDLE_ID="com.joyera.resonate"

echo "🔨 Building iOS app..."
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination "id=$DEVICE_ID" \
  -allowProvisioningUpdates \
  CODE_SIGN_STYLE=Automatic \
  DEVELOPMENT_TEAM=$TEAM_ID \
  install

# 查找构建的 .app 文件
APP_PATH=$(find ~/Library/Developer/Xcode/DerivedData -name "Runner.app" 2>/dev/null | head -n 1)

if [ -z "$APP_PATH" ]; then
  echo "❌ Failed to find Runner.app"
  exit 1
fi

echo "📱 Installing to device..."
ios-deploy -b "$APP_PATH" -i $DEVICE_ID

echo "✅ Installation complete!"
echo "📲 Launching app..."
ios-deploy -1 $BUNDLE_ID -i $DEVICE_ID --launch
```

使用方法：
```bash
chmod +x AIReference/install_to_ios_device.sh
./AIReference/install_to_ios_device.sh
```

---

## 最佳实践总结

1. **优先使用 xcodebuild + ios-deploy 组合**
   - 更稳定、更可控
   - 避免了 flutter run 的复杂性

2. **始终验证安装**
   - 使用 `ios-deploy --exists` 确认应用存在
   - 不要仅依赖构建工具的输出

3. **固定设备 ID**
   - 避免使用模糊的设备名称
   - 使用 `idevice_id -l` 获取准确 ID

4. **记录构建路径**
   - DerivedData 路径会随项目名称变化
   - 使用 `find` 命令动态查找

5. **签名配置**
   - 使用自动签名（Automatic）
   - 确保 Team ID 正确

---

## 更新记录

- **2026-01-19**：首次创建文档，记录成功安装到 iPhone 6s (iOS 15.8.4) 的完整流程
