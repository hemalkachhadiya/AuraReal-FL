import 'dart:io';

import 'package:aura_real/aura_real.dart';

class SvgAsset extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final double? borderRadius;
  final Alignment? alignment;

  const SvgAsset({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.borderRadius,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: SvgPicture.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        alignment: alignment ?? Alignment.center,
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}

class SvgNetwork extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final double? loadingHeight;
  final double? loadingWidth;
  final Color? color;
  final BoxFit? fit;
  final double? borderRadius;
  final Alignment? alignment;
  final Widget? errorWidget;

  const SvgNetwork({
    super.key,
    required this.url,
    this.height,
    this.width,
    this.loadingHeight,
    this.loadingWidth,
    this.color,
    this.fit,
    this.borderRadius,
    this.alignment,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child:
          url == null
              ? _errorWidgetBox()
              : SvgPicture.network(
                url.toString(),
                height: height,
                width: width,
                fit: fit ?? BoxFit.contain,
                alignment: alignment ?? Alignment.center,
                // placeholderBuilder: (con) {
                //   return CustomShimmer(
                //     height: loadingHeight ?? height,
                //     width: loadingWidth ?? width,
                //   );
                // },
                colorFilter:
                    color == null
                        ? null
                        : ColorFilter.mode(color!, BlendMode.srcIn),
              ),
    );
  }

  Widget _errorWidgetBox() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    return Container(
      height: height,
      width: width,
      color: ColorRes.white,
      padding: EdgeInsets.all(5.pw),
      child: SvgAsset(
        imagePath: AssetRes.appLogo,
        height: height,
        width: width,
        // fit: BoxFit.,
      ),
    );
  }
}

class AssetsImg extends StatelessWidget {
  final String imagePath;
  final double? height;
  final double? width;
  final Color? color;
  final BoxFit? fit;
  final double? borderRadius;

  const AssetsImg({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Image.asset(
        imagePath,
        height: height,
        width: width,
        fit: fit ?? BoxFit.contain,
        color: color,
      ),
    );
  }
}

class FileImg extends StatelessWidget {
  final File? file;
  final double? height;
  final double? width;
  final double? loadingHeight;
  final double? loadingWidth;
  final BoxFit? fit;
  final double? borderRadius;
  final Widget? errorWidget;
  final bool skipBaseUrl;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  const FileImg(
    this.file, {
    super.key,
    this.height,
    this.width,
    this.loadingHeight,
    this.loadingWidth,
    this.fit,
    this.borderRadius,
    this.errorWidget,
    this.skipBaseUrl = false,
    this.progressIndicatorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child:
          file == null
              ? _errorWidgetBox()
              : Image.file(
                file!,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                errorBuilder: (con, str, obj) {
                  return _errorWidgetBox();
                },
              ),
    );
  }

  Widget _errorWidgetBox() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    return Container(
      height: height,
      width: width,
      color: ColorRes.white,
      padding: EdgeInsets.all(5.pw),
      child: SvgAsset(
        imagePath: AssetRes.appLogo,
        height: height,
        width: width,
        // fit: BoxFit.,
      ),
    );
  }
}

class CachedImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final double? loadingHeight;
  final double? loadingWidth;
  final BoxFit? fit;
  final double? borderRadius;
  final Widget? errorWidget;
  final bool skipBaseUrl;
  final ProgressIndicatorBuilder? progressIndicatorBuilder;

  final Map<String, String>? headers;

  const CachedImage(
    this.url, {
    super.key,
    this.height,
    this.width,
    this.loadingHeight,
    this.loadingWidth,
    this.fit,
    this.borderRadius,
    this.errorWidget,
    this.skipBaseUrl = false,
    this.progressIndicatorBuilder,
    this.headers,
  });

  @override
  Widget build(BuildContext context) {
    String updatedUrl = "";
    if (skipBaseUrl) {
      updatedUrl = url.toString();
    } else {
      updatedUrl = url.toString();
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child:
          url == null
              ? _errorWidgetBox()
              : CachedNetworkImage(
                imageUrl: updatedUrl,
                height: height,
                width: width,
                fit: fit ?? BoxFit.cover,
                httpHeaders: headers,
                errorWidget: (con, str, obj) {
                  return _errorWidgetBox();
                },
                progressIndicatorBuilder:
                    progressIndicatorBuilder ??
                    (con, str, progress) {
                      return CustomShimmer(
                        height: loadingHeight ?? height,
                        width: loadingWidth ?? width,
                      );
                    },
              ),
    );
  }

  Widget _errorWidgetBox() {
    if (errorWidget != null) {
      return errorWidget!;
    }
    return Container(
      height: height,
      width: width,
      color: ColorRes.white,
      padding: EdgeInsets.all(5.pw),
      child: SvgAsset(
        imagePath: AssetRes.appLogo,
        height: height,
        width: width,
        // fit: BoxFit.,
      ),
    );
  }
}
