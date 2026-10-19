allprojects {
    repositories {
        google()
        mavenCentral()
    }
    // Some plugins pull androidx.core 1.18 which needs AGP 8.9 / compileSdk 36.
    configurations.all {
        resolutionStrategy {
            force("androidx.core:core:1.15.0", "androidx.core:core-ktx:1.15.0")
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
