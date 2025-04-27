import std/osproc
import std/strutils

proc normalizeCmd(cmd: string): string =
    when defined(windows):
        cmd.replace("/", "\\")
    else:
        cmd.replace("\\", "/")

proc execShellCmd*(command: string): int =
    let normalizedCmd = normalizeCmd(command)
    when defined(windows):
        echo "Executing on Windows: ", normalizedCmd
        result = execCmd("cmd /c " & normalizedCmd)
    else:
        echo "Executing on Unix-like system: ", normalizedCmd
        result = execCmd("/bin/sh -c '" & normalizedCmd & "'")

proc execCmdEx*(command: string): tuple[output: string, exitCode: int] =
    let normalizedCmd = normalizeCmd(command)
    when defined(windows):
        osproc.execCmdEx("cmd /c " & normalizedCmd)
    else:
        osproc.execCmdEx("/bin/sh -c '" & normalizedCmd & "'")
