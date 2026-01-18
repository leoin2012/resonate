# Resonate - 触觉视觉专注与呼吸应用

> 极简主义的专注和呼吸计时器，通过视觉、触觉和数据的完美结合，帮助用户进入专注状态。

## 📋 当前状态

### Phase 1: 基础架构 ✅
- [x] 项目初始化
- [x] 暗色主题
- [x] 路由配置
- [x] Home 页面框架
- [x] 数据模型定义（使用 SharedPreferences 替代 Isar）
- [x] 仓库层搭建（SessionRepository）
- [x] Chrome Web 平台调试完成

### Phase 2: 呼吸计时器 🚧
- [x] CustomPainter 呼吸圆圈动画（基础框架）
- [x] 计时器控制 UI
- [ ] 计时器逻辑（分/秒设置）
- [ ] 开始/暂停/重置功能
- [ ] 触觉反馈同步（每秒震动）
- [ ] 动画参数配置（速度、大小）

### Phase 3: 数据持久化 🚧
- [x] 呼吸会话数据模型（BreathingSession）
- [x] 保存每次会话记录（SharedPreferences）
- [ ] 历史记录页面 UI
- [ ] 统计数据展示

### Phase 4: 高级功能 ⏳
- [ ] 设置页面
- [ ] 自定义触觉反馈强度
- [ ] 不同呼吸模式（4-7-8、盒式呼吸等）
- [ ] 提醒功能

---

## 📐 技术栈

| 模块 | 技术 | 版本 | 用途 | 说明 |
|------|------|------|------|------|
| 状态管理 | flutter_riverpod | ^2.5.0 | AsyncNotifier 模式 | - |
| 导航 | go_router | ^14.1.0 | 声明式路由 | - |
| 数据持久化 | shared_preferences | ^2.2.2 | 本地历史记录 | 替代 Isar，全平台支持 |
| 触觉反馈 | haptic_feedback | ^0.4.0 | Taptic Engine | - |
| 动画 | flutter_animate | ^4.5.0 | UI 过渡动画 | - |
| 字体 | google_fonts | ^6.1.0 | Orbitron, Roboto | - |

---

## 📂 项目结构

```
lib/
├── main.dart                          # 应用入口
└── src/
    ├── core/
    │   ├── theme/
    │   │   └── app_theme.dart          # 主题配置（仅暗色模式）
    │   ├── router/
    │   │   └── app_router.dart         # 路由配置
    │   ├── constants/
    │   │   └── app_colors.dart         # 颜色常量
    │   └── utils/
    │       └── haptic_manager.dart     # 触觉反馈管理器
    ├── data/
    │   ├── models/
    │   │   └── breathing_session.dart  # 呼吸会话数据模型
    │   └── repositories/
    │       └── session_repository.dart # 数据仓库（SharedPreferences）
    └── features/
        ├── home/
        │   ├── domain/
        │   │   └── breathe_timer_provider.dart  # 计时器状态管理
        │   └── presentation/
        │       ├── home_screen.dart             # 主页面
        │       ├── breathing_animation_widget.dart  # 呼吸动画
        │       └── timer_control_widget.dart    # 计时器控制
        ├── settings/
        │   └── presentation/
        │       └── settings_screen.dart         # 设置页面
        └── history/
            ├── domain/
            │   └── history_provider.dart        # 历史记录状态管理
            └── presentation/
                └── history_screen.dart          # 历史记录页面

web/
├── index.html                         # Web 入口（HTML 渲染器配置）
├── manifest.json                      # PWA 配置
└── icons/                            # 图标资源
```

---

## 🎨 设计系统

### 色彩方案

| 颜色 | 代码 | 用途 |
|------|------|------|
| Background | `#0A0A0A` | 主背景 |
| Surface | `#1A1A1A` | 卡片/按钮背景 |
| Primary | `#00FFFF` | 主色调（青色） |
| Text Primary | `#FFFFFF` | 主要文字 |
| Text Secondary | `#B3B3B3` | 次要文字 |

### 字体

- **主标题**: Orbitron（科技感）
- **正文**: Roboto（可读性）

### 设计原则

- **极简主义**：去除所有不必要的元素
- **沉浸式**：全屏暗色主题，无干扰
- **流畅动画**：60fps 的呼吸圆圈动画

---

## 🚀 快速开始

### 环境要求

- Flutter SDK >= 3.38.0
- Dart SDK >= 3.10.0

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# Chrome Web (推荐 - 已验证可用)
flutter run -d chrome

# Windows Desktop (需要 Visual Studio)
flutter run -d windows

# Mac Desktop
flutter run -d macos
```

**注意**: Web 平台已配置使用 HTML 渲染器，无需 Shader 编译。

---

## 🛠️ 开发规范

### 代码规范

1. **注释语言**: 所有代码注释必须使用英文
2. **文件命名**: 使用 `snake_case`
3. **类命名**: 使用 `PascalCase`
4. **行尾格式**: 强制使用 LF
5. **避免硬编码**: 所有常量提取到 constants/

### 状态管理规范

- 使用 `AsyncNotifier` 管理异步状态
- 使用 `StateNotifier` 管理简单状态
- 状态更新必须通过 `notifier` 方法
- 禁止直接修改状态

### 数据持久化规范

- 使用 `SharedPreferences` 实现数据存储
- 所有数据模型必须实现 `fromJson` 和 `toJson` 方法
- 使用 JSON 序列化进行数据持久化

---

## ⚠️ 已知问题与限制

### Web 平台

- **问题**: Release 和 Profile 模式下 Shader 编译失败
- **解决方案**: 仅在 Debug 模式下开发，已配置 HTML 渲染器
- **影响**: 不影响日常开发和测试

### Windows Desktop

- **问题**: CMake 找不到 Visual Studio 实例
- **解决方案**: 使用 Chrome Web 作为主要开发平台
- **待处理**: 需要修复 CMake 配置或安装 Visual Studio 组件

---

## 📝 文档与参考

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev/)
- [Chrome 调试报告](AIReference/chrome_debug_report.md)

---

## 🤝 贡献指南

### 提交前检查

1. 代码符合开发规范
2. 所有注释使用英文
3. 更新 README.md（同步修改状态和项目结构）
4. 测试应用在 Chrome Web 上正常运行

### Commit 规范

- `feat:` 新功能
- `fix:` 修复 bug
- `docs:` 文档更新
- `refactor:` 代码重构
- `style:` 代码格式调整

---

## 📄 许可证

MIT License
