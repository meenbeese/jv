import std/os
import std/strutils
import src.commands.execute

proc testExecuteJava() =
    let javaFile = "TestProgram.java"
    let outputJar = "TestProgram.jar"
    
    # Prepare a simple Java program for testing
    let javaCode = """
    public class TestProgram {
        public static void main(String[] args) {
            System.out.println("Hello, World!");
        }
    }
    """
    writeFile(javaFile, javaCode)

    # Compile the Java program
    let compileResult = compileJava(javaFile)
    assert compileResult == 0, "Compilation failed"

    # Execute the Java program
    let executionResult = executeJava(outputJar)
    assert executionResult == "Hello, World!\n", "Execution output did not match expected"

    # Clean up
    removeFile(javaFile)
    removeFile(outputJar)

testExecuteJava()
