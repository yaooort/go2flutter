import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

void logInfo(String? msg) {
  try {
    if (kDebugMode) {
      print("go-ffi:$msg");
    }
    // ignore: empty_catches
  } catch (e) {}
}

/// 循环等待变量变为非空
Future<void> waitForVariable({
  required FutureOr<dynamic> Function() condition,
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final completer = Completer<void>();
  final stopwatch = Stopwatch()..start();

  // 定时检查变量是否符合条件
  Timer.periodic(interval, (timer) {
    if (condition() != null) {
      completer.complete();
      timer.cancel();
    } else if (stopwatch.elapsed >= timeout) {
      completer.completeError(TimeoutException('等待超时'));
      timer.cancel();
    }
  });

  return completer.future;
}

String currentPlatform() {
  // 平台
  if (kIsWeb) {
    return "3";
  } else if (Platform.isAndroid) {
    return "1";
  } else if (Platform.isIOS) {
    return "2";
  } else if (Platform.isMacOS) {
    return "4";
  } else if (Platform.isLinux) {
    return "5";
  } else if (Platform.isWindows) {
    return "6";
  } else if (Platform.isFuchsia) {
    return "7";
  } else {
    return "8";
  }
}
