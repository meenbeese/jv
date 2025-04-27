import std/os
import std/strutils
import commands/compile
import commands/execute
import commands/manage_versions

proc main() =
    if paramCount() < 2:
        echo "Usage: java-tool <command> [options]"
        quit(1)

    let command = paramStr(1)

    case command:
    of "compile":
        if paramCount() != 3:
            echo "Usage: java-tool compile <javaFile>"
            quit(1)
        compileJava(paramStr(2))
    of "execute":
        if paramCount() != 3:
            echo "Usage: java-tool execute <className>"
            quit(1)
        executeJava(paramStr(2))
    of "manage":
        if paramCount() < 3:
            echo "Usage: java-tool manage <subcommand> [options]"
            quit(1)
        let subcommand = paramStr(2)
        if subcommand == "list":
            listVersions()
        elif subcommand == "install":
            if paramCount() != 4:
                echo "Usage: java-tool manage install <version>"
                quit(1)
            installVersion(paramStr(3))
        elif subcommand == "set":
            if paramCount() != 4:
                echo "Usage: java-tool manage set <version>"
                quit(1)
            setVersion(paramStr(3))
        else:
            echo "Unknown manage subcommand: ", subcommand
            quit(1)
    else:
        echo "Unknown command: ", command
        quit(1)

main()
