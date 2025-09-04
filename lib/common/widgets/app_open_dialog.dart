import 'package:aura_real/aura_real.dart';

Future<bool> openAppAlertDialog(
  BuildContext context, {
  String? title,
  String? subTitle,
  VoidCallback? onCancelTap,
  VoidCallback? onYesTap,
  String? cancelBtnTitle,
  String? yesBtnTitle,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AppAlertDialog(
        title: title ?? '',
        subTitle: subTitle,
        onCancelTap: onCancelTap,
        onYesTap: onYesTap,
        cancelBtnTitle: context.l10n?.cancel ?? '',
        yesBtnTitle: yesBtnTitle ?? (context.l10n?.ok ?? ''),
      );
    },
  );
  return result == true;
}

class AppAlertDialog<bool> extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    this.subTitle,
    this.onCancelTap,
    this.onYesTap,
    required this.cancelBtnTitle,
    required this.yesBtnTitle,
  });

  final String title;
  final String? subTitle;
  final VoidCallback? onCancelTap;
  final VoidCallback? onYesTap;
  final String cancelBtnTitle;
  final String yesBtnTitle;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.pw),
      backgroundColor: ColorRes.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Header
          16.ph.spaceVertical,

          /// Title
          Center(child: Text(title, style: styleW600S20)),

          /// Divider
          Divider(color: ColorRes.primaryColor),

          /// Subtitle
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.pw),
              child: Text(
                subTitle ?? '',
                style: styleW400S16,
                textAlign: TextAlign.center,
              ),
            ),
          ),

          ///Spacing
          25.ph.spaceVertical,

          /// Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: EmptyButton(
                  title: cancelBtnTitle,
                  onTap: () {
                    onCancelTap?.call();
                    context.navigator.pop(false);
                  },
                ),
              ),
              16.pw.spaceHorizontal,
              Expanded(
                child: SubmitButton(
                  title: yesBtnTitle,

                  onTap: () {
                    onYesTap?.call();
                    context.navigator.pop(true);
                  },
                ),
              ),
              16.pw.spaceHorizontal,
            ],
          ),

          /// Spacing
          16.ph.spaceVertical,
        ],
      ),
    );
  }
}
