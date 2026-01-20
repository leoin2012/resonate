#!/bin/bash

# iOS 真机安装脚本 (优化版 v2)
# 用于自动化构建和部署 Resonate 应用到 iOS 真机
# 改进: 自动获取设备ID, 清理冲突文件, 支持Debug/Release模式

set -e  # 遇到错误立即退出

# ========== 配置参数 ==========
BUILD_MODE="${1:-debug}"  # 默认使用 debug 模式，可传参 release
BUILD_TIMEOUT=600  # 构建超时时间(秒),默认10分钟
DEPLOY_TIMEOUT=120  # 部署超时时间(秒),默认2分钟

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# 日志目录和文件
LOG_DIR="$PROJECT_ROOT/Saved/Logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BUILD_LOG="$LOG_DIR/build_${TIMESTAMP}.log"
INSTALL_LOG="$LOG_DIR/install_${TIMESTAMP}.log"
SUMMARY_LOG="$LOG_DIR/installation_summary_${TIMESTAMP}.log"

# 确保日志目录存在
mkdir -p "$LOG_DIR"

# 构建配置
if [ "$BUILD_MODE" == "release" ]; then
    BUILD_CONFIGURATION="Release"
    PRODUCTS_DIR="Release-iphoneos"
else
    BUILD_CONFIGURATION="Debug"
    PRODUCTS_DIR="Debug-iphoneos"
fi

# 构建产物路径
SYSTEM_DERIVED_DATA_DIR="$HOME/Library/Developer/Xcode/DerivedData"
PROJECT_TEMP_DERIVED_DATA="$SYSTEM_DERIVED_DATA_DIR/Runner-$(date +%s)"
APP_PATH="$PROJECT_TEMP_DERIVED_DATA/Build/Products/$PRODUCTS_DIR/Runner.app"

echo "========================================"
echo "  Resonate iOS 真机安装脚本 (v2)"
echo "========================================"
echo "📂 项目路径: $PROJECT_ROOT"
echo "🔧 构建模式: $BUILD_CONFIGURATION"
echo "📝 构建日志: $BUILD_LOG"
echo "📝 安装日志: $INSTALL_LOG"
echo "⏱️  构建超时: ${BUILD_TIMEOUT}秒"
echo "⏱️  部署超时: ${DEPLOY_TIMEOUT}秒"
echo "========================================"
echo ""
echo "开始时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 0: 清理 OneDrive 同步冲突文件 ==========
echo "========================================"
echo "步骤 0/8: 清理同步冲突文件"
echo "========================================"

cd "$PROJECT_ROOT"

# 查找并删除 OneDrive 同步产生的冲突文件
CONFLICT_FILES=$(find . -name "*-SHUCHANGLI*" -o -name "*-SHUCHANGLIU*" 2>/dev/null || true)
if [ -n "$CONFLICT_FILES" ]; then
    echo "发现以下冲突文件:"
    echo "$CONFLICT_FILES"
    echo ""
    echo "正在删除..."
    find . -name "*-SHUCHANGLI*" -delete 2>/dev/null || true
    find . -name "*-SHUCHANGLIU*" -delete 2>/dev/null || true
    echo "✅ 冲突文件已清理"
else
    echo "✅ 无冲突文件"
fi
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 1: 检查设备连接并获取设备ID ==========
echo "========================================"
echo "步骤 1/8: 检查设备连接"
echo "========================================"

# 使用 idevice_id 获取已连接的设备列表
if ! command -v idevice_id &> /dev/null; then
    echo "⚠️  未找到 idevice_id 命令"
    echo "正在尝试使用 flutter devices..."
    DEVICE_LINE=$(flutter devices 2>&1 | grep -E "iPhone|iPad" | head -1)
    if [ -z "$DEVICE_LINE" ]; then
        echo "❌ 未检测到 iOS 设备"
        echo ""
        echo "请确保:"
        echo "  1. 设备已通过 USB 线连接到 Mac"
        echo "  2. 设备已解锁"
        echo "  3. 已在设备上信任此电脑"
        echo ""
        echo "运行以下命令查看可用设备:"
        echo "  flutter devices"
        exit 1
    fi
    # 从 flutter devices 输出提取设备 ID
    DEVICE_ID=$(echo "$DEVICE_LINE" | grep -oE '[a-f0-9]{40}' | head -1)
    DEVICE_NAME=$(echo "$DEVICE_LINE" | sed 's/ •.*//' | xargs)
else
    # 使用 idevice_id 获取设备
    DEVICE_ID=$(idevice_id -l 2>/dev/null | head -1)
    if [ -z "$DEVICE_ID" ]; then
        echo "❌ 未检测到 iOS 设备"
        echo ""
        echo "请确保:"
        echo "  1. 设备已通过 USB 线连接到 Mac"
        echo "  2. 设备已解锁"
        echo "  3. 已在设备上信任此电脑"
        exit 1
    fi
    DEVICE_NAME=$(idevicename 2>/dev/null || echo "iOS Device")
fi

echo "✅ 设备已连接"
echo "📱 设备名称: $DEVICE_NAME"
echo "🔑 设备 ID: $DEVICE_ID"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 2: 清理项目 ==========
echo "========================================"
echo "步骤 2/8: 清理项目"
echo "========================================"

cd "$PROJECT_ROOT"

echo "清理 Flutter 构建产物..."
flutter clean || {
    echo "⚠️  Flutter clean 失败,继续执行..."
}

echo "删除旧的构建文件..."
rm -rf build .dart_tool ios/Pods ios/Podfile.lock ios/.symlinks 2>/dev/null || true
rm -rf ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec 2>/dev/null || true
echo "✅ 项目清理完成"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 3: 更新依赖 ==========
echo "========================================"
echo "步骤 3/8: 更新 Flutter 依赖"
echo "========================================"

echo "运行 flutter pub get..."
flutter pub get | tee -a "$BUILD_LOG"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ 依赖获取失败"
    echo "请检查网络连接或运行: flutter pub get"
    exit 1
fi

echo "✅ 依赖更新完成"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 4: 安装 CocoaPods 依赖 ==========
echo "========================================"
echo "步骤 4/8: 安装 CocoaPods 依赖"
echo "========================================"

cd ios

echo "运行 pod install..."
pod install | tee -a "$BUILD_LOG"

if [ ${PIPESTATUS[0]} -ne 0 ]; then
    echo "❌ CocoaPods 安装失败"
    echo "尝试的解决方案:"
    echo "  1. 运行: cd ios && pod deintegrate && pod install"
    echo "  2. 运行: cd ios && pod repo update && pod install"
    echo "  3. 删除 ios/Pods 目录后重试"
    exit 1
fi

cd ..
echo "✅ CocoaPods 依赖安装完成"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 5: 构建 iOS 应用 ==========
echo "========================================"
echo "步骤 5/8: 构建 iOS 应用"
echo "========================================"

cd ios

echo "配置信息:"
echo "  - 构建模式: $BUILD_CONFIGURATION"
echo "  - 目标设备: $DEVICE_ID"
echo "  - DerivedData: $PROJECT_TEMP_DERIVED_DATA"
echo "  - 超时时间: ${BUILD_TIMEOUT}秒"
echo ""
echo "开始构建 (这可能需要几分钟)..."
echo ""

# 检查系统是否支持 timeout 命令
if command -v gtimeout >/dev/null 2>&1; then
    TIMEOUT_CMD="gtimeout"
elif command -v timeout >/dev/null 2>&1; then
    TIMEOUT_CMD="timeout"
else
    echo "⚠️  系统不支持 timeout 命令,将使用标准构建(无超时限制)"
    echo "   如果需要超时控制,请安装: brew install coreutils"
    TIMEOUT_CMD=""
fi

# 使用明确的 DerivedData 路径进行构建
if [ -n "$TIMEOUT_CMD" ]; then
    $TIMEOUT_CMD $BUILD_TIMEOUT xcodebuild \
      -workspace Runner.xcworkspace \
      -scheme Runner \
      -configuration $BUILD_CONFIGURATION \
      -destination "id=$DEVICE_ID" \
      -derivedDataPath "$PROJECT_TEMP_DERIVED_DATA" \
      -allowProvisioningUpdates \
      build 2>&1 | tee "$BUILD_LOG"
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
else
    xcodebuild \
      -workspace Runner.xcworkspace \
      -scheme Runner \
      -configuration $BUILD_CONFIGURATION \
      -destination "id=$DEVICE_ID" \
      -derivedDataPath "$PROJECT_TEMP_DERIVED_DATA" \
      -allowProvisioningUpdates \
      build 2>&1 | tee "$BUILD_LOG"
    BUILD_EXIT_CODE=${PIPESTATUS[0]}
fi

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    if [ $BUILD_EXIT_CODE -eq 124 ] && [ -n "$TIMEOUT_CMD" ]; then
        echo "❌ 构建超时 (超过 ${BUILD_TIMEOUT}秒)"
        echo "请尝试:"
        echo "  1. 增加脚本中的 BUILD_TIMEOUT 值"
        echo "  2. 检查网络连接 (代码签名需要)"
        echo "  3. 重启 Mac 后重试"
    else
        echo "❌ 构建失败 (退出码: $BUILD_EXIT_CODE)"
        echo ""
        echo "常见问题排查:"
        echo "  1. 检查代码签名: Xcode -> Runner target -> Signing & Capabilities"
        echo "  2. 检查证书: Xcode -> Preferences -> Accounts"
        echo "  3. 查看完整日志: $BUILD_LOG"
    fi
    
    exit 1
fi

cd ..
echo ""
echo "✅ 构建成功"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 6: 验证构建产物 ==========
echo "========================================"
echo "步骤 6/8: 验证构建产物"
echo "========================================"

echo "查找构建产物..."
echo "  预期路径: $APP_PATH"

if [ ! -d "$APP_PATH" ]; then
    echo "❌ 应用构建产物不存在"
    echo ""
    echo "尝试查找替代路径..."
    
    # 尝试在系统 DerivedData 中查找
    SYSTEM_DERIVED_DATA=$(ls -td ~/Library/Developer/Xcode/DerivedData/Runner-* 2>/dev/null | head -1)
    
    if [ -n "$SYSTEM_DERIVED_DATA" ]; then
        ALTERNATIVE_APP="$SYSTEM_DERIVED_DATA/Build/Products/$PRODUCTS_DIR/Runner.app"
        
        if [ -d "$ALTERNATIVE_APP" ]; then
            echo "⚠️  在系统 DerivedData 中找到构建产物"
            echo "  路径: $ALTERNATIVE_APP"
            APP_PATH="$ALTERNATIVE_APP"
        fi
    fi
    
    if [ ! -d "$APP_PATH" ]; then
        echo ""
        echo "❌ 无法找到有效的构建产物"
        echo "请检查:"
        echo "  1. 构建是否成功完成"
        echo "  2. 查看构建日志: $BUILD_LOG"
        echo "  3. 尝试手动运行构建命令"
        exit 1
    fi
fi

APP_SIZE=$(du -sh "$APP_PATH" | cut -f1)
echo "✅ 构建产物验证通过"
echo "  路径: $APP_PATH"
echo "  大小: $APP_SIZE"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 7: 部署到设备 ==========
echo "========================================"
echo "步骤 7/8: 部署到设备"
echo "========================================"

echo "部署信息:"
echo "  - 设备 ID: $DEVICE_ID"
echo "  - 应用路径: $APP_PATH"
echo "  - 超时时间: ${DEPLOY_TIMEOUT}秒"
echo ""
echo "开始部署 (这可能需要几十秒)..."
echo ""

if [ -n "$TIMEOUT_CMD" ]; then
    $TIMEOUT_CMD $DEPLOY_TIMEOUT ios-deploy \
      --id "$DEVICE_ID" \
      --bundle "$APP_PATH" \
      --noninteractive \
      --debug 2>&1 | tee "$INSTALL_LOG"
    DEPLOY_EXIT_CODE=${PIPESTATUS[0]}
else
    ios-deploy \
      --id "$DEVICE_ID" \
      --bundle "$APP_PATH" \
      --noninteractive \
      --debug 2>&1 | tee "$INSTALL_LOG"
    DEPLOY_EXIT_CODE=${PIPESTATUS[0]}
fi

if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
    # 检查是否是代码签名信任问题
    if [ $DEPLOY_EXIT_CODE -eq 254 ] || [ $DEPLOY_EXIT_CODE -eq 255 ]; then
        if grep -qi "invalid code signature\|inadequate entitlements\|not been explicitly trusted" "$INSTALL_LOG" 2>/dev/null; then
            echo ""
            echo "⚠️  应用已安装成功,但需要手动信任开发者证书"
            DEPLOY_EXIT_CODE=0
        fi
    elif [ $DEPLOY_EXIT_CODE -eq 124 ] && [ -n "$TIMEOUT_CMD" ]; then
        echo "❌ 部署超时 (超过 ${DEPLOY_TIMEOUT}秒)"
        echo "请尝试:"
        echo "  1. 增加脚本中的 DEPLOY_TIMEOUT 值"
        echo "  2. 断开并重新连接设备"
        echo "  3. 重启设备后重试"
        exit 1
    else
        echo "❌ 部署失败 (退出码: $DEPLOY_EXIT_CODE)"
        echo ""
        echo "常见问题排查:"
        echo "  1. 检查设备是否解锁"
        echo "  2. 检查 USB 连接是否稳定"
        echo "  3. 查看完整日志: $INSTALL_LOG"
        exit 1
    fi
    
    if [ $DEPLOY_EXIT_CODE -ne 0 ]; then
        exit 1
    fi
fi

# 检查是否真的安装成功
if grep -q "100%" "$INSTALL_LOG" 2>/dev/null; then
    echo ""
    echo "✅ 应用已成功安装到设备 (100%)"
else
    echo ""
    echo "⚠️  部署可能未完成"
    echo "请检查应用是否出现在设备上"
fi

echo ""
echo "✅ 部署流程完成"
echo "完成时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# ========== 步骤 8: 生成安装摘要 ==========
echo "========================================"
echo "步骤 8/8: 生成安装摘要"
echo "========================================"

echo ""
echo "========================================"
echo "  安装成功! 🎉"
echo "========================================"
echo ""
echo "📱 设备信息:"
echo "  - 设备名称: $DEVICE_NAME"
echo "  - 设备 ID: $DEVICE_ID"
echo ""
echo "📦 应用信息:"
echo "  - 构建模式: $BUILD_CONFIGURATION"
echo "  - 应用路径: $APP_PATH"
echo "  - 应用大小: $APP_SIZE"
echo "  - 包名: com.joyera.resonate"
echo ""
echo "📝 日志文件:"
echo "  - 构建日志: $BUILD_LOG"
echo "  - 安装日志: $INSTALL_LOG"
echo ""
echo "========================================"
echo "  ⚠️  重要：首次启动需要信任开发者证书"
echo "========================================"
echo ""
echo "📱 在 iPhone 上操作步骤："
echo ""
echo "  1️⃣  找到并尝试打开 Resonate 应用"
echo ""
echo "  2️⃣  如果显示 '不受信任的开发者'，请："
echo ""
echo "     打开 📱 设置"
echo "        ↓"
echo "     通用"
echo "        ↓"
echo "     VPN与设备管理"
echo "        ↓"
echo "     找到开发者证书 (Apple Development)"
echo "        ↓"
echo "     点击 '信任' ✅"
echo ""
echo "  3️⃣  返回桌面，重新打开 Resonate 应用"
echo ""
echo "========================================"

# 保存摘要到文件
cat > "$SUMMARY_LOG" <<EOF
# iOS 真机安装摘要

## 安装信息
- 安装时间: $(date '+%Y-%m-%d %H:%M:%S')
- 设备名称: $DEVICE_NAME
- 设备 ID: $DEVICE_ID
- 构建模式: $BUILD_CONFIGURATION
- 应用路径: $APP_PATH
- 应用大小: $APP_SIZE

## 日志文件
- 构建日志: $BUILD_LOG
- 安装日志: $INSTALL_LOG

## 执行步骤
0. ✓ 清理同步冲突文件
1. ✓ 检查设备连接
2. ✓ 清理项目
3. ✓ 更新 Flutter 依赖
4. ✓ 安装 CocoaPods 依赖
5. ✓ 构建 iOS 应用
6. ✓ 验证构建产物
7. ✓ 部署到设备
8. ✓ 生成安装摘要

## 状态
✅ 安装成功

EOF

echo "摘要已保存到: $SUMMARY_LOG"
echo ""
