import 'package:aura_real/aura_real.dart';

void openAppBottomShit({
  required BuildContext context,
  String? image,
  String? title,
  String? content,
  String? btnText,
  VoidCallback? onBtnTap,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
    ),
    builder: (BuildContext context) {
      return AppBottomShit(
        image: image,
        title: title,
        content: content,
        btnText: btnText,
        onBtnTap: onBtnTap,
      );
    },
  );
}

class AppBottomShit extends StatelessWidget {
  const AppBottomShit({
    super.key,
    this.image,
    this.title,
    this.content,
    this.btnText,
    this.onBtnTap,
  });

  final String? image;
  final String? title;
  final String? content;
  final String? btnText;
  final VoidCallback? onBtnTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100.w,
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: 24.ph,
              left: Constants.horizontalPadding,
              right: Constants.horizontalPadding,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (image != null)
                  Container(
                    height: 130.pw,
                    width: 130.pw,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: ColorRes.primaryColor,
                    ),
                    child: Container(
                      height: 108.pw,
                      width: 108.pw,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ColorRes.primaryColor,
                      ),
                      child: Container(
                        height: 86.pw,
                        width: 86.pw,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorRes.primaryColor,
                        ),
                        child: SvgAsset(
                          imagePath: image!,
                          height: 40.pw,
                          width: 40.pw,
                          color: ColorRes.white,
                        ),
                      ),
                    ),
                  ),

                20.ph.spaceVertical,

                Text(title ?? "", style: styleW700S20),

                16.ph.spaceVertical,

                Text(
                  content ?? "",
                  style: styleW400S14.copyWith(color: ColorRes.grey),
                  textAlign: TextAlign.center,
                ),

                24.ph.spaceVertical,

                SafeArea(
                  top: false,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.ph),
                    child: SubmitButton(title: btnText ?? "", onTap: onBtnTap),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: context.navigator.pop,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(Constants.horizontalPadding),
                child: SvgAsset(
                  imagePath: AssetRes.closeIcon,
                  height: Constants.horizontalPadding,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
