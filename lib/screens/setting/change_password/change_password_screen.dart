import 'package:aura_real/aura_real.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  static const routeName = "change_password_screen";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<ChangePasswordProvider>(
      create: (c) => ChangePasswordProvider(),
      child: const ChangePasswordScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottomNavigationBar: Consumer<ChangePasswordProvider>(
        builder: (context, provider, child) {
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
              vertical: 10,
            ),
            child: SubmitButton(
              title: context.l10n?.changePassword ?? "Change Password",
              loading: provider.loader,
              onTap: () {
                provider.onChangePasswordTap(context);
              },
              bgColor:
                  provider.isFormValid ? ColorRes.primaryColor : ColorRes.grey3,
            ),
          );
        },
      ),
      body: Consumer<ChangePasswordProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: CustomSingleChildScroll(
              physics: AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  20.ph.spaceVertical,
                  AppBackIcon(title: context.l10n?.changePassword ?? ""),
                  37.ph.spaceVertical,
                  AppTextField(
                    controller: provider.currentPasswordController,
                    error: provider.currentPasswordError,
                    hintText:
                        context.l10n?.currentPassword ?? "Current Password",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgAsset(
                        imagePath: AssetRes.lockIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        provider.onCurrentPwdVisibilityChanged();
                      },
                      child: SvgAsset(
                        imagePath:
                            provider.isCurrentPwdVisible
                                ? AssetRes.showIcon
                                : AssetRes.hideIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    isMandatory: true,
                    textInputType: TextInputType.text,
                    obscureText: !provider.isCurrentPwdVisible,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged: (value) {
                      provider.onCurrentPasswordChanged(value, context);
                    },
                  ),
                  20.ph.spaceVertical,
                  AppTextField(
                    controller: provider.newPasswordController,
                    error: provider.newPasswordError,
                    hintText: context.l10n?.newPassword ?? "New Password",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgAsset(
                        imagePath: AssetRes.lockIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        provider.onNewPwdVisibilityChanged();
                      },
                      child: SvgAsset(
                        imagePath:
                            provider.isNewPwdVisible
                                ? AssetRes.showIcon
                                : AssetRes.hideIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    isMandatory: true,
                    textInputType: TextInputType.text,
                    obscureText: !provider.isNewPwdVisible,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged: (value) {
                      provider.onNewPasswordChanged(value, context);
                    },
                  ),
                  20.ph.spaceVertical,
                  AppTextField(
                    controller: provider.confirmPasswordController,
                    error: provider.confirmPasswordError,
                    hintText:
                        context.l10n?.confirmPassword ?? "Confirm Password",
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: SvgAsset(
                        imagePath: AssetRes.lockIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        provider.onConfirmPwdVisibilityChanged();
                      },
                      child: SvgAsset(
                        imagePath:
                            provider.isConfirmPwdVisible
                                ? AssetRes.showIcon
                                : AssetRes.hideIcon,
                        width: 18,
                        height: 18,
                      ),
                    ),
                    isMandatory: true,
                    textInputType: TextInputType.text,
                    obscureText: !provider.isConfirmPwdVisible,
                    fillColor: ColorRes.lightGrey2,
                    borderRadius: 40.pw,
                    onChanged: (value) {
                      provider.onConfirmPasswordChanged(value, context);
                    },
                  ),
                  49.ph.spaceVertical,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
