import std/os

proc execShellCmd(command: string): int =
    let result = os.execShellCmd(command)
    return result
