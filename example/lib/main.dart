import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go/native_library.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _isOk = false;

  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Plugin example app'),
            ),
            body: Center(
              child: Text('Running on: $_platformVersion\n'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if (!_isOk) {
                  // 在正确的上下文中调用 ScaffoldMessenger
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('获取的时间: Go未初始化成功'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  return;
                }
                // 在正确的上下文中调用 ScaffoldMessenger
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('获取的时间: ${NativeLibrary().getTime()}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Icon(Icons.call_outlined),
            ),
          );
        },
      ),
    );
  }
}
