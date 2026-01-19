# iOS 平台搭建与 App Store 发布指南

**日期**: 2026-01-19
**项目**: Resonate
**目标平台**: iOS

---

## 📋 概述

本指南涵盖了在 iOS 上测试 Resonate 并准备 App Store 发布的所有必要步骤。

---

## 🛠️ 第一部分：Mac 环境搭建

### 1.1 硬件要求

- **Mac 电脑**，推荐使用 Apple Silicon (M1/M2/M3)
- 最少 16GB 内存
- 至少 50GB 可用磁盘空间用于 Xcode 和工具

### 1.2 软件要求

| 软件 | 最低版本 | 推荐版本 | 用途 |
|------|----------|----------|------|
| macOS | Sonoma 14.0+ | Sonoma 14.5+ | 操作系统 |
| Xcode | 15.0+ | 15.2+ | iOS 开发 |
| Xcode 命令行工具 | 15.0+ | 15.2+ | 构建工具 |
| CocoaPods | 1.14.0+ | 1.15.0+ | 依赖管理 |

### 1.3 安装步骤

```bash
# 步骤 1: 从 Mac App Store 安装 Xcode
# 或从以下地址下载：https://developer.apple.com/download/all/

# 步骤 2: 安装命令行工具
xcode-select --install

# 步骤 3: 接受 Xcode 许可协议
sudo xcodebuild -license accept

# 步骤 4: 安装 CocoaPods
sudo gem install cocoapods

# 步骤 5: 验证安装
xcodebuild -version
xcrun --show-sdk-path
```

### 1.4 Flutter iOS 配置

```bash
# 步骤 1: 将项目克隆到 Mac
git clone <your-repo-url>
cd resonate

# 步骤 2: 获取 Flutter 依赖
flutter pub get

# 步骤 3: 验证 Flutter Doctor
flutter doctor -v

# 步骤 4: 清理 iOS 构件（如果有）
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData

# 步骤 5: 安装 iOS 依赖
pod install
```

---

## 📱 第二部分：Apple Developer 账户设置

### 2.1 账户类型

| 账户类型 | 费用 | 功能 | 适合对象 |
|--------------|------|----------|----------|
| 个人 | $99/年 | 上传到 App Store、TestFlight | 个人开发者 |
| 组织 | $99/年 | 个人账户功能 + 团队功能 | 公司 |
| 企业 | $299/年 | 仅限内部分发 | 大型企业 |

**推荐**：从**个人**账户开始

### 2.2 账户注册

1. 访问 [Apple Developer](https://developer.apple.com/programs/enroll/)
2. 使用 Apple ID 登录
3. 选择注册类型
4. 提供个人/商业信息
5. 支付年费（$99）
6. 等待审核（通常 1-3 天）

### 2.3 App Store Connect 设置

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 完善个人资料：
   - 法律信息
   - 银行信息（用于收款）
   - 税务表（美国或国际）
3. 创建你的第一个应用（可以稍后进行）

---

## 📲 第三部分：iOS 应用配置

### 3.1 更新 Bundle Identifier

**文件**: `lib/main.dart`

```dart
void main() async {
  // ... 现有代码 ...
  runApp(const ProviderScope(child: ResonateApp()));
}
```

**文件**: `ios/Runner/Info.plist`

```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.resonate</string>

<key>CFBundleDisplayName</key>
<string>Resonate</string>

<key>CFBundleShortVersionString</key>
<string>1.0.0</string>

<key>CFBundleVersion</key>
<string>1</string>
```

### 3.2 应用权限（隐私信息）

**文件**: `ios/Runner/Info.plist`

```xml
<!-- 触觉反馈 -->
<key>NSHapticFeedbackUsageDescription</key>
<string>Resonate 使用触觉反馈来增强你的呼吸体验。</string>

<!-- iOS 14+ 需要 -->
<key>NSUserTrackingUsageDescription</key>
<string>我们不会跟踪你的数据。此权限仅因系统要求而显示。</string>
```

### 3.3 应用图标

**所需尺寸**：创建多种尺寸的图标

```bash
# 使用 Flutter Launcher Icons
flutter pub run flutter_launcher_icons:main

# 或手动将图标放置到：
# ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

**所需尺寸**：
- 60pt @2x (120x120) - iPhone 应用
- 60pt @3x (180x180) - iPhone 应用
- 76pt @2x (152x152) - iPad 应用
- 167x167 - iPad Pro 应用
- 1024x1024 - App Store 图标

### 3.4 启动屏

**文件**: `ios/Runner/LaunchScreen.storyboard`

保持简洁并与暗色主题匹配：
- 黑色背景
- 居中显示应用 Logo 或名称
- 无复杂动画

---

## 🔐 第四部分：代码签名与配置文件

### 4.1 开发证书

**方法 A：自动管理（推荐用于测试）**

```bash
# 在 Xcode 中：
# 1. 打开 ios/Runner.xcworkspace
# 2. 选择 Runner target
# 3. Signing & Capabilities 标签页
# 4. 勾选"Automatically manage signing"
# 5. 选择你的团队
```

**方法 B：手动管理（App Store 必需）**

```bash
# 创建证书签名请求 (CSR)
# 1. 打开钥匙串访问
# 2. 钥匙串访问 > 证书助理 > 从证书颁发机构请求证书
# 3. 将 CSR 文件保存到磁盘

# 将 CSR 上传到 Apple Developer Portal
# 1. 前往 Certificates, Identifiers & Profiles
# 2. 创建证书 (iOS Development)
# 3. 下载并安装到钥匙串
```

### 4.2 Provisioning Profile

```bash
# 自动签名：
# Xcode 会自动创建

# 手动管理：
# 1. 前往 Apple Developer Portal
# 2. 创建 Provisioning Profile
# 3. 选择 App ID (Bundle ID)
# 4. 选择证书
# 5. 选择设备（用于开发）
# 6. 下载并安装
```

### 4.3 App ID 注册

```bash
# 1. 前往 Apple Developer Portal
# 2. Certificates, Identifiers & Profiles > Identifiers
# 3. 点击"+"创建新 App ID
# 4. 选择 App IDs > App
# 5. 填写：
#    - Description: Resonate - Breathing Focus
#    - Bundle ID: Explicit > com.yourcompany.resonate
# 6. 添加功能（Resonate 不需要）
# 7. 注册
```

---

## 🧪 第五部分：在 iOS 上测试

### 5.1 物理设备测试

```bash
# 步骤 1: 通过 USB 连接 iPhone
# 步骤 2: 在 iPhone 上信任此电脑
# 步骤 3: 验证设备被检测到
flutter devices

# 步骤 4: 在设备上运行
flutter run -d <device-id>

# 或在 Xcode 中打开进行调试
open ios/Runner.xcworkspace
```

**测试检查清单**：
- [ ] 呼吸动画流畅（60fps）
- [ ] 触觉反馈在物理设备上工作
- [ ] 暗色主题显示良好
- [ ] 屏幕之间导航正常
- [ ] 数据持久化在应用重启后保持
- [ ] 应用处理屏幕方向变化
- [ ] 应用处理后台状态
- [ ] 应用处理通知（如果有）

### 5.2 iOS 模拟器测试

```bash
# 可用模拟器
flutter devices

# 在特定模拟器上运行
flutter run -d iPhone\ 15\ Pro

# 打开 iOS 模拟器
open -a Simulator
```

### 5.3 崩溃测试

```bash
# 测试边界情况：
# - 快速启动/停止计时器
# - 会话期间最小化应用
# - 杀掉应用并重启
# - 低内存情况
# - 不同 iOS 版本（14、15、16、17）

# 检查控制台日志：
# 在 Xcode 中：Window > Devices and Simulators > View Device Logs
```

---

## 📊 第六部分：App Store 元数据准备

### 6.1 应用信息

**App Store Connect 中必填字段**：

| 字段 | 值 | 备注 |
|-------|-------|-------|
| 应用名称 | Resonate - Breathing Focus | 控制在 30 字符以内 |
| 副标题 | Visual Haptic Focus & Breath | 控制在 30 字符以内 |
| 主要分类 | Health & Fitness | 最相关 |
| 次要分类 | Medical (可选) | 可选 |
| 年龄评级 | 4+ | 无明确内容 |

### 6.2 描述（短描述 170 字符）

**简短描述**：
```
Resonate 是一个极简主义的呼吸计时器，具有视觉动画和触觉反馈，帮助你专注和放松。
```

**完整描述**（最多 4000 字符）：
```
Resonate 是你正念呼吸和专注工作的伴侣。

主要功能：

• 视觉呼吸动画
流畅、催眠的圆圈以 60fps 引导你的呼吸节奏，提供舒缓的体验。

• 触觉反馈
精确的 Taptic Engine 振动与你的呼吸同步，提供温和的提醒而不干扰专注。

• 仅限暗色模式
专为低光环境设计，采用护眼色彩和最小干扰。

• 会话追踪
通过详细统计监控你的呼吸历史：
- 总会话数和完成率
- 平均时长
- 每日/每周趋势
- 个人最佳成绩

完美用于：

✓ 深度工作会话
✓ 冥想休息
✓ 减压
✓ 会前准备
✓ 睡眠例行程序

设计理念：

极简主义美学、流畅动画和触觉反馈创造了沉浸式体验，帮助你轻松进入心流状态。

隐私优先：

无跟踪、无广告、无云同步。你的数据保存在你的设备上。

立即下载 Resonate，改变你的呼吸练习。
```

### 6.3 关键词（最多 100 字符）

```
breathing,timer,focus,haptic,meditation,relax,health,fitness,mindfulness
```

### 6.4 截图

**要求**：
- iPhone 6.7" 显示屏 (1290x2796) - 必需
- iPhone 6.5" 显示屏 (1242x2688) - 必需
- iPad Pro 12.9" 显示屏 (2048x2732) - 可选

**需要创建的截图**（最少 3 张，最多 10 张）：

1. **首页** - 呼吸动画运行中
2. **计时器控制** - 显示开始/暂停/重置按钮
3. **历史记录** - 显示统计和会话列表
4. **设置页面** - 如果可用
5. **暗色主题** - 强调暗色主题设计

**提示**：
- 使用实际截图，不要使用设计图
- 显示包含真实数据的应用状态
- 确保文本可读
- 移除状态栏时间/日期（保持一致）

### 6.5 推广文本（最多 170 字符）

```
体验专注呼吸，配备视觉动画和触觉反馈。追踪你的进度，保持心流状态。
```

---

## 🚀 第七部分：为 App Store 构建

### 7.1 更新版本信息

**文件**: `pubspec.yaml`

```yaml
name: resonate
description: Visual Haptic Focus & Breath
version: 1.0.0+1
publish_to: 'none'
```

**文件**: `ios/Runner/Info.plist`

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

### 7.2 发布证书

```bash
# 创建发布证书（iOS Distribution 或 iOS App Store）
# 1. 流程与开发证书相同
# 2. 选择"iOS Distribution"类型
# 3. 下载并安装到钥匙串

# 创建 App Store Provisioning Profile
# 1. 前往 Apple Developer Portal
# 2. 创建 Provisioning Profile
# 3. 选择 App Store 类型
# 4. 选择 App ID 和发布证书
# 5. 下载并安装
```

### 7.3 构建 Archive

```bash
# 方法 1: 命令行
flutter build ios --release

# 这会创建：
# build/ios/archive/*.xcarchive

# 方法 2: 使用 Xcode（首次推荐）
# 1. 打开 ios/Runner.xcworkspace
# 2. 选择 Runner target
# 3. 选择"Any iOS Device (arm64)"
# 4. Product > Archive

# Archive 创建后：
# 1. 点击"Distribute App"
# 2. 选择"App Store Connect"
# 3. 按照向导操作
# 4. 上传到 App Store Connect
```

### 7.4 常见构建错误与解决方案

**错误**: "Provisioning profile doesn't include signing certificate"

```bash
# 解决方案：更新 provisioning profile
# 1. 前往 Apple Developer Portal
# 2. 编辑 profile，添加你的证书
# 3. 下载并安装
```

**错误**: "No matching provisioning profile found"

```bash
# 解决方案：清理并重新安装 profile
cd ios
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
# 重新下载并安装 profiles
```

**错误**: "ITMS-90338: Non-public API usage"

```bash
# 解决方案：检查是否有禁用的 API
# 常见问题：
# - 使用私有 API
# - 使用 SDK 中不存在的框架
# 检查所有第三方包
flutter pub deps
```

---

## 📤 第八部分：上传到 App Store Connect

### 8.1 创建应用记录

1. 登录 [App Store Connect](https://appstoreconnect.apple.com/)
2. 前往"My Apps"
3. 点击"+" > "New App"
4. 填写：
   - 平台：iOS
   - 名称：Resonate
   - 主要语言：English
   - Bundle ID：com.yourcompany.resonate
   - SKU：RESONATE001
5. 创建应用

### 8.2 上传二进制文件

**使用 Xcode**：
1. Archive 后，点击"Distribute App"
2. 选择"App Store Connect"
3. 选择"Automatically manage signing"
4. 上传

**使用 Transporter**（备选方案）：
```bash
# 从 Mac App Store 下载
# 上传 .ipa 文件
```

### 8.3 完成 App Store 信息

填写所有必填字段：
- [ ] 应用信息
- [ ] 定价和可用性
- [ ] 年龄评级问卷
- [ ] 应用隐私详情
- [ ] 上传所有截图
- [ ] 上传应用图标 (1024x1024)
- [ ] 提交审核

---

## 🔒 第九部分：应用隐私

### 9.1 隐私信息（必需）

由于 Resonate 使用最少的数据，以下是报告内容：

| 数据类型 | 收集？ | 分享？ | 用途 |
|-----------|-------------|----------|-----|
| 标识符 | 否 | 否 | 不适用 |
| 使用数据 | 否 | 否 | 不适用 |
| 诊断数据 | 否 | 否 | 不适用 |
| 其他数据 | 否 | 否 | 不适用 |

**说明**：
- Resonate 将呼吸会话历史存储在设备本地
- 不收集、传输或分享任何数据
- 使用 `shared_preferences`（仅本地存储）
- 无分析或跟踪

### 9.2 应用隐私政策

创建简单的隐私政策：

```
Resonate 隐私政策

最后更新：2026 年 1 月 19 日

1. 数据收集
Resonate 不收集、存储或传输任何个人数据。

2. 本地存储
应用使用设备的标准存储机制在设备本地存储呼吸会话历史。
此数据永远不会离开你的设备。

3. 无跟踪
Resonate 不使用分析、跟踪或广告技术。

4. 第三方服务
我们不使用任何收集你数据的第三方服务。

5. 数据访问
你的数据只能通过设备上的 Resonate 应用访问。

6. 数据删除
你可以通过应用中的"清除所有历史记录"功能删除所有数据，
或通过卸载应用来删除。

7. 联系方式
如有疑问，请联系我们：your.email@example.com
```

将此内容托管在你的网站或 GitHub 仓库中。

---

## ⏱️ 第十部分：审核时间线

### 10.1 平均审核时间

| 场景 | 典型时间 | 范围 |
|----------|--------------|-------|
| 首次提交 | 2-5 天 | 1-7 天 |
| 拒绝后重新提交 | 1-3 天 | 1-5 天 |
| 次要更新 | 1-2 天 | 1-3 天 |

### 10.2 审核流程

1. **自动检查**（几分钟）
   - 应用二进制文件验证
   - 元数据验证
   - 年龄评级确认

2. **人工审核**（1-5 天）
   - 应用功能测试
   - UI/UX 评估
   - 指南合规性检查

3. **结果**
   - 批准 - 应用上线
   - 拒绝 - 修复问题并重新提交

### 10.3 常见拒绝原因与预防

| 问题 | 如何避免 |
|-------|--------------|
| 启动时崩溃 | 在多个 iOS 版本上测试 |
| 缺失元数据 | 填写所有必填字段 |
| 年龄评级不正确 | 准确回答问卷 |
| 指南 2.1（性能） | 优化应用大小和性能 |
| 指南 4.0（设计） | 遵循 Human Interface Guidelines |
| 指南 5.1.1（数据收集） | 诚实报告隐私信息 |

---

## 📋 第十一部分：提交前检查清单

提交前，验证：

### 应用功能
- [ ] 应用启动无崩溃
- [ ] 所有功能按描述正常工作
- [ ] 应用优雅地处理错误
- [ ] 触觉反馈在物理设备上工作
- [ ] 数据正确持久化

### App Store 元数据
- [ ] 应用名称和副标题已填写
- [ ] 描述和关键词已优化
- [ ] 截图已上传（最少 3 张）
- [ ] 应用图标已上传（1024x1024）
- [ ] 推广文本已填写

### 隐私与合规
- [ ] 隐私政策已创建
- [ ] 隐私问卷已完成
- [ ] 年龄评级问卷已完成
- [ ] 无使用禁用的 API

### 法律
- [ ] 银行信息已添加（用于收款）
- [ ] 税务表已完成
- [ ] 所有条款和条件已接受

---

## 🎯 第十二部分：上线后任务

### 12.1 监控应用状态

```bash
# 在 App Store Connect 检查应用状态
# - 应用状态："Ready for Sale" = 已上线
# - 监控每日下载量
# - 在 Xcode Organizer 中查看崩溃报告
```

### 12.2 分析设置（可选）

如果以后想添加分析：

```yaml
# pubspec.yaml
dependencies:
  firebase_analytics: ^11.0.0
  firebase_core: ^3.0.0
```

### 12.3 更新策略
- 监控用户反馈（App Store 评价）
- 立即修复关键 Bug
- 计划每季度功能更新
- 保持变更日志对用户可见

---

## 📞 第十三部分：支持资源

### 官方资源

- [Apple Developer 文档](https://developer.apple.com/documentation/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter iOS 部署](https://docs.flutter.dev/deployment/ios)
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)

### 有用工具

- **Transporter** - 上传应用到 App Store
- **TestFlight** - Beta 测试
- **App Store Connect API** - 自动化提交（高级）

---

##  常见问题与快速修复

### 问题："Cannot add provisioning profile"

```bash
# 修复：清理 profile 并重新安装
cd ios
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/*
# 从 Apple Developer Portal 下载并安装
```

### 问题："No devices registered"

```bash
# 修复：在 Apple Developer Portal 注册设备
# 1. 通过 USB 插入设备
# 2. 打开 Xcode > Window > Devices and Simulators
# 3. 选择设备并点击"Add to Member Center"
```

### 问题："Build failed with exit code 65"

```bash
# 修复：清理并重新构建
flutter clean
cd ios
pod deintegrate
pod install
cd ..
flutter build ios
```

### 问题："App rejected for missing screenshots"

```bash
# 修复：上传至少 3 张 iPhone 6.7" 截图
# 尺寸：1290x2796 像素
```

---

## ✅ 总结检查清单

### 开始之前
- [ ] 拥有 Apple Silicon 的 Mac
- [ ] Apple Developer 账户（$99）
- [ ] 已安装 Xcode 15.0+
- [ ] 已安装 CocoaPods

### 配置
- [ ] Bundle ID 已注册
- [ ] 证书已创建
- [ ] Provisioning profile 已安装
- [ ] 应用图标已创建
- [ ] 隐私权限已添加

### 测试
- [ ] 在物理设备上测试过
- [ ] 在多个 iOS 版本上测试过
- [ ] 所有功能正常工作
- [ ] 无崩溃

### 提交
- [ ] App Store Connect 中已创建应用
- [ ] 元数据已完成
- [ ] 截图已上传
- [ ] 隐私问卷已完成
- [ ] 构建已上传
- [ ] 已提交审核

---

## 📚 额外资源

**需要阅读的文档**：
1. [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
2. [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
3. [Flutter iOS 最佳实践](https://docs.flutter.dev/development/ios-project-structure)

**推荐观看的视频**：
1. "App Store Connect Overview" - Apple Developer
2. "Submitting Your First App" - Apple Developer
3. "Flutter iOS Deep Dive" - Flutter 团队

**社区**：
- [Flutter Dev Community](https://dev.to/t/flutter)
- [Apple Developer Forums](https://developer.apple.com/forums/)
- [Stack Overflow (flutter-ios)](https://stackoverflow.com/questions/tagged/flutter-ios)

---

**下一步**：
1. 设置 Mac 环境
2. 注册 Apple Developer 账户
3. 在物理设备上测试应用
4. 准备所有资源和元数据
5. 构建并提交审核

**预计上线时间**：
- 设置：2-3 天
- 测试：3-5 天
- 资源准备：2-3 天
- 审核流程：2-5 天
- **总计：2-3 周**

祝你的 iOS 发布顺利！🚀
