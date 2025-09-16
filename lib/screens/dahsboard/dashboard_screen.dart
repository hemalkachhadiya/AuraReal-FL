import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/your_location/your_location_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const routeName = "dashboard";

  static Widget builder(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<YourLocationProvider>(
          create: (c) => YourLocationProvider(isComeFromSplash: false),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (c) => DashboardProvider(),
        ),
      ],
      child: const DashboardScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashboardProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: dashboardProvider.selectedIndex,
        children: [
          HomeScreen(),
          RatingScreen(),
          ChatScreen(),
          SettingScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 60,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              index: 0,
              icon: dashboardProvider.selectedIndex == 0?AssetRes.homeDarkIcon:AssetRes.homeIcon,
              label: 'Home',
              provider: dashboardProvider,
            ),
            _buildNavItem(
              context,
              index: 1,
              icon: dashboardProvider.selectedIndex == 1?AssetRes.starDarkIcon:AssetRes.starIcon,
              label: 'Rating',
              provider: dashboardProvider,
            ),
            _buildNavItem(
              context,
              index: 2,
              icon: dashboardProvider.selectedIndex == 2?AssetRes.msgDarkIcon:AssetRes.msgGrayIcon,
              label: 'Private Chat',
              provider: dashboardProvider,
            ),
            _buildNavItem(
              context,
              index: 3,
              icon:  dashboardProvider.selectedIndex == 3?AssetRes.settingDarkIcon:AssetRes.settingGrayIcon,
              label: 'Setting',
              provider: dashboardProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required String icon,
    required String label,
    required DashboardProvider provider,
  }) {
    final bool isSelected = provider.selectedIndex == index;

    return GestureDetector(
      onTap: () => provider.setSelectedIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? ColorRes.primaryColor.withValues(alpha: 0.16)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgAsset(
              imagePath: icon,
              color: isSelected ? ColorRes.primaryColor : Colors.grey[600],
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: Text(
                  label,
                  style: styleW500S12.copyWith(color: ColorRes.primaryColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
