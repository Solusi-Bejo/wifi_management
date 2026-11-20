group = "com.solusibejo.wifi_management"
version = "1.0-SNAPSHOT"

buildscript {
    // The oldest toolchain this plugin supports (Flutter 3.41 apps: AGP 8,
    // KGP 2.x). The app's own AGP/KGP win on the classpath.
    val kotlinVersion = "2.2.20"
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.11.1")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlinVersion")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.library")
}

// AGP 9 compiles Kotlin itself ("built-in Kotlin", Flutter 3.44+). Apps on
// AGP 8 (e.g. Flutter 3.41) still need the Kotlin Gradle Plugin, and Flutter
// before 3.47 does not apply it for plugins, so do it here when needed.
val agpMajor = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION
    .substringBefore('.')
    .toInt()
val usesBuiltInKotlin = agpMajor >= 9 &&
    (findProperty("android.builtInKotlin")?.toString()?.toBoolean() ?: true)
if (!usesBuiltInKotlin) {
    apply(plugin = "org.jetbrains.kotlin.android")
}

android {
    namespace = "com.solusibejo.wifi_management"

    compileSdk = 36

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    sourceSets {
        getByName("main") {
            java.srcDirs("src/main/kotlin")
        }
        getByName("test") {
            java.srcDirs("src/test/kotlin")
        }
    }

    defaultConfig {
        // The plugin reports `unsupported` below API 29 at runtime.
        minSdk = 24
    }

    testOptions {
        unitTests {
            isIncludeAndroidResources = true
            all {
                it.useJUnitPlatform()
                it.outputs.upToDateWhen { false }
                it.testLogging {
                    events("passed", "skipped", "failed", "standardOut", "standardError")
                    showStandardStreams = true
                }
            }
        }
    }
}

// Works with both KGP and built-in Kotlin (the `kotlin {}` accessor only
// exists when KGP is in the plugins block).
tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinJvmCompile>().configureEach {
    compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
}

dependencies {
    testImplementation("org.jetbrains.kotlin:kotlin-test")
}
