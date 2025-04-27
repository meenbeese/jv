import std/os except execShellCmd
import std/strutils
import ../utils/shell_commands

proc compileJava*(javaFile: string): int =
    if not javaFile.endsWith(".java"):
        echo "Error: The input file must have a .java extension"
        return 1

    if not fileExists(javaFile):
        echo "Error: Java file not found: ", javaFile
        return 1

    let javacCmd = when defined(windows):
        let javacPath = getEnv("JAVA_HOME", "") / "bin" / "javac.exe"
        if fileExists(javacPath): javacPath else: "javac.exe"
    else:
        "javac"

    let compileCommand = javacCmd & " " & javaFile
    let exitCode = execShellCmd(compileCommand)

    if exitCode == 0:
        echo "Compilation successful."
    else:
        echo "Compilation failed with exit code: ", exitCode

    return exitCode
