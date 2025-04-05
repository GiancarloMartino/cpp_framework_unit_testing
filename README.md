# C++ Unit Testing Template

A plug-and-play framework for C++ unit testing utilizing GoogleTest, CMake, and PowerShell to start writing tests immediately regardless of the specific project.

## 📋 Overview

This template is designed to eliminate the repetitive configuration required to implement unit testing in C++ projects. The included calculator is merely a demonstrative example - the real value lies in the project structure and automation scripts that allow you to focus on writing tests rather than configuring the environment.

## 🎯 Project Objective

Provide an **immediate and ready-to-use** testing framework for any C++ project with:
- Zero configuration required to get started
- Support for multiple independent projects in the same directory
- Complete automation of the test-driven development cycle

## 🔧 Template Structure

```
template/
├── CMakeLists.txt       # Build system configured for automated testing
├── build.ps1            # Complete automation script
├── src/                 # Your code goes here
│   ├── example.h        # (replaceable example with your code)
│   └── example.cpp      # (replaceable example with your code)
└── test/                # Your unit tests go here
    └── example_test.cpp # (replaceable example with your tests)
```

## 🚀 How to Use the Template

### 1. Clone or copy the template structure

```bash
git clone https://github.com/username/cpp-unit-testing-template.git my-project
```

### 2. Replace the example with your code

- Replace files in `src/` with your source files
- Add your tests in the `test/` folder

### 3. Run the build script

```powershell
.\build.ps1
```

That's it! Your tests will be compiled and executed automatically.

## 💻 PowerShell Script Capabilities

The `build.ps1` script automates the entire test-driven development cycle:

### Usage Modes

- **Rapid Development**:
  ```powershell
  .\build.ps1 -Watch
  ```
  Automatically detects file changes and recompiles/runs tests, ideal for TDD

- **IDE Setup**:
  ```powershell
  .\build.ps1 -CompileCommands
  ```
  Generates necessary files for optimal editor experience with IntelliSense

- **Clean Build**:
  ```powershell
  .\build.ps1 -Clean -RebuildAll
  ```
  Completely rebuilds the project and tests

- **Complete Configuration**:
  ```powershell
  .\build.ps1 -Clean -RebuildAll -CompileCommands -Watch
  ```
  Complete setup with active watch mode

### Key Features

- **Environment Detection**: Automatically verifies and installs necessary dependencies
- **Continuous Testing**: Recompiles and runs tests on every file change
- **Multi-Project Support**: Each copy of the template is self-contained and independent
- **Zero Configuration**: No changes to CMakeLists.txt required for simple projects

## 📝 The CMakeLists.txt Explained

The CMakeLists.txt file is designed to be universal and require no modifications for most projects:

1. **Automatic GoogleTest Download**:
   - Uses FetchContent to download and configure GoogleTest
   - No external dependencies to manually install

2. **Automatic Test Discovery**:
   - Automatically detects all test files in the `test/` directory
   - Each test file becomes a separate executable

3. **Include Path Configuration**:
   - Automatically configures inclusion paths for tests and libraries
   - Ensures tests can always access header files

4. **Project Independence**:
   - Works with any source code structure
   - Requires no specific naming conventions

## 🔄 Test-Driven Workflow

With this template, you can easily follow a TDD approach:

1. **Write a test** in `test/my_test.cpp`
2. **Start the script** with `.\build.ps1 -Watch`
3. **Watch the test fail**
4. **Implement code** in `src/`
5. **See the test pass** automatically when the script detects changes
6. **Repeat** for each new feature

## 💡 Why Use This Template?

- **Time Saving**: Eliminates hours of repetitive configuration
- **Consistency**: Maintains the same testing structure across different projects
- **Code Focus**: Concentrate on writing tests and code, not configuration
- **Scalability**: Works from simple libraries to complex projects
- **Isolation**: Each project based on the template is completely independent

## 🛠️ Requirements

- CMake (3.14 or higher)
- A C++ compiler (configured for MSYS2/GCC on Windows)
- PowerShell 5.1 or higher

## 📄 License

[MIT](LICENSE)