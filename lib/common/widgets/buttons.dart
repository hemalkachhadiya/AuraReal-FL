import 'package:aura_real/aura_real.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({
    super.key,
    this.title,
    this.onTap,
    this.bgColor,
    this.raduis,
    this.enable = true,
    this.loading = false,
    this.style,
    this.height,
  });

  final String? title;
  final VoidCallback? onTap;
  final double? height;
  final double? raduis;
  final TextStyle? style;
  final Color? bgColor;
  final bool enable;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: 200.milliseconds,
      width: 100.w,
      height: height ?? 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(raduis??30.pw),
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
                borderRadius: BorderRadius.circular(8.pw),
                child: Center(
                  child: Text(
                    title ?? '',
                    style:
                    style ?? styleW700S16.copyWith(color: ColorRes.white),
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

class EmptyButton extends StatelessWidget {
  const EmptyButton({
    super.key,
    this.title,
    this.onTap,
    this.style,
    this.enable = true,
    this.loading = false,
    this.isBordered = false,
  });

  final String? title;
  final VoidCallback? onTap;
  final bool enable;
  final bool isBordered;
  final TextStyle? style;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.pw),
        border: Border.all(
          color: isBordered ? ColorRes.primaryColor : ColorRes.transparent,
        ),
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
                  child: CircularProgressIndicator(color: ColorRes.black),
                ),
              );
            }
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enable ? onTap : null,
                borderRadius: BorderRadius.circular(8.pw),
                child: Center(
                  child: Text(
                    title ?? '',
                    style:
                    style ??
                        styleW700S16.copyWith(
                          color: enable ? null : ColorRes.black,
                        ),
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
