# iOS 准备工作检查清单

**日期**: 2026-01-19
**项目**: Resonate
**目的**: iOS 测试和 App Store 提交快速参考

---

## 📋 第一阶段：Mac 环境搭建

### 硬件要求
- [ ] Mac 电脑（推荐 Apple Silicon M1/M2/M3）
- [ ] 至少 16GB 内存
- [ ] 至少 50GB 可用磁盘空间
- [ ] iPhone 连接线（Lightning/USB-C）

### 软件安装
- [ ] macOS Sonoma 14.0 或更高版本
- [ ] Xcode 15.0 或更高版本（从 Mac App Store 安装）
- [ ] Xcode 命令行工具（`xcode-select --install`）
- [ ] 接受 Xcode 许可协议（`sudo xcodebuild -license accept`）
- [ ] CocoaPods（`sudo gem install cocoapods`）

### Flutter 配置
- [ ] 将项目克隆到 Mac
- [ ] `flutter pub get`
- [ ] `flutter doctor -v`（确保 iOS 显示 ✓）
- [ ] `cd ios && pod install`

---

## 🔐 第二阶段：Apple Developer 账户

### 账户注册
- [ ] 注册 Apple Developer Program（$99/年）
- [ ] 等待审核通过（1-3 天）
- [ ] 登录 [App Store Connect](https://appstoreconnect.apple.com/)
- [ ] 完善个人资料：
  - [ ] 法律信息
  - [ ] 银行信息（用于收款）
  - [ ] 税务表

### 团队设置
- [ ] 邀请团队成员（如需要）
- [ ] 分配角色和权限

---

## 📱 第三阶段：应用配置

### Bundle ID
- [ ] 注册 Bundle ID：`com.yourcompany.resonate`
- [ ] 类型：明确的 App ID
- [ ] 功能：暂时无需额外功能

### 证书
- [ ] 创建开发证书（用于测试）
- [ ] 创建发布证书（用于 App Store）
- [ ] 安装到钥匙串

### Provisioning Profile
- [ ] 创建开发 Provisioning Profile
- [ ] 创建 App Store Provisioning Profile
- [ ] 安装到 Mac

### App Store Connect
- [ ] 在 App Store Connect 创建新应用
- [ ] 填写基本信息：
  - [ ] 名称：Resonate
  - [ ] 平台：iOS
  - [ ] Bundle ID：com.yourcompany.resonate
  - [ ] SKU：RESONATE001

---

## 🎨 第四阶段：应用资源

### 图标
- [ ] 创建 1024x1024 App Store 图标
- [ ] 创建 iOS 应用图标（多种尺寸）：
  - [ ] 60pt @2x (120x120)
  - [ ] 60pt @3x (180x180)
  - [ ] 76pt @2x (152x152)
  - [ ] 167x167
- [ ] 放置到 `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 截图（最少 3 张，最多 10 张）
- [ ] iPhone 6.7" 显示屏 (1290x2796)：
  - [ ] 首页界面
  - [ ] 计时器控制界面
  - [ ] 历史记录界面
- [ ] （可选）iPhone 6.5" 显示屏 (1242x2688)
- [ ] （可选）iPad Pro 12.9" 显示屏 (2048x2732)

### 启动屏
- [ ] 配置 `ios/Runner/LaunchScreen.storyboard`
- [ ] 黑色背景，居中显示 Logo
- [ ] 无复杂动画

---

## 📝 第五阶段：元数据准备

### 应用信息
- [ ] 名称：Resonate - Breathing Focus
- [ ] 副标题：Visual Haptic Focus & Breath
- [ ] 简短描述（最多 170 字符）
- [ ] 完整描述（最多 4000 字符）
- [ ] 关键词（最多 100 字符）：`breathing,timer,focus,haptic,meditation,relax,health,fitness,mindfulness`
- [ ] 推广文本（最多 170 字符）
- [ ] 分类：健康与健身
- [ ] 年龄评级：4+

### 隐私
- [ ] 完成隐私问卷
- [ ] 创建隐私政策文档
- [ ] 上传到 App Store Connect
- [ ] 在元数据中添加隐私政策链接

---

## 🧪 第六阶段：iOS 测试

### 物理设备测试
- [ ] 通过 USB 连接 iPhone
- [ ] 在 iPhone 上信任此电脑
- [ ] `flutter devices` - 验证设备被识别
- [ ] `flutter run -d <device-id>`
- [ ] 测试所有功能：
  - [ ] 呼吸动画（60fps）
  - [ ] 触觉反馈
  - [ ] 计时器控制
  - [ ] 数据持久化
  - [ ] 页面导航
  - [ ] 屏幕方向变化
  - [ ] 后台状态

### 模拟器测试
- [ ] 在多个 iOS 版本上测试（14、15、16、17）
- [ ] 在不同设备尺寸上测试
- [ ] 在 iPad 上测试（如支持）

### 边界情况
- [ ] 快速启动/停止计时器
- [ ] 会话期间最小化应用
- [ ] 杀掉应用并重启
- [ ] 低内存场景

---

## 🚀 第七阶段：构建 App Store 版本

### 版本信息
- [ ] 在 `pubspec.yaml` 中更新版本：`version: 1.0.0+1`
- [ ] 更新 `ios/Runner/Info.plist`：
  - [ ] CFBundleShortVersionString: 1.0.0
  - [ ] CFBundleVersion: 1

### 隐私权限
- [ ] 在 `ios/Runner/Info.plist` 中添加：
  - [ ] NSHapticFeedbackUsageDescription
  - [ ] NSUserTrackingUsageDescription（如需要）

### 构建 Archive
- [ ] `flutter clean`
- [ ] `cd ios && pod install && cd ..`
- [ ] `flutter build ios --release`
- [ ] 在 Xcode 中打开 `ios/Runner.xcworkspace`
- [ ] Product > Archive
- [ ] Distribute App > App Store Connect
- [ ] 上传

---

## 📤 第八阶段：提交 App Store

### 完善元数据
- [ ] 上传所有截图
- [ ] 上传 App Store 图标
- [ ] 填写应用描述
- [ ] 添加关键词
- [ ] 添加推广文本
- [ ] 完成年龄评级
- [ ] 完成隐私详情

### 最终审查
- [ ] 对照 App Store 审核指南检查
- [ ] 再次全面测试应用
- [ ] 验证无禁用的 API
- [ ] 检查应用大小（推荐 < 100MB）

### 提交
- [ ] 点击"Add for Review"
- [ ] 选择版本 1.0.0
- [ ] 提交审核
- [ ] 等待 2-5 天

---

## ⏱️ 时间预估

| 阶段 | 时间 |
|-------|------|
| Mac 环境搭建 | 2-3 天 |
| Apple Developer 账户 | 2-3 天（含审核时间） |
| 应用配置 | 1-2 天 |
| 资源创建 | 2-3 天 |
| 元数据准备 | 1-2 天 |
| iOS 测试 | 3-5 天 |
| 构建和上传 | 1 天 |
| App Store 审核 | 2-5 天 |
| **总计** | **14-24 天（2-3.5 周）** |

---

## 🚨 常见误区

### 账户问题
- ❌ 不要忘记接受 Xcode 许可协议
- ❌ 不要对 App Store 构建使用自动签名
- ❌ 不要等到最后一刻才填写银行信息

### 资源问题
- ❌ 不要使用设计图作为应用截图
- ❌ 不要忘记创建所有尺寸的图标
- ❌ 不要使用模糊或低分辨率的图片

### 元数据问题
- ❌ 不要留空任何必填字段
- ❌ 不要超过字符限制
- ❌ 不要忘记隐私问卷

### 构建问题
- ❌ 不要跳过物理设备测试
- ❌ 不要使用 debug 构建版本提交
- ❌ 不要忘记更新版本号

### 审核问题
- ❌ 不要在已知崩溃的情况下提交
- ❌ 不要使用禁用的 API 或私有框架
- ❌ 不要隐藏描述中提到的功能

---

## 📞 资源

### 官方文档
- [Apple Developer 文档](https://developer.apple.com/documentation/)
- [App Store 审核指南](https://developer.apple.com/app-store/review/guidelines/)
- [Flutter iOS 部署](https://docs.flutter.dev/deployment/ios)
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)

### 快速命令

```bash
# 检查设备
flutter devices

# 清理构建
flutter clean
cd ios && pod install && cd ..

# 构建 iOS 版本
flutter build ios --release

# 在 Xcode 中打开
open ios/Runner.xcworkspace

# 验证 Flutter 配置
flutter doctor -v

# 在设备上运行
flutter run -d <device-id>
```

---

## ✅ 提交前最终检查清单

在点击"Submit"之前，请验证：

**应用**
- [ ] 启动时无崩溃
- [ ] 所有功能按描述正常工作
- [ ] 应用优雅地处理错误
- [ ] 在物理设备上测试过
- [ ] 在多个 iOS 版本上测试过

**元数据**
- [ ] 应用名称和副标题已填写
- [ ] 描述完整且吸引人
- [ ] 关键词已优化
- [ ] 截图已上传（至少 3 张）
- [ ] 应用图标已上传（1024x1024）

**法律**
- [ ] 隐私政策已创建
- [ ] 隐私问卷已完成
- [ ] 年龄评级准确
- [ ] 银行信息已配置
- [ ] 税务表已完成

**技术**
- [ ] 发布证书已安装
- [ ] Provisioning Profile 正确
- [ ] 构建是 release 版本
- [ ] 版本号一致
- [ ] 无禁用的 API

---

## 🎯 成功标准

当以下条件满足时，你的应用就准备好了：
- ✓ 应用在 iPhone 上流畅运行
- ✓ 所有截图和资源已准备就绪
- ✓ 所有元数据已完成
- ✓ 构建成功上传
- ✓ App Store Connect 中无警告或错误

**祝你成功！** 🚀
