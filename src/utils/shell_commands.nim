import std/osproc
import std/strutils

proc normalizeCmd(cmd: string): string =
    when defined(windows):
        cmd.replace("/", "\\")
    else:
        cmd.replace("\\", "/")

proc execShellCmd*(command: string; silent: bool = true): int =
    let normalizedCmd = normalizeCmd(command)
    if not silent:
        when defined(windows):
            echo "Executing on Windows: ", normalizedCmd
        else:
            echo "Executing on Unix-like system: ", normalizedCmd
    when defined(windows):
        result = execCmd("cmd /c " & normalizedCmd)
    else:
        result = execCmd("/bin/sh -c '" & normalizedCmd & "'")

proc execCmdEx*(command: string): tuple[output: string, exitCode: int] =
    let normalizedCmd = normalizeCmd(command)
    when defined(windows):
        osproc.execCmdEx("cmd /c " & normalizedCmd)
    else:
        osproc.execCmdEx("/bin/sh -c '" & normalizedCmd & "'")
