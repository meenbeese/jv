import std/os except execShellCmd, execCmdEx
import std/strutils
import ../utils/shell_commands
import install

type JavaVersionManager = enum
    JEnv, # macOS and Linux
    Jabba, # All platforms
    Manual # Windows fallback

proc getVersionManager(): JavaVersionManager =
    when defined(windows):
        # Check with PowerShell Get-Command, silencing errors and output
        if execShellCmd("powershell -Command \"if (Get-Command jabba -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }\" 2>$null", true) == 0:
            return Jabba
        # Check default install location
        let jabbaExe = getEnv("USERPROFILE") / ".jabba" / "bin" / "jabba.exe"
        if fileExists(jabbaExe):
            return Jabba
        return Manual
    else:
        if execShellCmd("which jenv", true) == 0:
            return JEnv
        elif execShellCmd("which jabba", true) == 0:
            return Jabba
        return Manual

proc getJabbaCmd*(): string =
    when defined(windows):
        let jabbaExe = getEnv("USERPROFILE") / ".jabba" / "bin" / "jabba.exe"
        if fileExists(jabbaExe):
            return jabbaExe
        else:
            return "jabba"
    else:
        let jabbaBin = getEnv("HOME") / ".jabba" / "bin" / "jabba"
        if fileExists(jabbaBin):
            return jabbaBin
        else:
            return "jabba"

proc ensureVersionManagerExists*(): bool =
    let status = ensureVersionManager()
    if not status.success:
        echo status.message
        echo "Please install a version manager:"
        echo "  - Jabba (recommended for all platforms): https://github.com/shyiko/jabba"
        when not defined(windows):
            echo "  - jEnv (for macOS/Linux): https://github.com/jenv/jenv"
        return false
    return true

proc listVersions*(): seq[string] =
    if not ensureVersionManagerExists():
        return @[]
    
    case getVersionManager()
    of JEnv:
        let output = execCmdEx("jenv versions")
        if output.exitCode == 0:
            return output.output.splitLines()
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        let fullCmd = jabbaCmd & " ls"
        let output = execCmdEx(fullCmd)
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

proc searchVersions*(): seq[string] =
    case getVersionManager()
    of JEnv:
        echo "jEnv doesn't support remote version listing. Please visit https://adoptium.net for available versions."
        return @[]
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        let output = execCmdEx(jabbaCmd & " ls-remote")
        if output.exitCode == 0:
            return output.output.splitLines()
    of Manual:
        echo "Please visit https://adoptium.net for available versions."
        return @[]
    return @[]

proc installVersion*(version: string): bool =
    if not ensureVersionManagerExists():
        return false
    
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv add " & version) == 0
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        return execShellCmd(jabbaCmd & " install " & version) == 0
    of Manual:
        echo "Please install Java " & version & " manually from https://adoptium.net"
        return false

proc setVersion*(version: string): bool =
    if not ensureVersionManagerExists():
        return false
    
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv global " & version) == 0
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        return execShellCmd(jabbaCmd & " use " & version) == 0
    of Manual:
        when defined(windows):
            return execShellCmd("setx JAVA_HOME \"" & version & "\"") == 0
        else:
            return execShellCmd("export JAVA_HOME=" & version) == 0
