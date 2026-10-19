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

// Plugins that still compile Java as 1.8 clash with Kotlin's default JVM target
// on newer JDKs ("Inconsistent JVM-target compatibility"): make Kotlin follow
// each library's own Java target.
subprojects {
    val align = Action<Project> {
        val android = extensions.findByType<com.android.build.gradle.LibraryExtension>() ?: return@Action
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions.jvmTarget.set(
                provider {
                    org.jetbrains.kotlin.gradle.dsl.JvmTarget.fromTarget(android.compileOptions.targetCompatibility.toString())
                },
            )
        }
    }
    if (state.executed) align.execute(this) else afterEvaluate(align)
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
