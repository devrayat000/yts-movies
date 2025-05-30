plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load keystore properties for signing
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.dev.standard.ytsmovies"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    defaultConfig {
        multiDexEnabled = true
    }

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 11
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.dev.standard.ytsmovies"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode        
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        release {
            // Use release signing config for production builds
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}


// def localProperties = new Properties()
// def localPropertiesFile = rootProject.file('local.properties')
// if (localPropertiesFile.exists()) {
//     localPropertiesFile.withReader('UTF-8') { reader ->
//         localProperties.load(reader)
//     }
// }

// def flutterRoot = localProperties.getProperty('flutter.sdk')
// if (flutterRoot == null) {
//     throw new GradleException("Flutter SDK not found. Define location with flutter.sdk in the local.properties file.")
// }

// def flutterVersionCode = localProperties.getProperty('flutter.versionCode')
// if (flutterVersionCode == null) {
//     flutterVersionCode = '1'
// }

// def flutterVersionName = localProperties.getProperty('flutter.versionName')
// if (flutterVersionName == null) {
//     flutterVersionName = '1.0'
// }
// // For Production
// // def keystoreProperties = new Properties()
// // def keystorePropertiesFile = rootProject.file('key.properties')
// // if (keystorePropertiesFile.exists()) {
// //     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
// // }

// apply plugin: 'com.android.application'
// apply plugin: 'kotlin-android'
// apply plugin: 'kotlin-android-extensions'
// apply from: "$flutterRoot/packages/flutter_tools/gradle/flutter.gradle"

// android {
//     compileSdkVersion 33
//     ndkVersion flutter.ndkVersion

//     compileOptions {
//         sourceCompatibility JavaVersion.VERSION_1_8
//         targetCompatibility JavaVersion.VERSION_1_8
//     }

//     kotlinOptions {
//         jvmTarget = '1.8'
//     }

//     sourceSets {
//         main.java.srcDirs += 'src/main/kotlin'
//     }

//     defaultConfig {
//         // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
//         applicationId "com.dev.standard.ytsmovies"
//         // You can update the following values to match your application needs.
//         // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-gradle-build-configuration.
//         minSdkVersion 21
//         targetSdkVersion flutter.targetSdkVersion
//         versionCode flutterVersionCode.toInteger()
//         versionName flutterVersionName
//     }

//     // For Production
//     // signingConfigs {
//     //    release {
//     //         keyAlias keystoreProperties['keyAlias']
//     //         keyPassword keystoreProperties['keyPassword']
//     //         storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
//     //         storePassword keystoreProperties['storePassword']
//     //     }
//     // }

//     buildTypes {
//         release {
//             // TODO: Add your own signing config for the release build.
//             // Signing with the debug keys for now, so `flutter run --release` works.
//             signingConfig signingConfigs.debug
//             // For production
//             // minifyEnabled true //Important step
//             // shrinkResources true
//             // proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
//             // signingConfig signingConfigs.release
//         }
//     }
// }

// flutter {
//     source '../..'
// }

// dependencies {
//     implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
//     implementation 'androidx.cardview:cardview:1.0.0'
// }
