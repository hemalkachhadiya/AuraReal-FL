import 'package:aura_real/aura_real.dart';

import 'package:aura_real/aura_real.dart';

class SubmitButton2 extends StatelessWidget {
  const SubmitButton2({
    super.key,
    this.title,
    this.onTap,
    this.bgColor,
    this.raduis,
    this.enable = true,
    this.loading = false,
    this.style,
    this.height,
    this.icon, // New parameter for icon
  });

  final String? title;
  final VoidCallback? onTap;
  final double? height;
  final double? raduis;
  final TextStyle? style;
  final Color? bgColor;
  final bool enable;
  final bool loading;
  final String? icon; // Icon data (e.g., Icons.upload)

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 200.milliseconds,
      width: 100.w,
      height: height ?? 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raduis ?? 30.pw),
        color:
            enable
                ? bgColor ?? ColorRes.primaryColor
                : bgColor?.withValues(alpha: 0.6) ??
                    ColorRes.primaryColor.withValues(alpha: 0.6),
      ),
      child: AnimatedSwitcher(
        duration: 300.milliseconds,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: Builder(
          key: ValueKey<bool>(loading),
          builder: (context) {
            if (loading) {
              return Center(
                child: SizedBox(
                  height: 25,
                  width: 25,
                  child: CircularProgressIndicator(color: ColorRes.white),
                ),
              );
            }
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enable ? onTap : null,
                borderRadius: BorderRadius.circular(raduis??8.pw),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // Center content horizontally
                    children: [
                      if (icon != null) // Conditionally show icon
                        SvgAsset(imagePath: icon ?? "", color: ColorRes.white),
                      if (icon != null) 8.0.spaceHorizontal,
                      // Spacing between icon and text
                      Text(
                        title ?? '',
                        style:
                            style ??
                            styleW600S10.copyWith(color: ColorRes.white),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
