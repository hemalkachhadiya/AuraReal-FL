import 'package:aura_real/aura_real.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}

class SmallLoader extends StatelessWidget {
  const SmallLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: AppLoader());
  }
}

class FullPageLoader extends StatelessWidget {
  const FullPageLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      width: 100.w,
      decoration: BoxDecoration(color: ColorRes.black.withValues(alpha: 0.2)),
      child: Center(child: AppLoader()),
    );
  }
}

class StackedLoader extends StatelessWidget {
  final bool loading;
  final Widget child;

  const StackedLoader({super.key, this.loading = false, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (loading)
          Container(
            height: 100.h,
            width: 100.w,
            decoration: BoxDecoration(
              color: ColorRes.black.withValues(alpha: 0.2),
            ),
            child: Center(child: AppLoader()),
          ),
      ],
    );
  }
}

// class AppRefreshIndicator extends StatelessWidget {
//   final Widget child;
//   final Future<void> Function()? onRefresh;
//
//   const AppRefreshIndicator({
//     super.key,
//     required this.child,
//     required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (onRefresh == null) return child;
//     return RefreshIndicator(
//       onRefresh: onRefresh!,
//       backgroundColor: ColorRes.white,
//       color: ColorRes.primaryColor,
//       strokeWidth: 4,
//       child: child,
//     );
//   }
// }

bool isLoaderDialogOpen = false;

void startLoaderDialog() {
  final context = navigatorKey.currentContext;
  if (isLoaderDialogOpen || context == null) {
    return;
  }
  isLoaderDialogOpen = true;
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: SizedBox(
          height: 100.h,
          width: 100.w,
          child: const SmallLoader(),
        ),
      );
    },
    useSafeArea: false,
    barrierDismissible: false,
    barrierColor: ColorRes.white.withValues(alpha: 0.1),
  ).whenComplete(() {
    isLoaderDialogOpen = false;
  });
}

void closeLoaderDialog() {
  final context = navigatorKey.currentContext;
  if (context == null) {
    return;
  }
  if (isLoaderDialogOpen) {
    context.navigator.pop();
  }
}
