plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

if (file("google-services.json").exists()) apply(plugin = "com.google.gms.google-services")

val releaseTaskRequested = gradle.startParameter.taskNames.any {
    it.substringAfterLast(':').contains("Release", ignoreCase = true)
}
val releaseStorePath = System.getenv("DOCLYZER_ANDROID_STORE_FILE")
val releaseStorePassword = System.getenv("DOCLYZER_ANDROID_STORE_PASSWORD")
val releaseKeyAlias = System.getenv("DOCLYZER_ANDROID_KEY_ALIAS")
val releaseKeyPassword = System.getenv("DOCLYZER_ANDROID_KEY_PASSWORD")

if (releaseTaskRequested) {
    val missing = listOf(
        "DOCLYZER_ANDROID_STORE_FILE" to releaseStorePath,
        "DOCLYZER_ANDROID_STORE_PASSWORD" to releaseStorePassword,
        "DOCLYZER_ANDROID_KEY_ALIAS" to releaseKeyAlias,
        "DOCLYZER_ANDROID_KEY_PASSWORD" to releaseKeyPassword,
    ).filter { it.second.isNullOrBlank() }.map { it.first }
    if (missing.isNotEmpty()) {
        throw GradleException("Android release signing is required. Set: ${missing.joinToString()}")
    }
    if (!file(releaseStorePath!!).isFile) {
        throw GradleException("DOCLYZER_ANDROID_STORE_FILE must point to an existing keystore")
    }
}

android {
    namespace = "io.envsoft.doclyzer"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "io.envsoft.doclyzer"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            if (releaseTaskRequested) {
                storeFile = file(releaseStorePath!!)
                storePassword = releaseStorePassword
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

flutter {
    source = "../.."
}
