import std/os
import std/strutils

proc listVersions(): seq[string] =
    let versions = os.execShellCmd("jenv versions")
    return versions.splitLines()

proc installVersion(version: string): bool =
    let result = os.execShellCmd("jenv add " & version)
    return result == 0

proc setVersion(version: string): bool =
    let result = os.execShellCmd("jenv global " & version)
    return result == 0
