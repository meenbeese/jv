# Package
version       = "0.1.0"
author        = "Kuzey Bilgin"
description   = "A Java version manager and build tool written in Nim"
license       = "MIT"
srcDir        = "src"
bin           = @["jv"]
installExt    = @["nim"]

# Dependencies
requires "nim >= 2.0.0"

task test, "Run all tests":
  exec "nim c -r src/main.nim test"

task install, "Install jv globally":
  exec "nimble build -d:release"
  when defined(windows):
    exec "powershell -Command \"[Environment]::SetEnvironmentVariable('Path', $env:Path + ';' + (Get-Location).Path + '\\bin', 'User')\""
  else:
    exec "mkdir -p ~/.local/bin"
    exec "cp bin/jv ~/.local/bin/"
    exec "chmod +x ~/.local/bin/jv"