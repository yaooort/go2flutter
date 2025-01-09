import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'tools.dart';

class WasmLoader {
  // 这个方法将动态加载所有必需的 JavaScript 文件
  Future<void> loadWasmScripts() async {
    try {
      // 加载 wasm_exec.js
      await _loadScript('assets/packages/go/web/wasm_exec.js');
      // 加载 plugin.js
      await _loadScript('assets/packages/go/web/plugin.js');

      // 加载完成后调用 JavaScript 中的 loadWasm 函数
      js.context.callMethod('loadWasm');
    } catch (e) {
      logInfo('加载 WASM 脚本时出错: $e');
    }
  }

  // 助手方法：加载 JavaScript 文件
  Future<void> _loadScript(String scriptSrc) {
    final script = html.ScriptElement()
      ..src = scriptSrc
      ..type = 'application/javascript';

    // 返回一个 Future，表示脚本加载的完成
    final completer = FutureCompleter<void>();

    script.onLoad.listen((event) {
      logInfo('$scriptSrc 加载成功');
      completer.complete();
    });

    script.onError.listen((event) {
      logInfo('加载 $scriptSrc 出错');
      completer.completeError('加载 $scriptSrc 出错');
    });

    html.document.head?.append(script);
    return completer.future;
  }
}

class FutureCompleter<T> {
  final _completer = Completer<T>();

  Future<T> get future => _completer.future;

  void complete([T? value]) {
    _completer.complete(value);
  }

  void completeError([Object? error]) {
    _completer.completeError(error ?? '未知错误');
  }
}
