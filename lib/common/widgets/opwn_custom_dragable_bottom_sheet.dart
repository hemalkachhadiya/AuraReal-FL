import 'package:aura_real/aura_real.dart';

/// Enhanced function to open Custom Draggable BottomSheet
Future<T?> openCustomDraggableBottomSheet<T>(
  BuildContext context, {
  String? title,
  String? subtitle,
  Widget? customChild,
  VoidCallback? onCancelTap,
  VoidCallback? onConfirmTap,
  String? cancelBtnTitle,
  String? confirmBtnTitle,
  bool showButtons = true,
  double? borderRadius,
  EdgeInsets? padding,
  bool isDismissible = true,
  bool enableDrag = true,
  double initialChildSize = 0.9, // Increased from 0.8
  double minChildSize = 0.6, // Increased from 0.5
  double maxChildSize = 0.9, // Increased from 0.9 to allow full screen
}) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return DraggableCustomBottomSheet<T>(
        title: title,
        subtitle: subtitle,
        customChild: customChild,
        onCancelTap: onCancelTap,
        onConfirmTap: onConfirmTap,
        cancelBtnTitle: cancelBtnTitle,
        confirmBtnTitle: confirmBtnTitle,
        showButtons: showButtons,
        borderRadius: borderRadius,
        padding: padding,
        initialChildSize: initialChildSize,
        minChildSize: minChildSize,
        maxChildSize: maxChildSize,
      );
    },
  );
  return result;
}

/// Custom Draggable BottomSheet Widget
class DraggableCustomBottomSheet<T> extends StatelessWidget {
  const DraggableCustomBottomSheet({
    super.key,
    this.title,
    this.subtitle,
    this.customChild,
    this.onCancelTap,
    this.onConfirmTap,
    this.cancelBtnTitle,
    this.confirmBtnTitle,
    this.showButtons = true,
    this.borderRadius,
    this.padding,
    this.initialChildSize = 0.7,
    this.minChildSize = 0.5,
    this.maxChildSize = 0.9,
  });

  final String? title;
  final String? subtitle;
  final Widget? customChild;
  final VoidCallback? onCancelTap;
  final VoidCallback? onConfirmTap;
  final String? cancelBtnTitle;
  final String? confirmBtnTitle;
  final bool showButtons;
  final double? borderRadius;
  final EdgeInsets? padding;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: initialChildSize,
      minChildSize: minChildSize,
      maxChildSize: maxChildSize,
      builder: (context, scrollController) {
        return Container(
          padding: padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(borderRadius ?? 16),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                if (title != null) ...[
                  Text(
                    title!,
                    style: styleW700S20,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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

                // Custom Child with scrollable content
                if (customChild != null) ...[
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: customChild!,
                    ),
                  ),
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
                                borderRadius: BorderRadius.circular(8),
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
                                borderRadius: BorderRadius.circular(8),
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
      },
    );
  }
}
