// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:path/path.dart' as path;
import 'package:test/test.dart';

void main() {
  test('no resize by default', () async {
    final Uint8List bytes = await readFile('4x4.png');
    final Codec codec = await instantiateImageCodec(bytes);
    final FrameInfo frame = await codec.getNextFrame();
    final int codecHeight = frame.image.height;
    final int codecWidth = frame.image.width;
    expect(codecHeight, 2);
    expect(codecWidth, 2);
  });

  test('resize width with constrained height', () async {
    final Uint8List bytes = await readFile('4x4.png');
    final Codec codec = await instantiateImageCodec(bytes, targetHeight: 1);
    final FrameInfo frame = await codec.getNextFrame();
    final int codecHeight = frame.image.height;
    final int codecWidth = frame.image.width;
    expect(codecHeight, 1);
    expect(codecWidth, 1);
  });

  test('resize height with constrained width', () async {
    final Uint8List bytes = await readFile('4x4.png');
    final Codec codec = await instantiateImageCodec(bytes, targetWidth: 1);
    final FrameInfo frame = await codec.getNextFrame();
    final int codecHeight = frame.image.height;
    final int codecWidth = frame.image.width;
    expect(codecHeight, 1);
    expect(codecWidth, 1);
  });

  test('upscale image by 5x', () async {
    final Uint8List bytes = await readFile('4x4.png');
    final Codec codec = await instantiateImageCodec(bytes, targetWidth: 10);
    final FrameInfo frame = await codec.getNextFrame();
    final int codecHeight = frame.image.height;
    final int codecWidth = frame.image.width;
    expect(codecHeight, 10);
    expect(codecWidth, 10);
  });

  test('upscale image varying width and height', () async {
    final Uint8List bytes = await readFile('4x4.png');
    final Codec codec =
        await instantiateImageCodec(bytes, targetWidth: 10, targetHeight: 1);
    final FrameInfo frame = await codec.getNextFrame();
    final int codecHeight = frame.image.height;
    final int codecWidth = frame.image.width;
    expect(codecHeight, 1);
    expect(codecWidth, 10);
  });

  test('pixels: no resize by default', () async {
    final BlackSquare blackSquare = BlackSquare.create();
    final Image resized = await blackSquare.resize();
    expect(resized.height, blackSquare.height);
    expect(resized.width, blackSquare.width);
  });

  test('pixels: resize width with constrained height', () async {
    final BlackSquare blackSquare = BlackSquare.create();
    final Image resized = await blackSquare.resize(targetHeight: 1);
    expect(resized.height, 1);
    expect(resized.width, 1);
  });

  test('pixels: resize height with constrained width', () async {
    final BlackSquare blackSquare = BlackSquare.create();
    final Image resized = await blackSquare.resize(targetWidth: 1);
    expect(resized.height, 1);
    expect(resized.width, 1);
  });

  test('pixels: upscale image by 5x', () async {
    final BlackSquare blackSquare = BlackSquare.create();
    final Image resized = await blackSquare.resize(targetWidth: 10);
    expect(resized.height, 10);
    expect(resized.width, 10);
  });

  test('pixels: upscale image varying width and height', () async {
    final BlackSquare blackSquare = BlackSquare.create();
    final Image resized =
        await blackSquare.resize(targetHeight: 1, targetWidth: 10);
    expect(resized.height, 1);
    expect(resized.width, 10);
  });
}

class BlackSquare {
  BlackSquare._(this.width, this.height, this.pixels);

  factory BlackSquare.create({int width = 2, int height = 2}) {
    final Uint8List pixels =
        Uint8List.fromList(List<int>.filled(width * height * 4, 0));
    return BlackSquare._(width, height, pixels);
  }

  Future<Image> resize({int targetWidth, int targetHeight}) async {
    final Completer<Image> imageCompleter = Completer<Image>();
    decodeImageFromPixels(pixels, width, height, PixelFormat.rgba8888,
        (Image image) => imageCompleter.complete(image),
        targetHeight: targetHeight, targetWidth: targetWidth);
    return await imageCompleter.future;
  }

  final int width;
  final int height;
  final Uint8List pixels;
}

Future<Uint8List> readFile(String fileName) async {
  final File file =
      File(path.join('flutter', 'testing', 'resources', fileName));
  return await file.readAsBytes();
}
