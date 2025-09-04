import 'package:aura_real/aura_real.dart';

class CreateNewPasswordScreen extends StatelessWidget {
  const CreateNewPasswordScreen({super.key});

  static const routeName = "create_new_password";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<CreateNewPasswordProvider>(
      create: (c) => CreateNewPasswordProvider(),
      child: const CreateNewPasswordScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateNewPasswordProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          bottomNavigationBar: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 10.ph,
            ),
            child: SubmitButton(
              loading: provider.loader,
              title: context.l10n?.save ?? "",
              onTap: provider.loader ? null : () => provider.onSaveTap(context),
            ),
          ),
          body: SafeArea(
            child: CustomSingleChildScroll(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
              ),
              child: Column(
                children: [
                  8.ph.spaceVertical,
                  AppBackIcon(),
                  25.ph.spaceVertical,
                  Text(
                    context.l10n?.createNewPassword ?? "",
                    style: styleW700S24,
                  ),
                  10.ph.spaceVertical,
                  Text(
                    context
                            .l10n
                            ?.yourNewPasswordMustBeDifferentFromPreviousUsedPassword ??
                        "",
                    style: styleW400S16.copyWith(color: ColorRes.grey6),
                    textAlign: TextAlign.center,
                  ),
                  40.ph.spaceVertical,

                  // New Password
                  AppTextField(
                    hintText: context.l10n?.newPassword ?? "",
                    controller: provider.newPasseController,
                    error: provider.newPasswordError,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgAsset(
                        imagePath: AssetRes.lockIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: SvgAsset(
                      imagePath:
                          provider.isNewPasswordVisible
                              ? AssetRes.hideIcon
                              : AssetRes.showIcon,
                      width: 18,
                      height: 18,
                    ),
                    onSuffixTap: provider.toggleNewPasswordVisibility,
                    isMandatory: true,
                    textInputType: TextInputType.text,
                    obscureText: provider.isNewPasswordVisible,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged: (val) => provider.setNewPassword(context, val),
                  ),
                  20.ph.spaceVertical,

                  // Confirm Password
                  AppTextField(
                    controller: provider.confirmPassController,
                    error: provider.confirmPasswordError,
                    hintText: context.l10n?.confirmPassword ?? "",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgAsset(
                        imagePath: AssetRes.lockIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: SvgAsset(
                      imagePath:
                          provider.isConfirmPasswordVisible
                              ? AssetRes.hideIcon
                              : AssetRes.showIcon,
                      width: 18,
                      height: 18,
                    ),
                    onSuffixTap: provider.toggleConfirmPasswordVisibility,
                    isMandatory: true,
                    textInputType: TextInputType.text,
                    obscureText: provider.isConfirmPasswordVisible,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged:
                        (val) => provider.setConfirmPassword(context, val),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
