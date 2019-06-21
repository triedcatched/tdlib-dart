# tdlib_dart/FluGram

Telegram on dart

## Getting Started

This project is based on tdlib and currently only supports Android.
libtdjson.so for arm, arm64 and x86 arch has been pre-built.

To build for Android: Setup flutter, download ndk-bundle from Android sdk manager

`flutter run`



## To create Android APK

```
flutter build apk --release --target-platform android-arm
flutter build apk --release --target-platform android-arm64
flutter build apk --release --target-platform android-x86
```
