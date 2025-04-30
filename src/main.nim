import std/os except execShellCmd
import std/strutils
import std/parsecfg
import commands/compile
import commands/execute
import commands/manage
import commands/install
import commands/init
import commands/options
import utils/shell_commands

proc getVersion(): string =
    let nimblePath = getCurrentDir() / "jv.nimble"
    if fileExists(nimblePath):
        let dict = loadConfig(nimblePath)
        return dict.getSectionValue("", "version")
    return "unknown"

proc runTests(): int =
    for kind, path in walkDir("tests"):
        if kind == pcFile and path.endsWith(".nim"):
            echo "Running test: ", path
            let exitCode = execShellCmd("nim c -r " & path)
            if exitCode != 0:
                echo "Test failed: ", path
                return exitCode
    return 0

proc main() =
    if paramCount() < 1:
        printHelp()
        quit(1)

    let command = paramStr(1)

    case command:
    of "version":
        echo "jv version ", getVersion()
        quit(0)
    of "help":
        printHelp()
        quit(0)
    of "init":
        quit(initProject())
    of "test":
        quit(runTests())
    of "compile":
        if paramCount() != 2:
            echo "Usage: jv compile <javaFile>"
            quit(1)
        quit(compileJava(paramStr(2)))
    of "execute":
        if paramCount() != 2:
            echo "Usage: jv execute <className>"
            quit(1)
        quit(executeJava(paramStr(2)))
    of "manage":
        if paramCount() < 2:
            echo "Usage: jv manage <list|search|current|install|uninstall|set> [version]"
            quit(1)
        let subcommand = paramStr(2)
        case subcommand:
        of "list":
            let versions = listVersions()
            for version in versions:
                echo version
            quit(0)
        of "current":
            let currentVersion = getCurrentVersion()
            if currentVersion.len > 0:
                echo currentVersion
                quit(0)
            else:
                echo "No Java version currently selected"
                quit(1)
        of "search":
            quit(searchVersions())
        of "install":
            if paramCount() != 3:
                echo "Usage: jv manage install <version>"
                quit(1)
            if installVersion(paramStr(3)):
                echo "Successfully installed Java ", paramStr(3)
                quit(0)
            else:
                echo "Failed to install Java ", paramStr(3)
                quit(1)
        of "uninstall":
            if paramCount() != 3:
                echo "Usage: jv manage uninstall <version>"
                quit(1)
            if uninstallVersion(paramStr(3)):
                echo "Successfully uninstalled Java ", paramStr(3)
                quit(0)
            else:
                echo "Failed to uninstall Java ", paramStr(3)
                quit(1)
        of "set":
            if paramCount() != 3:
                echo "Usage: jv manage set <version>"
                quit(1)
            if setVersion(paramStr(3)):
                echo "Successfully set Java version to ", paramStr(3)
                when defined(windows):
                    echo "\nTo use the new version, either:"
                    echo "1. Start a new terminal session"
                    echo "2. Run 'RefreshEnv' in PowerShell"
                else:
                    echo "\nTo use the new version, either:"
                    echo "1. Start a new terminal session"
                    echo "2. Run 'source ~/.bashrc' (bash) or 'source ~/.zshrc' (zsh)"
                quit(0)
            else:
                echo "Failed to set Java version to ", paramStr(3)
                quit(1)
        else:
            echo "Unknown manage subcommand: ", subcommand
            quit(1)
    else:
        echo "Unknown command: ", command
        quit(1)

main()
