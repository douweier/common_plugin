
import 'dart:async';
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 图片加载，缓存图片，加载状态显示

class ImageLoad extends StatelessWidget {
  final String url;
  final bool onlyShowIcon; ///是否只显示图标
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ImageLoad(this.url,{
    super.key,
    this.onlyShowIcon = true,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    double iconSize = 30;
    bool _onlyShowIcon = onlyShowIcon;
    if (width != null){ ///根据width计算iconSize尺寸
      if (width! < 100){
        iconSize = 18;
        _onlyShowIcon = true;
      }
    }
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => placeholder ?? SizedBox(
        height: height ?? 100,
        child: LoadingPage(
          type: LoadingType.loading,
          showAppScaffold: false,
          iconSize: iconSize,
          onlyShowIcon: _onlyShowIcon,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? SizedBox(
        height: height ?? 100,
        child: LoadingPage(
          type: LoadingType.error,
          showAppScaffold: false,
          iconSize: iconSize,
          onlyShowIcon: _onlyShowIcon,
        ),
      ),
    );
  }

}

/// ImageLoadProvider持久缓存图片
class ImageLoadProvider extends ImageProvider<ImageLoadProvider> {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ImageLoadProvider({
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Future<ImageLoadProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<ImageLoadProvider>(this);
  }

  @override
  ImageStreamCompleter loadImage(ImageLoadProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('URL: $url');
      },
    );
  }

  Future<ui.Codec> _loadAsync(ImageLoadProvider key, ImageDecoderCallback decode) async {
    try {
      final imageProvider = CachedNetworkImageProvider(key.url);
      final Completer<ImageInfo> completer = Completer<ImageInfo>();

      imageProvider.resolve(const ImageConfiguration()).addListener(ImageStreamListener((info, _) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
      }));

      final ImageInfo imageInfo = await completer.future;
      final ByteData? byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Failed to convert image to ByteData');
      }

      final ImmutableBuffer buffer = await ui.ImmutableBuffer.fromUint8List(byteData.buffer.asUint8List());
      return await decode(buffer);
    } catch (e) {
      debugPrint('Failed to load image from URL: $url. Error: $e');
      rethrow;
    }
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is ImageLoadProvider &&
        other.url == url &&
        other.width == width &&
        other.height == height &&
        other.fit == fit;
  }

  @override
  int get hashCode => Object.hash(url, width, height, fit);

  @override
  String toString() => 'ImageLoadProvider(url: "$url", width: $width, height: $height, fit: $fit)';
}
