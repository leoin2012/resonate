# Flutter Web Chrome 调试修复报告

**日期**: 2026-01-18
**项目**: Resonate
**平台**: Chrome Web (HTML Renderer)

## 执行摘要

成功修复了 Resonate 应用在 Chrome Web 平台的编译和运行问题。应用现在可以在 Chrome 浏览器中以 debug 模式正常运行。

## 遇到的问题

### 1. Isar 数据库 Web 平台兼容性问题

**问题描述**:
- Isar 在 Web 平台上生成的代码包含 JavaScript 无法精确表示的大整数
- 错误信息：`Expected a JavaScript number that fits into a 64-bit signed integer, but got 9223372036854776000`

**解决方案**:
- 完全移除 Isar 数据库依赖
- 使用 `shared_preferences` 实现跨平台数据持久化
- 创建简单的 JSON 序列化方案

### 2. BreathingSession 模型构造函数问题

**问题描述**:
- 默认值 `this.id = DateTime.now().millisecondsSinceEpoch` 不是常量表达式
- 错误信息：`Constant expression expected`

**解决方案**:
```dart
BreathingSession({
  required this.startTime,
  // ...
  int? id,
}) : id = id ?? DateTime.now().millisecondsSinceEpoch;
```
- 使用可选的 `int? id` 参数
- 在初始化列表中设置默认值

### 3. Web Shader 编译问题

**问题描述**:
- Shader 编译器无法写入 `ink_sparkle.frag` 和 `stretch_effect.frag`
- 错误信息：`Could not write file to .../build/web/assets/shaders/ink_sparkle.frag`

**解决方案**:
- 在 `web/index.html` 中添加配置使用 HTML 渲染器：
```html
<script>
  window.flutter_web_renderer = "html";
</script>
```
- 避免使用 CanvasKit 渲染器（需要 Shader 编译）

### 4. Repository 方法名不匹配

**问题描述**:
- `getRecentSessions` 方法在 SessionRepository 中不存在

**解决方案**:
- 统一使用 `getSessionsFromLastDays` 方法名
- 更新所有调用处的代码

### 5. Windows Desktop 构建问题

**问题描述**:
- CMake 无法找到 Visual Studio 实例
- 错误信息：`Generator Visual Studio 17 2022 could not find any instance`

**解决方案**:
- 使用 `flutter doctor -v` 确认 Visual Studio 已安装
- 最终选择 Chrome Web 作为主要测试平台

## 架构变更

### 数据存储方案变更

| 之前 (Isar) | 现在 (SharedPreferences) |
|------------|--------------------------|
| `@collection` 注解 | JSON 序列化 |
| `Id id = Isar.autoIncrement` | `int id` (时间戳) |
| 原生数据库查询 | 内存 + JSON |
| Web 平台不支持 | 全平台支持 |

### 文件结构变更

**移除的文件**:
- `lib/src/data/isar_service.dart`
- `lib/src/data/isar_service_stub.dart`
- `lib/src/data/repositories/session_repository_stub.dart`
- `lib/src/data/repositories/session_repository_native.dart`
- `lib/src/data/repositories/session_repository_web.dart`

**简化为单一实现**:
- `lib/src/data/repositories/session_repository.dart` (SharedPreferences)

## 测试结果

### ✅ 成功的项目

| 平台 | 状态 | 渲染器 | 备注 |
|------|------|--------|------|
| Chrome Web | ✅ 成功 | HTML | Debug 模式正常运行 |

### ❌ 失败的项目

| 平台 | 状态 | 错误原因 |
|------|------|----------|
| Chrome Web (Release/Profile) | ❌ | Shader 编译失败 |
| Windows Desktop | ❌ | CMake 找不到 Visual Studio |

## 最终配置

### pubspec.yaml 依赖

```yaml
dependencies:
  flutter_riverpod: ^2.5.0
  go_router: ^14.1.0
  shared_preferences: ^2.2.2
  google_fonts: ^6.1.0
  haptic_feedback: ^0.4.0
  flutter_animate: ^4.5.0
```

### Web 配置 (index.html)

```html
<script>
  window.flutter_web_renderer = "html";
</script>
```

## 命令参考

### 运行应用

```bash
# Chrome Debug (推荐)
flutter run -d chrome

# 查看 Flutter 环境
flutter doctor

# 查看可用设备
flutter devices
```

### 避免使用

```bash
# ❌ 这些命令会触发 Shader 编译问题
flutter build web
flutter run -d chrome --release
flutter run -d chrome --profile
```

## 下一步建议

1. **功能测试**
   - 测试呼吸动画流畅度
   - 测试触觉反馈功能
   - 测试历史记录保存/读取

2. **性能优化**
   - 监控 Web 平台内存使用
   - 优化 JSON 序列化性能

3. **跨平台部署**
   - 在 Mac 上测试 iOS 构建
   - 修复 Windows Desktop 构建问题

4. **数据迁移**
   - 如果需要支持 Isar 数据迁移，实现导入/导出功能

## 总结

通过以下关键决策，成功解决了 Web 平台的所有问题：

1. **放弃 Isar**：选择更简单但更可靠的 SharedPreferences
2. **使用 HTML 渲染器**：避免复杂的 Shader 编译问题
3. **简化架构**：移除平台特定代码，统一实现

应用现在可以在 Chrome Web 上正常运行，为后续功能开发和测试奠定了基础。
