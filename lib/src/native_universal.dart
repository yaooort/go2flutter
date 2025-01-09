import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'tools.dart';

// ignore: implementation_imports
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'bindings.dart';
import 'native_interface.dart';

final class CallbackMessage extends Struct {
  external Pointer<Utf8> errMsg;
  external Pointer<Utf8> message;
  @Int64()
  external int code;
}

String name = 'libgocoresdk';

/// 导出dart动态库桥梁. android ios macos windows linux
class NativeLibrary extends NativeLibraryInterface {
  late final EngineLib _engineArchiveLib;
  late final DynamicLibrary look;

  // ignore: prefer_typing_uninitialized_variables
  late final interactiveCppSub;
  ReceivePort? interactiveCppRequests;

  // https://flutter.cn/community/tutorials/singleton-pattern-in-flutter-n-dart 单例模式
  NativeLibrary._internal() {
    look = load();
    _engineArchiveLib = EngineLib(look);
  }

  factory NativeLibrary() => _instance;
  static final NativeLibrary _instance = NativeLibrary._internal();

  DynamicLibrary load() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open("$name.so");
    }
    if (Platform.isMacOS) {
      return DynamicLibrary.open("$name.dylib");
    }
    if (Platform.isIOS) {
      return DynamicLibrary.process();
    }
    if (Platform.isWindows) {
      return DynamicLibrary.open("$name.dll");
    }
    if (Platform.isLinux) {
      return DynamicLibrary.open("$name.so");
    }
    return DynamicLibrary.open("$name.so");
  }

  // 改为谁接收谁释放的原则
  coverDartStrAutoFree(Pointer pc) {
    String dartStr = pc.cast<Utf8>().toDartString();
    // 这里兼容windows释放调用CGO
    _engineArchiveLib.FreePointer(Pointer<GoInt64>.fromAddress(
      pc.address,
    ));
    return dartStr;
  }

  @override
  String getTime() {
    // 如果将dart 传入的数据转C 就需要释放内存
    // final fooNative = "foo".toNativeUtf8();
    // malloc.free(fooNative);
    return coverDartStrAutoFree(_engineArchiveLib.GetTime());
  }

  @override
  Future<bool> init(OnMessage onMessage, {String token = ""}) async {
    if (interactiveCppRequests != null) {
      logInfo("golib 已经初始化过了");
      return false;
    }
    try {
      int result =
          _engineArchiveLib.InitializeDartApi(NativeApi.initializeApiDLData);
      if (result != 1) {
        logInfo("golib初始化失败$result");
        return false;
      }
      if (interactiveCppRequests == null) {
        interactiveCppRequests = ReceivePort();
        interactiveCppSub = interactiveCppRequests?.listen((address) {
          final addressInt = address as int;
          final work = Pointer<CallbackMessage>.fromAddress(addressInt);
          final code = work.ref.code;
          String errMsg = work.ref.errMsg.cast<Utf8>().toDartString();
          String message = work.ref.message.cast<Utf8>().toDartString();
          logInfo("golib返回数据:code=$code,message=$message,errMsg=$errMsg");
          onMessage(Message(errMsg, message, code));
          _engineArchiveLib.FreeCallbackMessageMemory(
              Pointer<GoInt64>.fromAddress(
            addressInt,
          ));
          if (work.ref.code == 999) {
            // 程序结束
            Future.delayed(const Duration(seconds: 3), () {
              logInfo("golib程序结束释放监听");
              interactiveCppSub.cancel();
              interactiveCppRequests?.close();
            });
          }
        }, onDone: () {
          logInfo("golib结束监听");
        });
      }
      Directory documentsDir = await getApplicationSupportDirectory();
      // Directory documentsDir = await getApplicationDocumentsDirectory();
      String documentsPath = p.join(documentsDir.path, 'db');
      logInfo("golibDB存储目录:$documentsPath");
      final nativePort = interactiveCppRequests?.sendPort.nativePort;
      final platform = currentPlatform();
      _engineArchiveLib.InitStart(
          documentsPath.toNativeUtf8().cast<Char>(),
          token.toNativeUtf8().cast<Char>(),
          platform.toNativeUtf8().cast<Char>(),
          nativePort!);
    } catch (e) {
      // 处理代码执行错误...
      logInfo("golib执行静态库错误${e.toString()}");
      return false;
    }
    return true;
  }

  // 停止运行
  @override
  stopWork() {
    _engineArchiveLib.StopWork();
    // 程序结束
    logInfo("golib程序结束释放监听");
    interactiveCppSub.cancel();
    interactiveCppRequests?.close();
    interactiveCppRequests = null;
  }
}
