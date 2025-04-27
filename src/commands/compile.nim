proc compileJava(javaFile: string): int =
    import os, strutils

    if not javaFile.endsWith(".java"):
        echo "Error: The input file must have a .java extension"
        return 1

    if not fileExists(javaFile):
        echo "Error: Java file not found: ", javaFile
        return 1

    let compileCommand = "javac " & javaFile
    let result = execShellCmd(compileCommand)

    if result == 0:
        echo "Compilation successful."
    else:
        echo "Compilation failed with exit code: ", result

    return result
