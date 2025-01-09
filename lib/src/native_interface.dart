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
