import 'package:aura_real/aura_real.dart';
class UnKnownScreen extends StatelessWidget {
  static const String routeName = "/pageNotFound";

  const UnKnownScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text("Page Not Found", style: styleW700S22)),
    );
  }
}
