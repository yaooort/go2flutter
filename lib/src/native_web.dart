import 'dart:js' as js;
import 'tools.dart';
import 'wasm_loader.dart';
import 'native_interface.dart';

String name = 'libgocoresdk';

/// 导出dart动态库桥梁. web
class NativeLibrary extends NativeLibraryInterface {
  js.JsObject? _engineArchiveLib;

  NativeLibrary._internal() {}

  factory NativeLibrary() => _instance;
  static final NativeLibrary _instance = NativeLibrary._internal();

  js.JsObject? _engine() {
    if (_engineArchiveLib == null) {
      if (js.context.hasProperty(name)) {
        _engineArchiveLib = js.context[name] as js.JsObject?;
      } else {
        logInfo('JavaScript context does not contain $name');
      }
    }
    return _engineArchiveLib;
  }

  @override
  String getTime() {
    return _engine()?.callMethod("GetTime") ?? "";
  }

  @override
  Future<bool> init(OnMessage onMessage, {String token = ""}) async {
    // 这里可以进行插件的注册和方法通道的初始化
    final wasmLoader = WasmLoader();
    try {
      await wasmLoader.loadWasmScripts(); // 动态加载脚本
      await waitForVariable(
        condition: () => _engine(),
        timeout: Duration(seconds: 15), // 15秒内初始化成功
      );
      _engine()?.callMethod("InitStart", [
        "",
        token,
        "3",
        (msg) {
          // 处理来自 Go 的回调消息
          final msgDart = Message(msg['errMsg'], msg['message'], msg['code']);
          onMessage(msgDart);
          logInfo(
              "golib-web返回数据:code=${msgDart.code},message=${msgDart.message},errMsg=${msgDart.errMsg}");
        }
      ]);
      return true;
    } catch (e) {
      logInfo('WASM 初始化失败: $e');
      return false;
    }
  }

  @override
  stopWork() {
    _engine()?.callMethod("StopWork") ?? "";
  }
}
