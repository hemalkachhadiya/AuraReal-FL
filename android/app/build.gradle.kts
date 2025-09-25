plugins {
    id("com.android.application")
    id("kotlin-android")
    id ("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.smarttechnica.aura.real.social.media"
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
<<<<<<< HEAD
        isCoreLibraryDesugaringEnabled = true 
=======
        isCoreLibraryDesugaringEnabled = true
>>>>>>> 4282f2524770eaf9cba2f15c3c74cf2082beada3
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.smarttechnica.aura.real.social.media"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
   




    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so flutter run --release works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
dependencies {
<<<<<<< HEAD
 
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
=======

    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
>>>>>>> 4282f2524770eaf9cba2f15c3c74cf2082beada3
