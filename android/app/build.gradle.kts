plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.secgyu.fuelkeeper"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // flutter_local_notifications 등이 Java 8+ API(java.time)를
        // minSdk 26 미만 환경에서 사용하기 위해 desugaring 활성화 필요.
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.secgyu.fuelkeeper"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // 64-bit ARM 단일 ABI만 포함해 APK 크기를 대폭 줄인다.
        // 2017년 이후 출시된 Android 기기 대부분이 arm64-v8a를 지원한다.
        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    // Flutter는 --target-platform으로 Flutter 엔진 ABI만 제한한다.
    // naver_map_plugin 같은 외부 패키지가 prebuild로 가져오는 .so는
    // packaging.jniLibs.excludes로 직접 걸러내야 다른 ABI가 APK에 포함되지 않는다.
    packaging {
        jniLibs {
            excludes += setOf(
                "lib/x86/**",
                "lib/x86_64/**",
                "lib/armeabi-v7a/**",
            )
        }
    }

    buildTypes {
        release {
            // 포트폴리오 배포용 APK는 debug key 그대로 서명한다.
            // 정식 스토어 배포 시점에 자체 keystore + key.properties 분리 예정.
            signingConfig = signingConfigs.getByName("debug")
            // R8(코드 minify) + 사용 안 하는 리소스 제거.
            // 의존성별 keep 규칙은 각 패키지의 consumer-rules.pro에서 머지된다.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Java 8+ API(java.time 등) desugaring 라이브러리.
    // flutter_local_notifications 21.x가 요구한다.
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
