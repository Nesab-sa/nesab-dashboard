import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A unified image widget that renders SVG, asset, or network images.
///
/// Automatically detects the image type based on [path]:
/// - Ends with `.svg` → renders as SVG (asset or network)
/// - Starts with `http` → renders as network image (cached)
/// - Otherwise → renders as asset image
class AppImage extends StatelessWidget {
  const AppImage({
    required this.path,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholder,
    super.key,
  });

  final String path;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final Widget? placeholder;

  bool get _isSvg => path.toLowerCase().endsWith('.svg');
  bool get _isNetwork => path.startsWith('http');

  @override
  Widget build(BuildContext context) {
    if (_isSvg) {
      return _isNetwork
          ? SvgPicture.network(
              path,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
            )
          : SvgPicture.asset(
              path,
              width: width,
              height: height,
              fit: fit,
              alignment: alignment,
              colorFilter: color != null
                  ? ColorFilter.mode(color!, BlendMode.srcIn)
                  : null,
            );
    }

    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        alignment: alignment as Alignment,
        color: color,
        placeholder: placeholder != null ? (_, _) => placeholder! : null,
        errorWidget: (_, _, _) =>
            placeholder ?? const Icon(Icons.broken_image_outlined),
      );
    }

    return Image.asset(
      path,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      color: color,
      cacheWidth: width != null ? (width! * 2).toInt() : null,
      cacheHeight: height != null ? (height! * 2).toInt() : null,
      errorBuilder: placeholder != null
          ? (_, _, _) => placeholder!
          : (_, _, _) => const Icon(Icons.broken_image_outlined),
    );
  }
}
