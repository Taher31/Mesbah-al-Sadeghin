import groovy.json.JsonSlurper
import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
}

/**
 * Release signing comes from `android/keystore.properties` locally (never committed) or from
 * environment variables in CI. Without either, release builds are left unsigned.
 */
val signing = Properties().apply {
    rootProject.file("keystore.properties").takeIf { it.exists() }?.inputStream()?.use(::load)
}
fun signingValue(key: String, env: String): String? = signing.getProperty(key) ?: System.getenv(env)?.takeIf { it.isNotBlank() }

val webPackage = JsonSlurper().parse(rootProject.file("../web/package.json")) as Map<*, *>
val appVersion = webPackage["version"] as String
val versionParts = requireNotNull(Regex("""(\d+)\.(\d{1,3})\.(\d{1,3})""").matchEntire(appVersion)) {
    "Use a major.minor.patch version in web/package.json, with minor and patch below 1000."
}.groupValues.drop(1).map { it.toLong() }
val (major, minor, patch) = versionParts
require(major <= 2099) { "The major version is too large for an Android versionCode." }
// Reserve three digits each for minor and patch so later releases can update earlier APKs.
val appVersionCode = major * 1_000_000 + minor * 1_000 + patch
require(appVersionCode > 0) { "The Android versionCode must be positive." }

android {
    namespace = "ir.sadeghin.mesbah"
    compileSdk = 36
    // Only build-tools 36.0.0 is installed locally; pin it so AGP doesn't try to download another.
    buildToolsVersion = "36.0.0"

    defaultConfig {
        // Same id as the B4A release, so a release signed with the original key updates it in place.
        applicationId = "MesbahoSadeghin.App"
        minSdk = 21
        targetSdk = 36
        versionCode = appVersionCode.toInt()
        versionName = appVersion
    }

    val storePath = signingValue("storeFile", "ANDROID_KEYSTORE_PATH")
    signingConfigs {
        if (storePath != null) {
            create("release") {
                storeFile = file(storePath)
                storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
                keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
                keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            }
        }
    }

    buildTypes {
        debug {
            // Lets the dev build sit next to the installed B4A build on a test phone.
            applicationIdSuffix = ".dev"
        }
        release {
            signingConfig = signingConfigs.findByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        buildConfig = true
    }
    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

/**
 * The app is the web app (web/), built once and shared with the website: this copies its build
 * (`web/dist`, from `npm run build` there) into the APK's assets as `web/`. The site's download
 * folder and server and service-worker files are left out; the APK serves the files itself.
 */
abstract class CopyWebApp : DefaultTask() {
    @get:InputFiles
    abstract val dist: ConfigurableFileCollection

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty

    @TaskAction
    fun copy() {
        val root = dist.files.single()
        val index = root.resolve("index.html")
        check(index.isFile) { "${root.path} has no index.html: run `npm ci && npm run build` in web/ first." }
        // The site may be built for a sub-folder (GitHub Pages); the APK serves it from the root.
        check(index.readText().contains("\"/assets/")) {
            "web/dist was built for a sub-folder (BASE_PATH); rebuild it with `npm run build` and no BASE_PATH."
        }
        val target = outputDir.get().asFile.resolve("web")
        target.deleteRecursively()
        root.copyRecursively(target)
        listOf("download", ".htaccess", "sw.js").forEach { target.resolve(it).deleteRecursively() }
    }
}

val copyWebApp = tasks.register<CopyWebApp>("copyWebApp") {
    dist.from(rootProject.file("../web/dist"))
}

androidComponents {
    onVariants { variant ->
        variant.sources.assets?.addGeneratedSourceDirectory(copyWebApp, CopyWebApp::outputDir)
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity)
}
