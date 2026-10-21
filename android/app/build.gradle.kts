import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

/**
 * Release signing comes from `android/keystore.properties` locally (never committed) or from
 * environment variables in CI. Without either, release builds are left unsigned.
 */
val signing = Properties().apply {
    rootProject.file("keystore.properties").takeIf { it.exists() }?.inputStream()?.use(::load)
}
fun signingValue(key: String, env: String): String? = signing.getProperty(key) ?: System.getenv(env)?.takeIf { it.isNotBlank() }

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
        // The B4A release was versionCode 3. CI numbers each release after its run, so every
        // published APK installs as an update of the one before.
        val ciRun = System.getenv("GITHUB_RUN_NUMBER")?.toIntOrNull()
        versionCode = if (ciRun != null) 100 + ciRun else 20
        versionName = if (ciRun != null) "2.0.$ciRun" else "2.0.0"
        vectorDrawables.useSupportLibrary = true
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
            versionNameSuffix = "-dev"
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
        compose = true
        buildConfig = true
    }
    androidResources {
        // The book databases are already XOR-scrambled; compressing them only slows the first-run copy.
        noCompress += "book"
    }
    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

/**
 * The books are maintained once, in the B4A project's `Files/` folder, and shared with the web app;
 * this copies them into the APK's assets as `books/N.book` at build time.
 */
abstract class CopyBooks : DefaultTask() {
    @get:InputFiles
    abstract val books: ConfigurableFileCollection

    @get:OutputDirectory
    abstract val outputDir: DirectoryProperty

    @TaskAction
    fun copy() {
        val target = outputDir.get().asFile.resolve("books")
        target.deleteRecursively()
        target.mkdirs()
        books.files.forEach { it.copyTo(target.resolve(it.name), overwrite = true) }
    }
}

val copyBooks = tasks.register<CopyBooks>("copyBooks") {
    books.from(rootProject.fileTree("../Files") { include("*.book") })
}

androidComponents {
    onVariants { variant ->
        variant.sources.assets?.addGeneratedSourceDirectory(copyBooks, CopyBooks::outputDir)
    }
}

dependencies {
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.lifecycle.runtime.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.datastore.preferences)

    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.foundation)
    implementation(libs.androidx.compose.material3)
    implementation(libs.androidx.compose.material.icons.extended)
    debugImplementation(libs.androidx.compose.ui.tooling)
}
