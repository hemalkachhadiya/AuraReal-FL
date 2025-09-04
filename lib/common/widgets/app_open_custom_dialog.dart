import 'package:aura_real/aura_real.dart';

// Enhanced Custom Dialog Function
Future<T?> openCustomDialog<T>(
  BuildContext context, {
  String? title,
  String? subtitle,
  Widget? customChild,
  VoidCallback? onCancelTap,
  VoidCallback? onConfirmTap,
  String? cancelBtnTitle,
  String? confirmBtnTitle,
  bool showButtons = true,
  bool barrierDismissible = true,
  EdgeInsets? padding,
  double? borderRadius,
}) async {
  final result = await showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (context) {
      return CustomDialog<T>(
        title: title,
        subtitle: subtitle,
        customChild: customChild,
        onCancelTap: onCancelTap,
        onConfirmTap: onConfirmTap,
        cancelBtnTitle: cancelBtnTitle,
        confirmBtnTitle: confirmBtnTitle,
        showButtons: showButtons,
        padding: padding,
        borderRadius: borderRadius,
      );
    },
  );
  return result;
}

// Custom Dialog Widget
class CustomDialog<T> extends StatelessWidget {
  const CustomDialog({
    super.key,
    this.title,
    this.subtitle,
    this.customChild,
    this.onCancelTap,
    this.onConfirmTap,
    this.cancelBtnTitle,
    this.confirmBtnTitle,
    this.showButtons = true,
    this.padding,
    this.borderRadius,
  });

  final String? title;
  final String? subtitle;
  final Widget? customChild;
  final VoidCallback? onCancelTap;
  final VoidCallback? onConfirmTap;
  final String? cancelBtnTitle;
  final String? confirmBtnTitle;
  final bool showButtons;
  final EdgeInsets? padding;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
      ),
      insetPadding: EdgeInsets.symmetric(
        horizontal: Constants.horizontalPadding,
      ),
      backgroundColor: Colors.white,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  margin: EdgeInsets.only(bottom: 15),
                  child: InkWell(
                    onTap: () {
                      context.navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: ColorRes.red,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close,
                            color: ColorRes.white,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Spacer(),
              ],
            ),
            // Title
            if (title != null) ...[
              Text(title!, style: styleW700S24, textAlign: TextAlign.center),
              const SizedBox(height: 16),
            ],

            // Subtitle
            if (subtitle != null) ...[
              Text(
                subtitle!,
                style: styleW400S16.copyWith(color: ColorRes.grey6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],

            // Custom Child Widget
            if (customChild != null) ...[
              customChild!,
              if (showButtons) const SizedBox(height: 20),
            ],

            // Buttons
            if (showButtons) ...[
              Row(
                children: [
                  if (cancelBtnTitle != null) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          onCancelTap?.call();
                          Navigator.of(context).pop();
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius ?? 8,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          cancelBtnTitle!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (confirmBtnTitle != null)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onConfirmTap?.call();
                          Navigator.of(context).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              borderRadius ?? 8,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                        child: Text(
                          confirmBtnTitle ?? 'OK',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Enhanced version of your existing alert dialog with custom child support
Future<bool> openAppAlertDialog(
  BuildContext context, {
  String? title,
  String? subTitle,
  Widget? customChild,
  VoidCallback? onCancelTap,
  VoidCallback? onYesTap,
  String? cancelBtnTitle,
  String? yesBtnTitle,
  bool showButtons = true,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AppAlertDialog(
        title: title ?? '',
        subTitle: subTitle,
        customChild: customChild,
        onCancelTap: onCancelTap,
        onYesTap: onYesTap,
        cancelBtnTitle: cancelBtnTitle ?? 'Cancel',
        yesBtnTitle: yesBtnTitle ?? 'OK',
        showButtons: showButtons,
      );
    },
  );
  return result == true;
}

// Enhanced AppAlertDialog with custom child support
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    required this.title,
    this.subTitle,
    this.customChild,
    this.onCancelTap,
    this.onYesTap,
    required this.cancelBtnTitle,
    required this.yesBtnTitle,
    this.showButtons = true,
  });

  final String title;
  final String? subTitle;
  final Widget? customChild;
  final VoidCallback? onCancelTap;
  final VoidCallback? onYesTap;
  final String cancelBtnTitle;
  final String yesBtnTitle;
  final bool showButtons;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Title
          if (title.isNotEmpty) ...[
            Center(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Divider
          Divider(color: Colors.grey.shade300),
          const SizedBox(height: 12),

          // Subtitle
          if (subTitle != null) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  subTitle!,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Custom Child Widget
          if (customChild != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: customChild!,
            ),
            const SizedBox(height: 20),
          ],

          // Buttons
          if (showButtons) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        onCancelTap?.call();
                        Navigator.of(context).pop(false);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        cancelBtnTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        onYesTap?.call();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C5CE7),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        yesBtnTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

