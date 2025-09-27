import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';

class YourLocationScreen extends StatefulWidget {
  final bool isComeFromSplash;

  const YourLocationScreen({super.key, this.isComeFromSplash = false});

  static const routeName = "your_location_screen";

  static Widget builder(BuildContext context, {bool isComeFromSplash = false}) {
    return ChangeNotifierProvider<YourLocationProvider>(
      create: (c) => YourLocationProvider(isComeFromSplash: isComeFromSplash),
      child: YourLocationScreen(isComeFromSplash: isComeFromSplash),
    );
  }

  @override
  State<YourLocationScreen> createState() => _YourLocationScreenState();
}

class _YourLocationScreenState extends State<YourLocationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    // Register the observer for lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    // Check permissions initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Builder(
          builder: (BuildContext newContext) {
            Provider.of<YourLocationProvider>(
              newContext,
              listen: false,
            ).checkPermissionsAfterSettings(newContext);
            Provider.of<YourLocationProvider>(
              newContext,
              listen: false,
            ).checkPermissionsAfterSettings(newContext);
            return Container(); // Return an empty widget as this is just for context
          },
        );
      }
    });
  }

  @override
  void dispose() {
    // Remove the observer when the widget is disposed
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      Builder(
        builder: (BuildContext newContext) {
          Provider.of<YourLocationProvider>(
            newContext,
            listen: false,
          ).checkPermissionsAfterSettings(newContext);
          return Container(); // Return an empty widget as this is just for context
        },
      );
    }
  }

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed && mounted) {
  //     // Use a Builder to ensure a fresh context with access to the provider
  //     Builder(
  //       builder: (BuildContext newContext) {
  //         Provider.of<YourLocationProvider>(newContext, listen: false)
  //             .checkPermissionsAfterSettings(newContext);
  //         return Container(); // Return an empty widget as this is just for context
  //       },
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Consumer<YourLocationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Constants.horizontalPadding,
                  vertical: 30,
                ),
                child: CustomSingleChildScroll(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      8.ph.spaceVertical,
                      if (!provider.isComeFromSplash) AppBackIcon(),
                      30.ph.spaceVertical,
                      Text(
                        context.l10n?.whatIsYOurLocation ?? "",
                        style: styleW700S24,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n?.locationForRestaurantAndProduct ?? "",
                        style: styleW400S16.copyWith(color: ColorRes.grey6),
                        textAlign: TextAlign.center,
                      ),
                      56.ph.spaceVertical,
                      SizedBox(
                        height: 220,
                        width: double.infinity,
                        child: Center(
                          child: AssetsImg(imagePath: AssetRes.locationImg),
                        ),
                      ),
                      123.ph.spaceVertical,
                      SubmitButton(
                        loading: provider.isLoading,
                        onTap: () async {
                          await provider.allowLocation(context);
                        },
                        title:
                            context.l10n?.allowLocationAccess ??
                            "Allow Location Access",
                      ),
                      12.ph.spaceVertical,
                      TextButton(
                        onPressed: () async {
                          context.navigator.pushNamed(MapScreen.routeName);
                        },
                        child: Text(
                          context.l10n?.interLocationManually ?? "",
                          style: TextStyle(color: Colors.black87),
                        ),
                      ),
                      if (provider.errorMessage != null) ...[
                        12.ph.spaceVertical,
                        Text(
                          provider.errorMessage!,
                          style: TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      20.ph.spaceVertical,
                    ],
                  ),
                ),
              ),
              if (provider.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  // Semi-transparent background
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
