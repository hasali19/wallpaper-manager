import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class Wallpaper {
  static void set(File file, {String? monitorId}) {
    final wallpaper = DesktopWallpaper.createInstance();
    using((alloc) {
      final hr = wallpaper.setWallpaper(
        monitorId?.toNativeUtf16(allocator: alloc) ?? nullptr,
        file.path.toNativeUtf16(allocator: alloc),
      );
      if (FAILED(hr)) {
        throw WindowsException(hr);
      }
    });
  }

  static String? get({String? monitorId}) {
    final wallpaper = DesktopWallpaper.createInstance();
    return using((alloc) {
      final path = alloc<Pointer<Utf16>>();
      wallpaper.getWallpaper(
          monitorId?.toNativeUtf16(allocator: alloc) ?? nullptr, path);
      if (path == nullptr) return null;
      return path.value.toDartString();
    });
  }
}
