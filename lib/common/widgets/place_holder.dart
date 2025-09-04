import 'package:aura_real/aura_real.dart';

class CustomShimmer extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;

  const CustomShimmer({super.key, this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Shimmer.fromColors(
        baseColor: ColorRes.grey,
        highlightColor: ColorRes.grey.withValues(alpha: 0.6),
        child: Container(
          height: height ?? 100.h,
          width: width ?? 100.w,
          color: ColorRes.black,
        ),
      ),
    );
  }
}

class CustomShimmer2 extends StatelessWidget {
  final double? height;
  final double? width;
  final double? borderRadius;

  const CustomShimmer2({super.key, this.height, this.width, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0),
      child: Shimmer.fromColors(
        baseColor: ColorRes.lightGrey.withValues(alpha: 0.3),
        highlightColor: ColorRes.lightGrey.withValues(alpha: 0.6),
        child: Container(
          height: height ?? 100.h,
          width: width ?? 100.w,
          color: ColorRes.black,
        ),
      ),
    );
  }
}
