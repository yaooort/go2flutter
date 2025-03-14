# Flutter 如何使用 Dart FFI 和 Golang 进行调用

本项目提供了一个完整的基础框架，演示如何使用 Flutter 的 Dart FFI（Foreign Function Interface）直接调用 Golang 代码，并支持所有 Flutter 平台（Android、iOS、Windows、macOS、Linux 和 Web）。通过此框架，开发者可以省去传统的通过平台代码（如 Java/Kotlin、Swift/Objective-C）桥接的繁琐步骤，直接实现 Dart 与 Golang 的交互。



------

<div align="center">
<p align="center">
  <a href="https://github.com/yaooort/go2flutter/blob/master/README.md">English</a> · 
  <a href="https://github.com/yaooort/go2flutter/blob/master/README_ZH.md">中文</a>
</p>
</div>

## 功能简介

- **跨平台支持**：支持 Android、iOS、Windows、macOS、Linux 和 Web 平台。
- **纯 FFI 调用**：无需通过平台中间代码转换，Dart 可直接调用 Golang 方法。
- **示例 Demo**：实现了一个从 Golang 定时回调当前时间到 Flutter 的功能。
- **简单集成**：开发者仅需 minimal 配置，即可在项目中直接使用。
- **Web 兼容**：支持 Web 平台，但要求 Golang 代码中不存在 IO 操作。

------

## 框架工作原理

1. **Dart FFI**：通过 Dart FFI，Flutter 项目直接调用本地 Golang 动态库（如 `.so`、`.dylib`、`.dll`）。
2. **Web 平台支持**：通过 Golang 的 WebAssembly 输出，使 Dart 能够在 Web 平台运行 Golang 代码。
3. **统一接口**：框架提供统一的接口规范，开发者只需遵循规范声明和实现接口，无需处理底层平台差异。

------

## 使用指南

### 1. 下载和初始化项目

克隆本项目到您的本地开发环境：

```shell
git clone https://github.com/yaooort/go2flutter.git
cd go2flutter
```

------

### 2. 编译 Golang 代码

Golang 代码库位于 `core` 目录下，您需要将希望暴露给 Flutter 调用的方法分别定义在以下文件中：

- **原生平台**：`core/export/cgo/main.go`
- **Web 平台**：`core/export/web/main.go`

框架已提供一个示例代码（定时器回调当前时间），可参考扩展。完成方法定义后，运行以下命令编译所有平台的 Golang 动态库：

```shell
# go mod version set current
cd core
make cp-dl
make all
cd ..
flutter pub run ffigen
```

编译完成后，生成的库文件位于 `core/build` 目录：

- 原生动态库（如 `.so`、`.dll`、`.dylib`）位于 `core/build/native`。
- WebAssembly 文件（`.wasm`）位于 `core/build/web`。

------

### 3. 在 Flutter 中声明 Golang 方法

1. 打开 Flutter 项目的 `lib/src/native_interface.dart` 文件。
2. 按以下方式声明并实现 Golang 方法：
   - 声明与 Golang 对应的函数接口。
   - 为 Web 平台实现特定的调用逻辑。
   - 为其他平台实现通用的 FFI 调用。

以下是一个示例接口声明：

```dart
class Message {
  late final String errMsg;
  late final String message;
  late final int code;

  Message(this.errMsg, this.message, this.code);
}

typedef OnMessage = void Function(Message message);

// 定义一个抽象类作为标准桥梁
abstract class NativeLibraryInterface {
  // test get go time
  String getTime();

  // 初始化
  Future<bool> init(OnMessage onMessage, {String token});

  // 停止
  stopWork();
}
```

具体实现请参考框架中已提供的 `native_native_interface.dart` 和 `web_native_interface.dart` 文件。

------

### 4. 在项目中引入插件

在您的 Flutter 项目的 `pubspec.yaml` 文件中添加以下依赖：

```yaml
dependencies:
  go:
    path: ./go2flutter
```

确保将路径指向本框架的实际路径。

------

### 5. 使用示例

框架提供了一个example功能：Golang 定时器每秒回调当前时间到 Flutter。以下是示例用法：

```dart
  // 初始化平台版本
    NativeLibrary().init((message) {
      setState(() {
        _platformVersion = message.message;
      });
    }).then((bool isOk) {
      setState(() {
        _isOk = isOk;
      });
      if (kDebugMode) {
        print("初始化go：$isOk");
      }
    });


SnackBar(
                    content: Text('获取的时间: ${NativeLibrary().getTime()}'),
                    duration: const Duration(seconds: 2),
                  ),
```

运行 Flutter 应用后，您将在控制台中看到 Go 端定时返回的时间。

------

## 项目目录结构

```
go2flutter/
│
├── core/                  # Golang 代码库
│   ├── export/            # Golang 方法定义目录
│   │   ├── cgo/           # 原生平台方法
│   │   └── web/           # Web 平台方法
│   └── ...                # 其他 Golang 源文件
│
├── lib/                   # Flutter 代码库
│   ├── src/               # FFI 和接口实现
│   │   ├── native_interface.dart  # 接口声明
│   │   ├── native_universal.dart  # 原生平台实现
│   │   └── native_web.dart     # Web 平台实现
│   └── ...
```

------

## 注意事项

1. **Web 平台限制**：
   - Golang 代码在 Web 平台上运行时，不支持 IO 操作。
   - 需要通过 WebAssembly 编译生成 `.wasm` 文件。
2. **编译工具链要求**：
   - 需要安装 `make` 工具。
   - Golang 环境版本要求：1.17 及以上。
3. **动态库兼容性**：
   - 各平台编译的动态库文件需与运行环境匹配。
   - 生成的动态库文件包含平台差异，请确保正确加载。

------

## 开发者扩展

1. **新增 Golang 方法**：
   - 在 `core/export/cgo/main.go` 或 `core/export/web/main.go` 中定义方法。
   - 确保方法签名符合框架规范。
2. **扩展 Dart 接口**：
   - 在 `lib/src/native_interface.dart` 中添加方法声明。
   - 在 `native_native_interface.dart` 和 `web_native_interface.dart` 中实现。

------

## 支持和贡献

欢迎贡献代码或提交问题报告！如果您在使用中遇到问题，请通过 Issue 与我们联系。

------

## 结语

通过本项目，开发者可以方便地在 Flutter 项目中调用 Golang 方法，无需处理平台中间代码转换，简化了开发流程。希望您能从中获益！ 🎉
