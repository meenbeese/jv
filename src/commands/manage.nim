import std/os except execShellCmd, execCmdEx
import std/strutils
import ../utils/shell_commands
import ../utils/parse_versions
import install

type JavaVersionManager = enum
    JEnv, # macOS and Linux
    Jabba  # All platforms

proc getVersionManager(): JavaVersionManager =
    when defined(windows):
        # Check with PowerShell Get-Command, silencing errors and output
        if execShellCmd("powershell -Command \"if (Get-Command jabba -ErrorAction SilentlyContinue) { exit 0 } else { exit 1 }\" 2>$null", true) == 0:
            return Jabba
        # Check default install location
        let jabbaExe = getEnv("USERPROFILE") / ".jabba" / "bin" / "jabba.exe"
        if fileExists(jabbaExe):
            return Jabba
        return Jabba
    else:
        if execShellCmd("which jenv", true) == 0:
            return JEnv
        elif execShellCmd("which jabba", true) == 0:
            return Jabba
        return Jabba

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
    return @[]

proc searchVersions*(): int =
    case getVersionManager()
    of JEnv:
        echo "jEnv doesn't support remote version listing. Please visit https://adoptium.net for available versions."
        return 1
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        let output = execCmdEx(jabbaCmd & " ls-remote")
        if output.exitCode == 0:
            let versions = output.output.splitLines()
            printVersionTable(versions)
            return 0
    return 1

proc installVersion*(version: string): bool =
    if not ensureVersionManagerExists():
        return false
    
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv add " & version) == 0
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        let urlOutput = execCmdEx(jabbaCmd & " ls-remote " & version)
        if urlOutput.exitCode == 0:
            let url = urlOutput.output.strip()
            echo "Downloading " & version & " (" & url & ")"
            when defined(windows):
                return execShellCmd(jabbaCmd & " install " & version & " >nul 2>&1") == 0
            else:
                return execShellCmd(jabbaCmd & " install " & version & " >/dev/null 2>&1") == 0
        return false

proc setVersion*(version: string): bool =
    if not ensureVersionManagerExists():
        return false
    
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv global " & version) == 0
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        when defined(windows):
            discard execShellCmd(jabbaCmd & " install " & version & " 2>$null")
            
            let jabbaRoot = getEnv("USERPROFILE") / ".jabba"
            let scriptPath = jabbaRoot / "jabba.ps1"
            
            if fileExists(scriptPath):
                if execShellCmd(jabbaCmd & " use " & version) != 0:
                    return false

                let javaHome = execCmdEx(jabbaCmd & " which " & version).output.strip()
                if javaHome.len > 0:
                    # Set JAVA_HOME in user environment
                    discard execShellCmd("setx JAVA_HOME \"" & javaHome & "\"")
                    
                    # Update PATH to include the new Java bin directory (user-level only)
                    let binPath = javaHome / "bin"
                    discard execShellCmd("powershell -Command \"" &
                        # Get User PATH only
                        "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); " &
                        
                        # Remove any existing Java paths
                        "$cleanUserPath = ($userPath.Split(';') | Where-Object { " &
                        "    $_ -notmatch 'java|jdk|jre|Program Files.*\\\\Java|Program Files.*\\\\Microsoft\\\\jdk' " &
                        "}) -join ';'; " &
                        
                        # Put new Java path at the start of User PATH
                        "$newUserPath = '" & binPath.replace("\\", "/") & ";' + $cleanUserPath; " &
                        "[Environment]::SetEnvironmentVariable('PATH', $newUserPath, 'User'); " &
                        
                        # Update current session
                        "$env:JAVA_HOME = '" & javaHome.replace("\\", "/") & "'; " &
                        "$env:PATH = '" & binPath.replace("\\", "/") & ";' + " &
                        "($env:PATH.Split(';') | Where-Object { " &
                        "    $_ -notmatch 'java|jdk|jre|Program Files.*\\\\Java|Program Files.*\\\\Microsoft\\\\jdk' " &
                        "} | ForEach-Object { $_ }) -join ';'\"")
                    return true
            return false
        else:
            return execShellCmd(jabbaCmd & " use " & version) == 0

proc uninstallVersion*(version: string): bool =
    if not ensureVersionManagerExists():
        return false
    
    case getVersionManager()
    of JEnv:
        return execShellCmd("jenv remove " & version) == 0
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        when defined(windows):
            return execShellCmd(jabbaCmd & " uninstall " & version & " >nul 2>&1") == 0
        else:
            return execShellCmd(jabbaCmd & " uninstall " & version & " >/dev/null 2>&1") == 0

proc checkSystemJava(): string =
    when defined(windows):
        let javaCheck = execCmdEx("powershell -NoProfile -NonInteractive -Command \"" &
            "try { " &
            "    $javaPath = (Get-Command java -ErrorAction Stop).Path; " &
            "    if ($javaPath -notmatch '.jabba') { " &
            "        Write-Output 'System Java detected at:'; " &
            "        Write-Output $javaPath; " &
            "        Write-Output ''; " &
            "        Write-Output 'Version information:'; " &
            "        $version = & $javaPath -version 2>&1; " &
            "        $version | ForEach-Object { Write-Output $_.ToString() }; " &
            "    }" &
            "} catch { " &
            "    exit 0; " &
            "}\"")
        
        if javaCheck.exitCode == 0 and javaCheck.output.len > 0:
            return "\nWarning: System-wide Java installation detected!\n\n" & 
                   javaCheck.output & 
                   "\nThis may interfere with jv's version management." &
                   "\nTo fix this:" &
                   "\n1. Uninstall Oracle JDK/JRE from Windows Settings > Apps" &
                   "\n2. Remove Java entries from System PATH" &
                   "\n3. Restart your terminal\n"
    return ""

proc getCurrentVersion*(): string =
    case getVersionManager()
    of JEnv:
        let output = execCmdEx("jenv version")
        if output.exitCode == 0:
            return output.output.strip()
    of Jabba:
        let jabbaCmd = getJabbaCmd()
        try:
            let systemJava = checkSystemJava()
            
            let currentOutput = execCmdEx(jabbaCmd & " current")
            if currentOutput.exitCode == 0 and currentOutput.output.strip().len > 0:
                let jabbaVersion = currentOutput.output.strip()
                let whichOutput = execCmdEx(jabbaCmd & " which " & jabbaVersion)
                if whichOutput.exitCode == 0:
                    let expectedJavaHome = whichOutput.output.strip()
                    let actualJavaHome = getEnv("JAVA_HOME")
                    
                    var result = jabbaVersion
                    if actualJavaHome != expectedJavaHome:
                        result &= "\nWarning: System JAVA_HOME mismatch!\n" &
                                "Expected: " & expectedJavaHome & "\n" &
                                "Actual: " & actualJavaHome
                    
                    if systemJava.len > 0:
                        result &= "\n" & systemJava
                    
                    return result
            
            var result = "No Java version selected in Jabba\n" &
                        "JAVA_HOME=" & getEnv("JAVA_HOME")
            
            if systemJava.len > 0:
                result &= "\n" & systemJava
            
            return result
            
        except:
            echo "Error checking Java version: ", getCurrentExceptionMsg()
    
    return "No Java version detected"
