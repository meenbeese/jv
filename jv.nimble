# Package
version       = "0.1.0"
author        = "Kuzey Bilgin"
description   = "Java version manager and build tool"
license       = "MIT"
srcDir        = "src"
bin           = @["jv"]

# Dependencies
requires "nim >= 1.6.0"

task test, "Run all tests":
  exec "nim c -r src/main.nim test"