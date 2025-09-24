import 'package:aura_real/aura_real.dart';

/// Enhanced function to open Custom Draggable BottomSheet with animation
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
  double initialChildSize = 0.9,
  double minChildSize = 0.6,
  double maxChildSize = 0.9,
}) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    backgroundColor: Colors.transparent,
    transitionAnimationController: AnimationController(
      vsync: Navigator.of(context).overlay!,
      duration: const Duration(milliseconds: 300),
    )..forward(),

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

/// Custom Draggable BottomSheet Widget with Comment Tree
class DraggableCustomBottomSheet<T> extends StatefulWidget {
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
  State<DraggableCustomBottomSheet<T>> createState() =>
      _DraggableCustomBottomSheetState<T>();
}

class _DraggableCustomBottomSheetState<T>
    extends State<DraggableCustomBottomSheet<T>>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (context, scrollController) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: widget.padding ?? const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(widget.borderRadius ?? 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar with animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: styleW700S20,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                // Subtitle
                if (widget.subtitle != null) ...[
                  Text(
                    widget.subtitle!,
                    style: styleW400S16.copyWith(color: ColorRes.grey6),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],

                // Comment Tree with scroll animation
                Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollBehavior().copyWith(overscroll: false),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: widget.customChild ?? Container(),
                    ),
                  ),
                ),

                // Buttons
                if (widget.showButtons) ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      if (widget.cancelBtnTitle != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              widget.onCancelTap?.call();
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
                              widget.cancelBtnTitle!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      if (widget.confirmBtnTitle != null)
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onConfirmTap?.call();
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
                              widget.confirmBtnTitle ?? 'OK',
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
