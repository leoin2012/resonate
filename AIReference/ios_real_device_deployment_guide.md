# iOS 真机部署配置指南

**项目**: Resonate - 触觉视觉专注与呼吸应用  
**配置日期**: 2026-01-19  
**目标设备**: iPhone 14 Pro  
**部署目标**: 在真机上测试和调试应用

---

## 📱 当前设备状态

**检测结果**:
- 设备名称: 刘舒畅的 iPhone
- 状态: 未配对 (Unpaired)
- 错误信息: `Pair with the device in the Xcode Devices Window, and respond to any pairing prompts on the device`

---

## 🔧 配置步骤

### 步骤 1: 在 Xcode 中配对设备

**必须操作**（需要你在Mac上完成）：

1. 打开 Xcode
2. 在菜单栏选择 `Window` → `Devices and Simulators` (或按 `⇧⌘2`)
3. 在左侧找到你的 iPhone 14 Pro
4. 点击设备名称，会出现配对提示
5. 在 iPhone 上确认信任此电脑（会弹出"要信任此电脑吗？"对话框）
6. 在 iPhone 上输入锁屏密码确认

**验证配对成功**:
配对成功后，Xcode 的 Devices 窗口中会显示：
- 设备名称和型号
- iOS 版本
- 日志输出区域（绿色圆形图标）

---

### 步骤 2: 配置代码签名

#### 方式 A: 使用 Apple ID 免费签名（推荐个人开发）

**优点**:
- 免费使用
- 7天内自动续签
- 适合开发测试

**配置步骤**:

1. 打开 Xcode 项目：
   ```bash
   open ios/Runner.xcworkspace
   ```

2. 在 Xcode 中：
   - 选择项目 `Runner` → 选择 `Runner` target
   - 点击 `Signing & Capabilities` 标签
   - 勾选 `Automatically manage signing`
   - 在 `Team` 下拉框中选择你的 Apple ID（或点击 `Add Account` 登录）

3. 如果没有 Apple ID，点击 `Add Account`：
   - 输入 Apple ID 和密码
   - 同意条款
   - 返回选择 Team

4. 配置完成后，Xcode 会自动生成：
   - 证书（Certificate）
   - App ID
   - Provisioning Profile

#### 方式 B: 使用 Apple Developer 账号

**优点**:
- 更稳定的签名
- 可以发布到 App Store
- 适合正式开发

**配置步骤**:
1. 登录 [Apple Developer Portal](https://developer.apple.com/account/)
2. 创建 App ID（Bundle ID: `com.example.resonate`）
3. 创建 Development 证书
4. 创建 Provisioning Profile
5. 在 Xcode 中手动配置这些资源

---

### 步骤 3: 配置项目 Info.plist

确保以下权限和配置正确：

```xml
<!-- 位置权限（如果需要） -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要位置权限以提供更好的体验</string>

<!-- 触觉反馈权限（iOS 10+ 自动支持） -->

<!-- 网络权限 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <false/>
</dict>
```

---

### 步骤 4: 验证设备信任

在 iPhone 上完成以下步骤：

1. 打开 `设置` → `通用` → `VPN与设备管理`
2. 找到你的开发者证书
3. 点击证书名称 → 点击"信任" → 确认信任

**重要**: 首次安装后，应用图标可能显示为灰色，需要手动信任开发者证书。

---

### 步骤 5: 构建和部署到真机

#### 使用 Xcode 直接部署（推荐）

```bash
# 1. 在 Xcode 中选择设备
# 在工具栏的设备选择器中选择你的 iPhone 14 Pro

# 2. 点击运行按钮 (⌘R)
# 或者在命令行中执行：
cd ios
xcodebuild -workspace Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=iOS,name=刘舒畅的 iPhone' \
  -allowProvisioningUpdates \
  build
```

#### 使用 Flutter CLI（需要先修复 Flutter 环境问题）

```bash
# 先配对设备
flutter devices

# 安装到真机
flutter run -d "刘舒畅的 iPhone"
```

---

## 🐛 常见问题排查

### 问题 1: 设备未配对

**错误信息**:
```
is not available because it is unpaired
```

**解决方案**:
1. 拔掉 USB 线，重新插入
2. 在 iPhone 上重启"信任此电脑"流程
3. 在 Xcode 中重新打开 Devices 窗口

---

### 问题 2: 代码签名错误

**错误信息**:
```
Code signing is required for product type 'Application' in SDK 'iOS'
```

**解决方案**:
1. 检查 Xcode 中是否勾选了 `Automatically manage signing`
2. 确保 Team 已正确选择
3. 尝试删除旧的 Provisioning Profile，让 Xcode 重新生成
4. 如果使用免费 Apple ID，确保网络连接正常（需要联网验证）

---

### 问题 3: 证书信任问题

**现象**:
- 应用安装成功但无法打开
- 应用图标显示为灰色

**解决方案**:
1. 打开 iPhone 的 `设置` → `通用` → `VPN与设备管理`
2. 找到开发者应用
3. 点击"信任 [开发者邮箱]"

---

### 问题 4: Bundle ID 冲突

**错误信息**:
```
The bundle identifier com.example.resonate cannot be used
```

**解决方案**:
修改 Bundle ID 为唯一标识：

1. 在 Xcode 中：
   - 打开 `Signing & Capabilities`
   - 修改 `Bundle Identifier` 为 `com.yourname.resonate`

2. 或在 `ios/Runner/Info.plist` 中：
   ```xml
   <key>CFBundleIdentifier</key>
   <string>com.yourname.resonate</string>
   ```

---

## 📋 真机测试检查清单

部署前确认：
- [ ] iPhone 已通过 USB 连接到 Mac
- [ ] 在 Xcode Devices 窗口中已配对设备
- [ ] 已配置代码签名（Automatically manage signing 已勾选）
- [ ] Team 已正确选择（Apple ID 或 Developer 账号）
- [ ] iPhone 上已信任开发者证书
- [ ] Bundle ID 配置正确且无冲突

部署后验证：
- [ ] 应用成功安装到 iPhone
- [ ] 应用可以正常启动
- [ ] 呼吸计时器功能正常
- [ ] 触觉反馈可以触发
- [ ] 设置页面功能正常
- [ ] 历史记录可以保存和查看

---

## 🎯 性能测试建议

在真机上测试以下方面：

1. **动画流畅度**
   - 检查呼吸圆圈动画是否达到 60fps
   - 使用 Flutter DevTools 监控帧率

2. **触觉反馈**
   - 验证触觉反馈的时机和强度
   - 测试不同震动模式

3. **电池消耗**
   - 运行应用 10-15 分钟
   - 检查电池消耗情况

4. **内存占用**
   - 使用 Xcode Instruments 监控内存
   - 确保没有内存泄漏

---

## 📊 调试工具推荐

### Xcode Instruments
- 性能分析
- 内存泄漏检测
- CPU 和 GPU 使用率

### Flutter DevTools
```bash
flutter attach
# 或在 VS Code 中使用 Flutter 扩展
```

### Console.app
- 查看 iOS 系统日志
- 调试原生层面的问题

---

## 🚀 下一步行动

**需要你手动完成的操作**：

1. **立即执行**:
   - 打开 Xcode (⌘Space，输入 "Xcode")
   - 菜单栏：Window → Devices and Simulators
   - 在左侧找到你的 iPhone，点击配对
   - 在 iPhone 上确认信任

2. **配对成功后**:
   - 在 Xcode 中打开项目: `open ios/Runner.xcworkspace`
   - 配置签名：选择 Runner target → Signing & Capabilities
   - 勾选 "Automatically manage signing"
   - 选择你的 Team (Apple ID)

3. **准备完成后告诉我**:
   - "我已经完成配对"
   - "签名已配置好"
   - 然后我会帮你执行构建命令

---

**文档生成时间**: 2026-01-19 14:48:54  
**最后更新**: 2026-01-19 14:48:54  
**维护者**: AI Assistant
