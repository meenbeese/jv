import std/os except execShellCmd, execCmdEx
import std/strutils
import ../utils/shell_commands

type JavaVersionManager = enum
    JEnv, # macOS and Linux
    Jabba, # All platforms
    Manual # Windows fallback

proc getVersionManager(): JavaVersionManager =
    when defined(windows):
        if execShellCmd("where jabba") == 0:
            return Jabba
        return Manual
    else:
        if execShellCmd("which jenv") == 0:
            return JEnv
        elif execShellCmd("which jabba") == 0:
            return Jabba
        return Manual

proc listVersions*(): seq[string] =
    case getVersionManager()
    of JEnv:
        let output = execCmdEx("jenv versions")
        if output.exitCode == 0:
            return output.output.splitLines()
    of Jabba:
        let output = execCmdEx("jabba ls")
        if output.exitCode == 0:
            return output.output.splitLines()
    of Manual:
        when defined(windows):
            let output = execCmdEx("dir /B \"%JAVA_HOME%\"")
            if output.exitCode == 0:
                return output.output.splitLines()
        else:
            let output = execCmdEx("/usr/libexec/java_home -V")
            if output.exitCode == 0:
                return output.output.splitLines()
    return @[]

proc installVersion*(version: string): bool =
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv add " & version) == 0
    of Jabba:
        return execShellCmd("jabba install " & version) == 0
    of Manual:
        echo "Please install Java " & version & " manually from https://adoptium.net"
        return false

proc setVersion*(version: string): bool =
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv global " & version) == 0
    of Jabba:
        return execShellCmd("jabba use " & version) == 0
    of Manual:
        when defined(windows):
            return execShellCmd("setx JAVA_HOME \"" & version & "\"") == 0
        else:
            return execShellCmd("export JAVA_HOME=" & version) == 0
