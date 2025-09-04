import 'package:aura_real/aura_real.dart';

class CustomHeader extends StatelessWidget {
  final String? title;
  final String? description;
  final List<Widget>? actions;
  final Color backgroundColor;
  final bool centerTitle;
  final bool showBackBtn;
  final Widget? customWidget;

  const CustomHeader({
    super.key,
    this.title,
    this.description,
    this.actions,
    this.customWidget,
    this.backgroundColor = const Color(0xFF5E5CE6),
    this.centerTitle = true,
    this.showBackBtn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Container(
          width: 100.w,
          height: 237.ph,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(60),
              bottomRight: Radius.circular(60),
            ),
          ),
        ),

        // Background icons
        Positioned(
          top: 0,
          left: 0,
          child: SvgPicture.asset(
            AssetRes.headerBgIcon,
            width: 100,
            height: 100,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Transform.rotate(
            angle: -1.01 * 3.14159,
            child: SvgPicture.asset(
              AssetRes.headerBgIcon,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Content
        Container(
          width: double.infinity,
          height: 237.ph,
          padding: EdgeInsets.only(top: 68, bottom: 31),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Back button (fixed left)
              if (showBackBtn)
                Positioned(
                  left: Constants.isTablet ? 16.pw : Constants.horizontalPadding,
                  top: 0,
                  child: InkWell(
                    onTap: () => context.navigator.pop(),
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      height: 30.pw,
                      width: 30.pw,
                      decoration: BoxDecoration(
                        color: ColorRes.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: SvgAsset(imagePath: AssetRes.leftIcon),
                      ),
                    ),
                  ),
                ),

              // Title + description (always centered)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: styleW700S24.copyWith(color: ColorRes.white),
                      textAlign: TextAlign.center,
                    ),
                  10.ph.spaceVertical,
                  if (description != null)
                    Text(
                      description!,
                      style: styleW400S14.copyWith(
                        color: ColorRes.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),

              // Actions (top-right)
              if (actions != null)
                Positioned(right: 16.pw, child: Row(children: actions!)),
            ],
          ),
        ),
      ],
    );
  }
}
