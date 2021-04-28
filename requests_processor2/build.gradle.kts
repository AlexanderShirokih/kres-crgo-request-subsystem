import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
    kotlin("jvm") version "1.3.72"
    application
}

group = "ru.aleshi"
version = "1.0-SNAPSHOT"

application {
    mainClassName = "ru.aleshi.requests.AppKt"
}

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    implementation("com.google.code.gson:gson:2.8.6")
    implementation("org.apache.poi:poi:4.1.2")
    implementation("org.apache.poi:poi-ooxml:4.1.2")
    implementation("org.apache.pdfbox:pdfbox:2.0.21")
    implementation("org.apache.commons:commons-lang3:3.11")
}

val compileKotlin: KotlinCompile by tasks

compileKotlin.kotlinOptions {
    languageVersion = "1.4"
}