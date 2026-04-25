// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

val localProperties = Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localProperties.load(localPropertiesFile.inputStream())
}

val baiduMapApiKey = localProperties.getProperty("baidu.map.api.key", "YOUR_BAIDU_MAP_API_KEY")

android {
    namespace = "com.hongchu.lingbanai"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.hongchu.lingbanai"
        minSdk = 24
        targetSdk = 36
        versionCode = 3
        versionName = "1.0.2"
        
        ndk {
            abiFilters.add("arm64-v8a")
        }
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = file(keystoreProperties.getProperty("storeFile"))
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        debug {
            manifestPlaceholders["baiduMapApiKey"] = baiduMapApiKey
        }
        release {
            signingConfig = signingConfigs.getByName("release")
            manifestPlaceholders["baiduMapApiKey"] = baiduMapApiKey
            
            // ===== 开启混淆和资源压缩 =====
            isMinifyEnabled = true
            isShrinkResources = true
            
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    packaging {
        jniLibs {
            pickFirsts.add("lib/armeabi-v7a/libBaiduMapSDK_base_v6_3_1.so")
            pickFirsts.add("lib/arm64-v8a/libBaiduMapSDK_base_v6_3_1.so")
            pickFirsts.add("lib/**/libc++_shared.so")
        }
    }
}

repositories {
    maven { url = uri("https://mapapi.bdimg.com/repository/maven-releases/") }
}

dependencies {
    implementation("com.baidu.lbsyun:BaiduMapSDK_Search:7.6.4")
    implementation("com.baidu.lbsyun:BaiduMapSDK_Util:7.6.4")
    implementation("com.baidu.lbsyun:BaiduMapSDK_Location_All:9.6.4")
    implementation("com.baidu.lbsyun:BaiduMapSDK_Map:7.6.4")
}

flutter {
    source = "../.."
}