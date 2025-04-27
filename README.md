# Java Tool

Java Tool is a command-line utility designed to manage Java versions and facilitate the compilation and execution of Java programs. It provides a simple interface for users to work with different Java versions and streamline their development workflow.

## Features

- **Manage Java Versions**: Easily list, install, and set default Java versions.
- **Compile Java Programs**: Compile Java source files using the `javac` command.
- **Execute Java Programs**: Run compiled Java programs with the `java` command and capture output.
- **File Operations**: Utility functions to check file existence, write to files, and remove files.

## Installation

1. Clone the repository:
   ```
   git clone https://github.com/meenbeese/jv.git
   ```
2. Navigate to the project directory:
   ```
   cd jv
   ```
3. Ensure you have Nim installed on your system. You can download it from [Nim's official website](https://nim-lang.org/).
4. Build the project:
   ```
   nim compile --run src/main.nim
   ```

## Usage

To use jv, run the following command in your terminal:

```
jv <command> [options]
```

### Commands

- `compile`: Compiles a Java file.
- `execute`: Executes a compiled Java program.
- `manage`: Manages installed Java versions (list, install, set).

## Examples

- Compile a Java file:
  ```
  jv compile MyProgram.java
  ```

- Execute a compiled Java program:
  ```
  jv execute MyProgram
  ```

- Manage Java versions:
  ```
  jv manage list
  ```
  ```
  jv manage install 11
  ```
  ```
  jv manage set 11
  ```

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any enhancements or bug fixes.

## License

This project is licensed under the MIT License. See the LICENSE file for more details.
