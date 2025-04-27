import std/os
import std/strutils

proc executeJava(javaClass: string): int =
    if not javaClass.endsWith(".class"):
        echo "Error: The input file must have a .class extension"
        return 1

    if not fileExists(javaClass):
        echo "Error: Class file not found: ", javaClass
        return 1

    let runCommand = "java " & javaClass.stripSuffix(".class")
    let result = execShellCmd(runCommand)

    if result == 0:
        echo "Execution successful."
    else:
        echo "Execution failed with exit code: ", result

    return result
