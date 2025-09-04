import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';

class YourLocationScreen extends StatelessWidget {
  const YourLocationScreen({super.key});

  static const routeName = "your_location_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<YourLocationProvider>(
      create: (c) => YourLocationProvider(),
      child: const YourLocationScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<YourLocationProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 30
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                8.ph.spaceVertical,
                AppBackIcon(),
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

                // Illustration
                Container(
                  height: 220,
                  width: double.infinity,

                  child: Center(
                    child: AssetsImg(imagePath: AssetRes.locationImg),
                  ),
                ),
                123.ph.spaceVertical,
                // Allow location button
                SubmitButton(
                  onTap: () {
                    provider.allowLocation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Location access granted")),
                    );
                  },

                  title: context.l10n?.allowLocationAccess ?? "",
                ),

                12.ph.spaceVertical,

                // Enter manually
                TextButton(
                  onPressed: () async {
                    final location = await _showManualLocationDialog(context);
                    if (location != null && location.isNotEmpty) {
                      provider.setManualLocation(location);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Manual location: $location")),
                      );
                    }
                  },
                  child: Text(
                    context.l10n?.interLocationManually ?? "",
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
                20.ph.spaceVertical,
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showManualLocationDialog(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Enter Location"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Type your city or area",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, null),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, controller.text.trim()),
                child: const Text("Save"),
              ),
            ],
          ),
    );
  }
}
