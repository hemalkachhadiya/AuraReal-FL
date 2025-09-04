import 'package:aura_real/aura_real.dart';


void showCustomToast(String msg, {bool? error}) {
  Widget widget() {
    final topSafeArea = Constants.safeAreaPadding.top;

    Color toastColor = error == true ? ColorRes.red : ColorRes.primaryColor;
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
            top: topSafeArea + 2.ph,
            left: 10.pw,
            right: 10.pw,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: ColorRes.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, 16),
                blurRadius: 24,
                color: ColorRes.black.withValues(alpha: 0.14),
              ),
              BoxShadow(
                offset: const Offset(0, 6),
                blurRadius: 30,
                color: ColorRes.black.withValues(alpha: 0.12),
              ),
              BoxShadow(
                offset: const Offset(0, 8),
                blurRadius: 10,
                color: ColorRes.black.withValues(alpha: 0.2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// Space
                    SizedBox(height: 15.pw),

                    Row(
                      children: [
                        /// Space
                        SizedBox(width: Constants.horizontalPadding),

                        Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: ColorRes.grey,
                          ),
                          padding: EdgeInsets.all(4.pw),
                          child: SvgAsset(
                            imagePath:
                            error == true
                                ? AssetRes.closeIcon
                                : AssetRes.rightTickIcon,
                            color: ColorRes.white,
                            height: 12.pw,
                          ),
                        ),

                        /// Space
                        SizedBox(width: 15.pw),

                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                error == true ? "Error" : "Success",
                                style: styleW700S17.copyWith(
                                  color: ColorRes.black2,
                                ),
                              ),

                              /// Space
                              const SizedBox(height: 2),

                              Text(
                                msg,
                                style: styleW400S13.copyWith(
                                  color: ColorRes.black,
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// Space
                        SizedBox(width: 15.pw),
                      ],
                    ),

                    /// Space
                    SizedBox(height: 15.pw),

                    Container(
                      height: 3,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: toastColor,
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(-5, 0),
                            blurRadius: 5,
                            spreadRadius: 1,
                            color: toastColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: -65.pw,
                  left: -74.pw,
                  child: Container(
                    height: 212.pw,
                    width: 212.pw,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors:
                        error == true
                            ? [
                          ColorRes.red.withValues(alpha: 0.12),
                          ColorRes.red.withValues(alpha: 0),
                        ]
                            : [
                          ColorRes.primaryColor.withValues(alpha: 0.12),
                          ColorRes.primaryColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  showToastWidget(
    widget(),
    duration: const Duration(seconds: 3),
    handleTouch: true,
    dismissOtherToast: true,
  );
}
