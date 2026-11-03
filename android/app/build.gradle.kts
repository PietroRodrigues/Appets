plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

import java.util.Properties

// O keystore de release e a sua senha ficam fora do git (ignorados).
// Configuracao: android/key.properties (copiar de android/key.properties.example).
val keystorePropertiesFile = rootProject.file("key.properties")

if (!keystorePropertiesFile.exists()) {
    throw GradleException(
        "Arquivo 'android/key.properties' não encontrado. " +
        "Copie 'android/key.properties.example' para 'android/key.properties' " +
        "e preencha storeFile, storePassword, keyAlias e keyPassword " +
        "antes de gerar builds de release."
    )
}

val keystoreProperties = Properties().apply {
    keystorePropertiesFile.inputStream().use { load(it) }
}

android {
    namespace = "com.pietrorodriguesdev.appets"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // applicationId definitivo: não alterar após o primeiro envio à Play Store.
        applicationId = "com.pietrorodriguesdev.appets"
        // versionName/versionCode são propagados pelo Flutter a partir do
        // pubspec.yaml (version: X.Y.Z+BUILD). Política de versionamento no pubspec.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")?.trim()?.takeIf { it.isNotEmpty() }
                ?: throw GradleException("Propriedade 'keyAlias' ausente ou vazia em android/key.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword")?.trim()?.takeIf { it.isNotEmpty() }
                ?: throw GradleException("Propriedade 'keyPassword' ausente ou vazia em android/key.properties")
            storeFile = file(
                keystoreProperties.getProperty("storeFile")?.trim()?.takeIf { it.isNotEmpty() }
                    ?: throw GradleException("Propriedade 'storeFile' ausente ou vazia em android/key.properties")
            )
            storePassword = keystoreProperties.getProperty("storePassword")?.trim()?.takeIf { it.isNotEmpty() }
                ?: throw GradleException("Propriedade 'storePassword' ausente ou vazia em android/key.properties")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            // Item 80: habilitar minifyEnabled/shrinkResources aqui.
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // Firebase BoM - gerencia versões automaticamente
    implementation(platform("com.google.firebase:firebase-bom:34.18.0"))

    // Firebase Auth
    implementation("com.google.firebase:firebase-auth")

    // Cloud Firestore
    implementation("com.google.firebase:firebase-firestore")

    // Firebase Storage
    implementation("com.google.firebase:firebase-storage")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
