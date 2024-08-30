
import 'package:cached_network_image/cached_network_image.dart';
import 'package:common_plugin/common_plugin.dart';
import 'package:flutter/material.dart';

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
          showAppBarTitle: false,
          showAppScaffold: false,
          iconSize: iconSize,
          onlyShowIcon: _onlyShowIcon,
        ),
      ),
      errorWidget: (context, url, error) => errorWidget ?? SizedBox(
        height: height ?? 100,
        child: LoadingPage(
          type: LoadingType.error,
          showAppBarTitle: false,
          showAppScaffold: false,
          iconSize: iconSize,
          onlyShowIcon: _onlyShowIcon,
        ),
      ),
    );
  }

}

