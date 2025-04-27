import std/os except execShellCmd
import std/strutils
import ../utils/shell_commands

proc executeJava*(javaClass: string): int =
    if not javaClass.endsWith(".class"):
        echo "Error: The input file must have a .class extension"
        return 1

    if not fileExists(javaClass):
        echo "Error: Class file not found: ", javaClass
        return 1

    let javaCmd = when defined(windows):
        let javaPath = getEnv("JAVA_HOME", "") / "bin" / "java.exe"
        if fileExists(javaPath): javaPath else: "java.exe"
    else:
        "java"

    let className = javaClass.replace(".class", "")
    let runCommand = javaCmd & " " & className
    let exitCode = execShellCmd(runCommand)

    if exitCode == 0:
        echo "Execution successful."
    else:
        echo "Execution failed with exit code: ", exitCode

    return exitCode
