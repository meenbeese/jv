import std/os except execShellCmd
import std/strutils
import std/rdstdin

proc getDomainName(): string =
    result = readLineFromStdin("Enter your domain name (e.g., example.com): ").strip()
    if result == "":
        return "example.com"

proc reverseDomain(domain: string): string =
    let parts = domain.split('.')
    var reversed: seq[string] = @[]
    for i in countdown(parts.len - 1, 0):
        reversed.add(parts[i])
    return reversed.join(".")

proc createGradleFiles(packageName: string) =
    writeFile("settings.gradle.kts", """
rootProject.name = "myproject"
""".strip())

    writeFile("build.gradle.kts", """
plugins {
    java
    application
}

group = "$1"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    testImplementation("org.junit.jupiter:junit-jupiter:5.9.2")
    testRuntimeOnly("org.junit.jupiter:junit-jupiter-engine:5.9.2")
}

application {
    mainClass.set("$1.App")
}

tasks.named<Test>("test") {
    useJUnitPlatform()
}
""".format(packageName))

proc createSourceDirectories(packageName: string) =
    let packagePath = packageName.replace(".", "/")
    createDir("src/main/java/" & packagePath)
    createDir("src/test/java/" & packagePath)
    
    let mainPath = "src/main/java/" & packagePath & "/App.java"
    writeFile(mainPath, """
package $1;

public class App {
    public static void main(String[] args) {
        System.out.println("Hello World!");
    }
}
""".format(packageName))

    let testPath = "src/test/java/" & packagePath & "/AppTest.java"
    writeFile(testPath, """
package $1;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

public class AppTest {
    @Test
    public void testApp() {
        assertTrue(true);
    }
}
""".format(packageName))

proc initProject*(): int =
    let domain = getDomainName()
    let packageName = reverseDomain(domain)
    
    createDir(".")
    createGradleFiles(packageName)
    createSourceDirectories(packageName)
    
    echo "Created new Java project with package name: ", packageName
    echo "Run 'gradle build' to build the project"
    return 0
