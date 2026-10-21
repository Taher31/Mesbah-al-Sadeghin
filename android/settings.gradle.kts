// Google Maven (dl.google.com) answers 404 from the developer's network in Iran, so local builds
// resolve AndroidX through public mirrors of it. CI runners (GitHub Actions sets CI=true) reach
// Google directly, and go there first.
val onCi = System.getenv("CI") == "true"

fun RepositoryHandler.mirrors() {
    maven("https://mirrors.tencent.com/nexus/repository/maven-public")
    maven("https://repo.huaweicloud.com/repository/maven")
}

pluginManagement {
    val onCi = System.getenv("CI") == "true"
    repositories {
        if (onCi) {
            google()
            gradlePluginPortal()
            mavenCentral()
        } else {
            maven("https://mirrors.tencent.com/nexus/repository/maven-public")
            maven("https://repo.huaweicloud.com/repository/maven")
            gradlePluginPortal()
            mavenCentral()
            google()
        }
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        if (onCi) {
            google()
            mavenCentral()
        } else {
            mirrors()
            mavenCentral()
            google()
        }
    }
}

rootProject.name = "MesbahSadeghin"
include(":app")
