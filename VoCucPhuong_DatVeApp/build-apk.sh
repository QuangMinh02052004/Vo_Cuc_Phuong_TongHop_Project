#!/bin/bash
# Build release APK cho app khách hàng (VCP Đặt Vé)
# Usage: ./build-apk.sh

set -e

export JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH
export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
export ANDROID_SDK_ROOT=$ANDROID_HOME

cd "$(dirname "$0")"

echo "==> Java: $(java -version 2>&1 | head -1)"
echo "==> Flutter clean..."
flutter clean > /dev/null

echo "==> pub get..."
flutter pub get > /dev/null

echo "==> Build APK release (signed)..."
flutter build apk --release --split-per-abi

echo ""
echo "✅ Xong! Files APK ở:"
ls -lh build/app/outputs/flutter-apk/*.apk
echo ""
echo "→ Gửi file 'app-arm64-v8a-release.apk' cho khách hàng (máy đời mới)"
echo "→ Hoặc 'app-armeabi-v7a-release.apk' cho máy cũ"
