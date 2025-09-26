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
    return Consumer<ProfileProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 15.ph,
            ),
            child: SubmitButton(
              bgColor:
                  provider.isFormValid ? ColorRes.primaryColor : ColorRes.grey3,
              title: context.l10n?.update ?? "",
              loading: provider.loader, // Show loading state
              onTap: () {
                if (!provider.loader) {
                  provider.userUpdateAPI(context);
                }
              },
            ),
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

                  // Profile Image Section
                  InkWell(
                    onTap: () {
                      provider.pickImage(context);
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 164.pw,
                          height: 164.ph,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: ColorRes.primaryColor.withValues(
                                alpha: 0.3,
                              ),
                              width: 2,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedImage(
                              "${EndPoints.domain}${userData?.profile.profileImage}",
                            ),
                          ),
                        ),

                        // Edit Icon
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: ColorRes.primaryColor,
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: ColorRes.white,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: SvgAsset(
                                imagePath: AssetRes.editIcon,
                                width: 20.pw,
                                height: 20.ph,
                                color: ColorRes.white,
                              ),
                            ),
                          ),
                        ),

                        // Loading overlay for image
                        if (provider.loader)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    ColorRes.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Show selected image indicator
                  if (provider.hasNewImage) ...[
                    10.ph.spaceVertical,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "New image selected",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: provider.clearSelectedImage,
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ],

                  30.ph.spaceVertical,

                  // Full Name Field
                  AppTextField(
                    controller: provider.fullNameController,
                    hintText: context.l10n?.fullName ?? "",
                    error: provider.fullNameError,
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
                      provider.onFullNameChanged(value);
                    },
                  ),
                  20.ph.spaceVertical,

                  // Email Field
                  AppTextField(
                    controller: provider.emailController,
                    error: provider.emailError,
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
                      provider.onEmailChanged(value);
                    },
                  ),
                  20.ph.spaceVertical,

                  // Mobile Field
                  AppTextField(
                    controller: provider.mobileController,
                    error: provider.mobileError,
                    hintText: context.l10n?.mobileNumber ?? "",
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
                    textInputType: TextInputType.phone,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged: (value) {
                      provider.onMobileChanged(value);
                    },
                  ),

                  20.ph.spaceVertical,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
