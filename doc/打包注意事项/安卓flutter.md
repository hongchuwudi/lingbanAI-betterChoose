## 📱 打包发布前必须检查的配置清单

### 1. **应用名称** (`android:label`)
- **位置**: `android/app/src/main/AndroidManifest.xml`
- **作用**: 手机桌面上显示的名字
- **示例**: `灵伴AI`
- **后果**: 如果还叫 `common_base_mobile_flutter`，用户安装后会看到这个名字，很不专业

### 2. **应用图标** (`android:icon`)
- **位置**: `android/app/src/main/res/mipmap-*` 文件夹
- **作用**: 手机桌面上显示的图标
- **示例**: 替换所有 `ic_launcher.png` 文件
- **后果**: 如果还是 Flutter 默认的蓝色图标，用户认不出来

### 3. **包名** (`applicationId` / `namespace`)
- **位置**: `android/app/build.gradle`
- **作用**: 应用的唯一标识，相当于身份证号
- **格式**: 通常是 `com.公司名.项目名`
- **示例**: `com.hongchu.lingbanai`
- **后果**: 
  - 一旦发布到应用商店，**永远不能改**
  - 如果和别人重名，发布失败
  - 改了之后，之前安装的用户收不到更新

### 4. **版本号** (`versionCode` / `versionName`)
- **位置**: `android/app/build.gradle`
- **作用**: 标识版本新旧
- **示例**: 
  ```gradle
  versionCode 1   // 第一次发布是1，以后每次更新 +1
  versionName "1.0.0"  // 用户看到的版本号
  ```
- **后果**: 
  - `versionCode` 不递增，用户收不到更新
  - `versionName` 随便写，用户看到会困惑

### 5. **最低支持版本** (`minSdkVersion`)
- **位置**: `android/app/build.gradle`
- **作用**: 最低支持到哪个 Android 版本
- **建议**: `minSdkVersion 21` (Android 5.0)
- **后果**: 设太高，老手机装不上；设太低，部分功能用不了

### 6. **权限申请**
- **位置**: `android/app/src/main/AndroidManifest.xml`
- **作用**: 告诉用户你的 App 需要什么权限
- **示例**: 相机、定位、存储等
- **后果**: 忘记加权限，功能用不了；加多了，用户不敢安装

---

## 📋 打包前检查清单

| 检查项 | 文件位置 | 是否已改？ |
|--------|----------|-----------|
| 应用名称 | `AndroidManifest.xml` → `android:label` | ☐ |
| 应用图标 | `res/mipmap-*/ic_launcher.png` | ☐ |
| 包名 | `build.gradle` → `namespace` 和 `applicationId` | ☐ |
| 版本号 | `build.gradle` → `versionCode` / `versionName` | ☐ |
| 最低版本 | `build.gradle` → `minSdkVersion` | ☐ |
| 权限 | `AndroidManifest.xml` → `<uses-permission>` | ☐ |
| 签名文件 | `build.gradle` → `signingConfigs` | ☐ |

---

## 🔑 最重要的：签名文件

发布版 App 还需要**签名文件**（相当于你的电子身份证）：

```gradle
// android/app/build.gradle
android {
    signingConfigs {
        release {
            storeFile file("your-keystore.jks")      // 签名文件
            storePassword "你的密码"
            keyAlias "key-alias"
            keyPassword "你的密码"
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 生成签名文件命令
```bash
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key-alias
```

**⚠️ 重要**：
- 签名文件**一定要保存好**，丢了就再也无法更新 App
- 密码**一定要记住**
- 用**新电脑打包**时需要把签名文件拷过去

---

## 🚀 打包发布流程

### 1. 修改所有配置
按上面的清单逐项修改

### 2. 生成签名文件
```bash
keytool -genkey -v -keystore release.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

### 3. 配置签名
在 `android/app/build.gradle` 中添加签名配置

### 4. 打包
```bash
# 清理旧文件
flutter clean

# 获取依赖
flutter pub get

# 打包 Release APK
flutter build apk --release

# 或者打包 App Bundle（Google Play 推荐）
flutter build appbundle --release
```

### 5. 找到安装包
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`

---

## 📱 发布到应用商店

| 平台 | 需要提交 |
|------|---------|
| **Google Play** | `.aab` 文件 + 截图 + 描述 + 隐私政策 |
| **华为应用市场** | `.apk` 或 `.aab` + 软著 |
| **小米应用商店** | `.apk` + 软著 |
| **腾讯应用宝** | `.apk` + 软著 |
| **iOS App Store** | `.ipa` + 99美元年费 + 审核 |

---

## ✅ 总结

打包发布前，你必须填好：
1. **应用信息**：名称、图标、包名、版本号
2. **签名文件**：你的 App 身份证
3. **权限**：告诉用户需要什么权限
4. **最低版本**：决定哪些手机能装

**这些都是一次性配置，配好后以后打包只需要改版本号就行！**