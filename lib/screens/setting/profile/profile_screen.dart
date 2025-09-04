import 'package:aura_real/aura_real.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const routeName = "profile_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<ProfileProvider>(
      create: (c) => ProfileProvider(),
      child: const ProfileScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Constants.horizontalPadding,
          vertical: 15.ph,
        ),
        child: SubmitButton(title: context.l10n?.update ?? "", onTap: () {}),
      ),
      body: SafeArea(
        child: CustomSingleChildScroll(
          padding: EdgeInsets.symmetric(
            horizontal: Constants.horizontalPadding,
          ),
          child: Column(
            children: [
              20.ph.spaceVertical,
              AppBackIcon(title: context.l10n?.profile ?? ""),
              86.ph.spaceVertical,
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(100),

                    child: AssetsImg(
                      imagePath: AssetRes.notificationUserImg,
                      width: 164.pw,
                      height: 164.ph,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 43,
                      height: 43,
                      decoration: BoxDecoration(
                        color: ColorRes.primaryColor,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: ColorRes.white, width: 2),
                      ),
                      child: Center(
                        child: SvgAsset(
                          imagePath: AssetRes.editIcon,
                          width: 20.pw,
                          height: 20.ph,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              30.ph.spaceVertical,
              AppTextField(
                controller: TextEditingController(text: "Brandon Carder"),
                // error: provider.fullNameError,
                hintText: context.l10n?.fullName ?? "",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SvgAsset(
                    imagePath: AssetRes.profileIcon,
                    width: 18,
                    height: 18,
                    color: ColorRes.primaryColor,
                  ),
                ),
                isMandatory: true,
                textInputType: TextInputType.name,
                fillColor: ColorRes.lightGrey2,
                borderRadius: 40.pw,
                onChanged: (value) {
                  // provider.onFullNameChanged(value, context);
                },
              ),
              20.ph.spaceVertical,

              AppTextField(
                controller: TextEditingController(
                  text: "BrandonCarder@gmail.com",
                ),

                // error: provider.emailError,
                hintText: context.l10n?.emailAddress ?? "",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SvgAsset(
                    imagePath: AssetRes.messageIcon,
                    width: 18,
                    height: 18,
                    color: ColorRes.primaryColor,
                  ),
                ),

                isMandatory: true,
                textInputType: TextInputType.emailAddress,
                fillColor: ColorRes.lightGrey2,
                borderRadius: 40.pw,
                onChanged: (value) {
                  // provider.onEmailChanged(value, context);

                  // Handle text change
                },
              ),
              20.ph.spaceVertical,

              AppTextField(
                controller: TextEditingController(text: "789541263"),

                // error: provider.emailError,
                hintText: context.l10n?.emailAddress ?? "",
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: SvgAsset(
                    imagePath: AssetRes.mobileIcon,
                    width: 18,
                    height: 18,
                    color: ColorRes.primaryColor,
                  ),
                ),

                isMandatory: true,
                textInputType: TextInputType.emailAddress,
                fillColor: ColorRes.lightGrey2,
                borderRadius: 40.pw,
                onChanged: (value) {
                  // provider.onEmailChanged(value, context);

                  // Handle text change
                },
              ),

              20.ph.spaceVertical,
            ],
          ),
        ),
      ),
    );
  }
}
