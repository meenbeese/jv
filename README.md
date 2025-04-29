# jv

A Java version manager and build tool written in Nim. Supports Windows, macOS, and Linux.

## Features

- Version Management
  - Install and manage multiple Java versions
  - Switch between Java versions easily
  - Supports Jabba (all platforms) and jEnv (macOS/Linux)
- Build Tools
  - Compile Java source files
  - Execute Java programs
  - Run tests
- Cross-Platform
  - Windows support with PowerShell integration
  - macOS and Linux support
  - Consistent experience across platforms

## Installation

### Prerequisites

- Nim compiler (<https://nim-lang.org/>)
- Git
- PowerShell (Windows) or Bash/Zsh (macOS/Linux)

### Windows

```sh
# Clone the repository
git clone https://github.com/meenbeese/jv.git
cd jv

# Run the install script
.\install.ps1
```

### macOS/Linux

```sh
# Clone the repository
git clone https://github.com/meenbeese/jv.git
cd jv

# Run the install script
chmod +x install.sh
./install.sh
```

After installation, restart your terminal and run `jv help` to verify the installation.

## Usage

### Basic Commands

```sh
# Show help
jv help

# Show version
jv version

# Initialize a new Java project with Gradle
jv init

# Compile a Java file
jv compile App.java

# Execute a compiled program
jv execute App

# List installed Java versions
jv manage list

# Install a new Java version
jv manage install openjdk@1.17.0

# Set active Java version
jv manage set openjdk@1.17.0

# Install version manager (if needed)
jv manage setup
```

### Project Initialization

The `init` command sets up a new Java project with:

- Gradle build system using Kotlin DSL
- Standard Maven project structure
- JUnit 5 testing support
- Package name based on reversed domain (e.g., com.example becomes example.com)
- Sample App class and test

```sh
jv init
# Enter your domain when prompted
```

### Version Management

The tool supports two version managers:

- Jabba: Available on all platforms, recommended for Windows
- jEnv: Available on macOS and Linux

The appropriate version manager will be installed automatically when needed.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
