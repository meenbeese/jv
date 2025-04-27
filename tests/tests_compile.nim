import std/os
import std/strutils
import src.commands.compile
import src.utils.file_operations

proc testCompileJava() =
    let testJavaFile = "Test.java"
    let expectedClassFile = "Test.class"
    
    # Create a simple Java file for testing
    writeFile(testJavaFile, """
    public class Test {
        public static void main(String[] args) {
            System.out.println("Hello, World!");
        }
    }
    """)

    # Compile the Java file
    compileJava(testJavaFile)

    # Check if the class file was created
    if not fileExists(expectedClassFile):
        echo "Test failed: Class file was not created."
        quit(1)

    # Clean up the generated files
    removeFile(testJavaFile)
    removeFile(expectedClassFile)

    echo "Test passed: Class file was created successfully."

testCompileJava()
