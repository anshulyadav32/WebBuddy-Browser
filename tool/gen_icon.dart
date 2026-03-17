wnload// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:convert';

// Minimal PNG encoder (RGBA, no dependencies)
Uint8List encodePng(int width, int height, Uint8List rgba) {
  Uint8List adler32(Uint8List data) {
    int a = 1, b = 0;
    for (final byte in data) {
      a = (a + byte) % 65521;
      b = (b + a) % 65521;
    }
    final r = ByteData(4);
    r.setUint32(0, (b << 16) | a, Endian.big);
    return r.buffer.asUint8List();
  }

  Uint8List crc32(Uint8List data) {
    var crc = 0xFFFFFFFF;
    for (final b in data) {
      crc ^= b;
      for (var i = 0; i < 8; i++) {
        crc = (crc & 1) != 0 ? (crc >> 1) ^ 0xEDB88320 : crc >> 1;
      }
    }
    final r = ByteData(4);
    r.setUint32(0, (~crc) & 0xFFFFFFFF, Endian.big);
    return r.buffer.asUint8List();
  }

  Uint8List chunk(List<int> type, Uint8List data) {
    final len = ByteData(4)..setUint32(0, data.length, Endian.big);
    final body = Uint8List.fromList([...type, ...data]);
    return Uint8List.fromList([
      ...len.buffer.asUint8List(),
      ...body,
      ...crc32(body),
    ]);
  }

  // Build raw scanlines
  final raw = BytesBuilder();
  for (var y = 0; y < height; y++) {
    raw.addByte(0); // filter none
    raw.add(rgba.sublist(y * width * 4, (y + 1) * width * 4));
  }

  // zlib compress (deflate)
  final compressed = zlib.encode(raw.toBytes());
  final zlibData = Uint8List.fromList(compressed);

  final ihdr = ByteData(13);
  ihdr.setUint32(0, width, Endian.big);
  ihdr.setUint32(4, height, Endian.big);
  ihdr.setUint8(8, 8); // bit depth
  ihdr.setUint8(9, 6); // colour type RGBA
  // compression/filter/interlace = 0

  final out = BytesBuilder();
  out.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]); // PNG sig
  out.add(chunk([0x49, 0x48, 0x44, 0x52], ihdr.buffer.asUint8List())); // IHDR
  out.add(chunk([0x49, 0x44, 0x41, 0x54], zlibData)); // IDAT
  out.add(chunk([0x49, 0x45, 0x4E, 0x44], Uint8List(0))); // IEND

  return out.toBytes();
}

Uint8List renderIcon(int size) {
  final pixels = Uint8List(size * size * 4);
  final cx = size / 2.0;
  final cy = size / 2.0;
  final bgR = 30.0 / 255, bgG = 100.0 / 255, bgB = 210.0 / 255;
  final radius = size * 0.42;
  final lineW = size * 0.045;

  void setPixel(int x, int y, double r, double g, double b, double a) {
    if (x < 0 || y < 0 || x >= size || y >= size) return;
    final i = (y * size + x) * 4;
    pixels[i] = (r * 255).clamp(0, 255).round();
    pixels[i + 1] = (g * 255).clamp(0, 255).round();
    pixels[i + 2] = (b * 255).clamp(0, 255).round();
    pixels[i + 3] = (a * 255).clamp(0, 255).round();
  }

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final dx = x - cx;
      final dy = y - cy;
      final dist = sqrt(dx * dx + dy * dy);

      // Rounded icon boundary
      if (dist > size * 0.48) {
        setPixel(x, y, 0, 0, 0, 0);
        continue;
      }

      double pr = bgR, pg = bgG, pb = bgB;

      bool onLine = false;

      // Outer globe circle
      if ((dist - radius).abs() < lineW) onLine = true;

      // Equator
      if (dy.abs() < lineW && dist < radius) onLine = true;

      // Vertical meridian
      if (dx.abs() < lineW && dist < radius) onLine = true;

      // Upper/lower latitude bands
      final lat = radius * 0.55;
      if ((dy.abs() - lat).abs() < lineW * 0.7 && dist < radius) onLine = true;

      // Two longitude ovals (skewed ellipses)
      for (final skew in [-0.55, 0.55]) {
        final ex = dx * skew;
        final ey = dy;
        final ed = sqrt(ex * ex + ey * ey);
        if ((ed - radius * 0.6).abs() < lineW * 0.7 && dist < radius) {
          onLine = true;
        }
      }

      if (onLine) {
        pr = 1.0;
        pg = 1.0;
        pb = 1.0;
      }

      setPixel(x, y, pr, pg, pb, 1.0);
    }
  }
  return pixels;
}

void main() {
  final configs = {
    'android/app/src/main/res/mipmap-mdpi/ic_launcher.png': 48,
    'android/app/src/main/res/mipmap-hdpi/ic_launcher.png': 72,
    'android/app/src/main/res/mipmap-xhdpi/ic_launcher.png': 96,
    'android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png': 144,
    'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png': 192,
  };

  for (final entry in configs.entries) {
    final size = entry.value;
    final rgba = renderIcon(size);
    final png = encodePng(size, size, rgba);
    File(entry.key).writeAsBytesSync(png);
    print('✓ ${entry.key} (${size}x$size)');
  }
  print('Done!');
}
