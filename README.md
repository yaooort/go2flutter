# How to Use Dart FFI and Golang in Flutter (Without Platform Code Conversion)

This project provides a complete framework demonstrating how to use Flutter's Dart FFI (Foreign Function Interface) to call Golang code directly. It supports all Flutter platforms, including Android, iOS, Windows, macOS, Linux, and Web. With this framework, developers can bypass the need for platform-specific code (e.g., Java/Kotlin, Swift/Objective-C) and achieve seamless interaction between Dart and Golang.

------

## Features

- **Cross-Platform Support**: Compatible with Android, iOS, Windows, macOS, Linux, and Web.
- **Pure FFI Calls**: No platform code conversion required; Dart calls Golang methods directly.
- **Demo Example**: Demonstrates a timer in Golang sending the current time to Flutter periodically.
- **Easy Integration**: Minimal configuration needed to use the framework in your project.
- **Web Compatibility**: Supports Web, provided Golang code has no IO operations.

------

## Framework Workflow

1. **Dart FFI**: Enables Flutter projects to directly call native Golang libraries (e.g., `.so`, `.dylib`, `.dll`).
2. **Web Platform Support**: Uses Golang's WebAssembly output to run Golang code on the Web.
3. **Unified Interface**: The framework provides a unified interface, allowing developers to declare and implement methods easily without worrying about platform-specific differences.

------

## Usage Guide

### 1. Clone and Initialize the Project

Clone the repository to your local development environment:

```shell
git clone https://github.com/your_repo/go2flutter.git
cd go2flutter
```

------

### 2. Compile Golang Code

The Golang codebase is located in the `core` directory. Methods to be exposed to Flutter should be defined in the following files:

- **Native Platforms**: `core/export/cgo/main.go`
- **Web Platform**: `core/export/web/main.go`

The framework provides a sample implementation (timer callback to return the current time). You can extend it as needed. After defining your methods, compile the Golang dynamic libraries for all platforms:

```shell
make all
```

The compiled libraries will be output to the `core/build` directory:

- Native dynamic libraries (e.g., `.so`, `.dll`, `.dylib`) in `core/build/native`.
- WebAssembly files (`.wasm`) in `core/build/web`.

------

### 3. Declare Golang Methods in Flutter

1. Open the `lib/src/native_interface.dart` file in your Flutter project.
2. Declare and implement Golang methods as follows:
   - Define function interfaces corresponding to Golang methods.
   - Implement platform-specific logic for Web.
   - Implement general FFI calls for other platforms.

Here is an example interface declaration:

```dart
class Message {
  late final String errMsg;
  late final String message;
  late final int code;

  Message(this.errMsg, this.message, this.code);
}

typedef OnMessage = void Function(Message message);

// Define an abstract class as the standard bridge
abstract class NativeLibraryInterface {
  // Test method to get the current time from Golang
  String getTime();

  // Initialize
  Future<bool> init(OnMessage onMessage, {String token});

  // Stop work
  void stopWork();
}
```

Refer to the provided implementations in `native_native_interface.dart` and `web_native_interface.dart` for details.

------

### 4. Add the Plugin to Your Project

Add the following dependency to your Flutter project's `pubspec.yaml` file:

```yaml
dependencies:
  go:
    path: ./go2flutter
```

Ensure the path points to the actual location of the framework.

------

### 5. Example Usage

The framework includes an example feature: a timer in Golang that sends the current time to Flutter every second. Here’s how to use it:

```dart
// Initialize platform version
NativeLibrary().init((message) {
  setState(() {
    _platformVersion = message.message;
  });
}).then((bool isOk) {
  setState(() {
    _isOk = isOk;
  });
  if (kDebugMode) {
    print("Initialized Go: $isOk");
  }
});

// Display the time in a SnackBar
SnackBar(
  content: Text('Current time: ${NativeLibrary().getTime()}'),
  duration: const Duration(seconds: 2),
),
```

Run the Flutter app, and you will see the current time returned from Golang in the console.

------

## Project Directory Structure

```shell
go2flutter/
│
├── core/                  # Golang Codebase
│   ├── export/            # Golang Method Definitions
│   │   ├── cgo/           # Native Platform Methods
│   │   └── web/           # Web Platform Methods
│   └── ...                # Other Golang Source Files
│
├── lib/                   # Flutter Codebase
│   ├── src/               # FFI and Interface Implementation
│   │   ├── native_interface.dart  # Interface Declarations
│   │   ├── native_universal.dart  # Native Platform Implementation
│   │   └── native_web.dart        # Web Platform Implementation
│   └── ...
```

------

## Notes

1. Web Platform Limitations:
   - Golang code running on the Web does not support IO operations.
   - Must compile to WebAssembly (`.wasm`) for Web use.
2. Toolchain Requirements:
   - Requires `make` tool.
   - Golang version: 1.17 or higher.
3. Dynamic Library Compatibility:
   - Ensure generated libraries match the target runtime environment.
   - Compiled libraries contain platform-specific differences; load appropriately.

------

## Developer Extensions

1. Adding New Golang Methods:
   - Define methods in `core/export/cgo/main.go` or `core/export/web/main.go`.
   - Ensure the method signatures conform to framework specifications.
2. Extending Dart Interfaces:
   - Add method declarations to `lib/src/native_interface.dart`.
   - Implement them in `native_native_interface.dart` and `web_native_interface.dart`.

------

## Support and Contributions

We welcome contributions and issue reports! If you encounter any problems, please reach out via Issues.

------

## Conclusion

This project simplifies the process of calling Golang methods from Flutter projects by eliminating the need for platform-specific code conversions. We hope you find this framework useful for your development needs! 🎉

