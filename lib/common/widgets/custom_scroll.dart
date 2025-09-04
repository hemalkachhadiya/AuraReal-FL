import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/widgets/common_widget.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    this.padding,
    this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.physics,
    this.emptyWidget,
    this.primary,
    this.showEmptyWidget = false,
    this.onRefresh,
    this.shrinkWrap,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.controller,
  });

  final EdgeInsetsGeometry? padding;
  final int? itemCount;
  final Widget? Function(BuildContext, int) itemBuilder;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;
  final bool showEmptyWidget;
  final bool? primary;
  final bool? shrinkWrap;
  final Future<void> Function()? onRefresh;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return AppRefreshIndicator(
      onRefresh: onRefresh,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ListView.separated(
            controller: controller,
            itemCount: itemCount ?? 0,
            padding: padding ?? EdgeInsets.zero,
            primary: primary,
            shrinkWrap: shrinkWrap ?? false,
            physics: physics ?? AlwaysScrollableScrollPhysics(),
            itemBuilder: itemBuilder,
            keyboardDismissBehavior: keyboardDismissBehavior,
            separatorBuilder: separatorBuilder ?? ((con, index) => SizedBox()),
          ),
          AnimatedSwitcher(
            duration: 300.milliseconds,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Visibility(
              key: ValueKey<bool>(showEmptyWidget),
              visible: showEmptyWidget,
              child: emptyWidget ?? SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSingleChildScroll extends StatelessWidget {
  const CustomSingleChildScroll({
    super.key,
    this.padding,
    this.physics,
    this.emptyWidget,
    this.primary,
    this.showEmptyWidget = false,
    this.onRefresh,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.controller,
    required this.child,
  });

  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final Widget? emptyWidget;
  final bool showEmptyWidget;
  final bool? primary;
  final Future<void> Function()? onRefresh;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController? controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constrains) {
        return AppRefreshIndicator(
          onRefresh: onRefresh,
          child: SingleChildScrollView(
            controller: controller,
            padding: padding,
            primary: primary,
            physics: physics ?? AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: keyboardDismissBehavior,
            child: Builder(
              builder: (context) {
                if (showEmptyWidget) {
                  return SizedBox(
                    height: constrains.maxHeight,
                    width: constrains.maxWidth,
                    child: Center(child: emptyWidget ?? SizedBox()),
                  );
                } else {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constrains.maxHeight,
                      minWidth: constrains.maxWidth,
                    ),
                    child: child,
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
