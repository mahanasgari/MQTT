allprojects {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

configurations.configureEach {
    resolutionStrategy.dependencySubstitution {
        substitute(module("com.android.tools.build:gradle")).using(module("com.android.tools.build:gradle:8.3.0"))
        substitute(module("com.android.tools.build:builder")).using(module("com.android.tools.build:builder:8.3.0"))
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
