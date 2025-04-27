import std/os
import std/strutils

proc fileExists(filePath: string): bool =
    return os.fileExists(filePath)

proc removeFile(filePath: string): bool =
    if fileExists(filePath):
        os.removeFile(filePath)
        return true
    return false

proc writeFile(filePath: string, content: string): bool =
    try:
        os.writeFile(filePath, content)
        return true
    except OSError as e:
        echo "Error writing to file: ", e.msg
        return false
