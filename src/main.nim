import std/os except execShellCmd
import std/strutils
import commands/compile
import commands/execute
import commands/manage
import commands/install
import utils/shell_commands

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
        echo "Usage: jv <command> [options]"
        quit(1)

    let command = paramStr(1)

    case command:
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
            echo "Usage: jv manage <list|install|set|setup> [version]"
            quit(1)
        let subcommand = paramStr(2)
        case subcommand:
        of "setup":
            let status = ensureVersionManager()
            echo status.message
            quit(if status.success: 0 else: 1)
        of "list":
            let versions = listVersions()
            for version in versions:
                echo version
            quit(0)
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
        of "set":
            if paramCount() != 3:
                echo "Usage: jv manage set <version>"
                quit(1)
            if setVersion(paramStr(3)):
                echo "Successfully set Java version to ", paramStr(3)
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
