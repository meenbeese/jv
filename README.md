# Java Tool

Java Tool is a command-line utility designed to manage Java versions and facilitate the compilation and execution of Java programs. It provides a simple interface for users to work with different Java versions and streamline their development workflow.

## Features

- **Cross-Platform Support**: Works on Windows, macOS, and Linux
- **Flexible Version Management**: Supports multiple version managers:
  - jEnv (macOS/Linux)
  - Jabba (all platforms)
  - Manual management with environment variables (Windows fallback)
- **Compile Java Programs**: Compile Java source files using the `javac` command
- **Execute Java Programs**: Run compiled Java programs with the `java` command
- **File Operations**: Utility functions for file management

## Prerequisites

- **Windows**: Java installation, optionally Jabba
- **macOS**: Java installation, jEnv or Jabba recommended
- **Linux**: Java installation, jEnv or Jabba recommended

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/meenbeese/jv.git
   ```
2. Navigate to the project directory:
   ```
   cd jv
   ```
3. Install Nim from [Nim's official website](https://nim-lang.org/)
4. Build the project:
   ```
   nim compile --run src/main.nim
   ```

## Usage

```
jv <command> [options]
```

### Commands

- `compile`: Compiles a Java file
- `execute`: Executes a compiled Java program
- `manage`: Manages Java versions

## Examples

Compile a Java file:
```
jv compile MyProgram.java
```

Execute a compiled Java program:
```
jv execute MyProgram
```

Manage Java versions:
```
jv manage list
jv manage install 11
jv manage set 11
```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

MIT License - see LICENSE file for details.
