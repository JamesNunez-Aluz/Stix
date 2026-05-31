allprojects {
    repositories {
        google()
        mavenCentral()
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

// Some Flutter plugins (e.g. receive_sharing_intent) ship Java 11 + Kotlin 17,
// which Gradle rejects as an inconsistent JVM target. Bump every Android
// *library* module's Java compatibility to 17 so it matches their Kotlin.
// Done via plugins.withId (not afterEvaluate) so it runs as the plugin applies.
subprojects {
    plugins.withId("com.android.library") {
        val androidExt =
            extensions.getByName("android") as com.android.build.gradle.BaseExtension
        androidExt.compileOptions {
            sourceCompatibility = JavaVersion.VERSION_17
            targetCompatibility = JavaVersion.VERSION_17
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
