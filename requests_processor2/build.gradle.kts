plugins {
    kotlin("jvm") version "1.3.72"
    application
}

group = "ru.aleshi"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    implementation("com.google.code.gson:gson:2.8.6")
    implementation("org.apache.poi:poi:4.1.2")
    implementation("org.apache.pdfbox:pdfbox:2.0.21")
    implementation("org.apache.commons:commons-lang3:3.11")
}