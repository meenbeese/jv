# Install script for Windows
param (
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Check if Nim is installed
if (-not (Get-Command nim -ErrorAction SilentlyContinue)) {
    Write-Error "Nim is not installed. Please install it from https://nim-lang.org/"
    exit 1
}

# Build the project
Write-Host "Building jv..."
nim c -d:release -o:bin/jv.exe src/main.nim

# Get the installation directory
$installDir = "$env:USERPROFILE\.jv"
$binDir = "$installDir\bin"

# Create installation directory
if (-not (Test-Path $binDir)) {
    New-Item -ItemType Directory -Path $binDir -Force | Out-Null
}

# Copy binary
Copy-Item "bin/jv.exe" -Destination "$binDir" -Force

# Add to PATH if not already present
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if (-not $userPath.Contains($binDir) -or $Force) {
    [Environment]::SetEnvironmentVariable(
        "Path",
        "$userPath;$binDir",
        "User"
    )
}

Write-Host "jv has been installed successfully!"
Write-Host "Please restart your terminal to use jv."