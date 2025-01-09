// 导出
library native;

export 'src/native_interface.dart';
export 'src/native_universal.dart'
    if (dart.library.io) 'src/native_universal.dart'
    if (dart.library.html) 'src/native_web.dart' show NativeLibrary;
