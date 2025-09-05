import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/password_reset/password_reset_screen.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  static const routeName = "sign_up";

  static Widget builder(BuildContext context) {
    Map<String, dynamic>? args;

    // Check if context.args is a Map and assign it
    if (context.args is Map<String, dynamic>) {
      args = context.args as Map<String, dynamic>;
    }
    return ChangeNotifierProvider<SignUpProvider>(
      create: (c) => SignUpProvider(args: args),
      child: const SignUpScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<SignUpProvider>(
        builder: (context, provider, child) {
          return SizedBox(
            width: 100.w,
            child: Column(
              children: [
                CustomHeader(
                  title: context.l10n?.signUp,
                  description: context.l10n?.letGetStartedByCreatingYourAccount,
                  backgroundColor: ColorRes.primaryColor,
                  centerTitle: true,
                  showBackBtn: true,
                ),
                37.ph.spaceVertical,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Constants.horizontalPadding,
                    ),
                    child: SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AppTextField(
                            controller: provider.fullNameController,
                            error: provider.fullNameError,
                            hintText: context.l10n?.fullName ?? "",
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: SvgAsset(
                                imagePath: AssetRes.profileIcon,
                                width: 18,
                                height: 18,
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
                              ),
                            ),

                            isMandatory: true,
                            textInputType: TextInputType.emailAddress,
                            fillColor: ColorRes.lightGrey2,
                            borderRadius: 40.pw,
                            onChanged: (value) {
                              provider.onEmailChanged(value);

                              // Handle text change
                            },
                          ),

                          20.ph.spaceVertical,

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
                              ),
                            ),
                            isMandatory: true,
                            textInputType: TextInputType.phone,
                            fillColor: ColorRes.lightGrey2,
                            borderRadius: 40.pw,
                            onChanged: (value) {
                              provider.onMobileChanged(value);

                              // Handle text change
                            },
                          ),

                          20.ph.spaceVertical,

                          AppTextField(
                            controller: provider.passwordController,
                            error: provider.pwdError,
                            hintText: context.l10n?.password ?? "",
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
                                provider.onPwdVisibilityChanged();
                              },
                              child: SvgAsset(
                                imagePath:
                                    !provider.isPwdVisible
                                        ? AssetRes.showIcon
                                        : AssetRes.hideIcon,
                                width: 18,
                                height: 18,
                              ),
                            ),
                            obscureText: !provider.isPwdVisible,
                            isMandatory: true,
                            textInputType: TextInputType.text,
                            fillColor: ColorRes.lightGrey2,
                            borderRadius: 40.pw,
                            onChanged: (value) {
                              provider.onPasswordChanged(value);

                              // Handle text change
                            },
                          ),

                          23.ph.spaceVertical,
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: provider.isChecked,
                                onChanged: (bool? value) {
                                  provider.toggleCheck();
                                },
                                activeColor: ColorRes.primaryColor,
                                checkColor: ColorRes.white,
                                shape: const CircleBorder(),
                                // ✅ Round shape
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                // ✅ Removes extra space
                                visualDensity:
                                    VisualDensity
                                        .compact, // ✅ Makes checkbox smaller/closer
                              ),
                              10.pw.spaceHorizontal,
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    text:
                                        context.l10n?.iAgreeToTheMedidoc ?? "",
                                    style: styleW400S16.copyWith(
                                      color: ColorRes.grey4,
                                    ),
                                    children: [
                                      TextSpan(
                                        text:
                                            " ${context.l10n?.termsOfService ?? ""} ",
                                        style: styleW400S16.copyWith(
                                          color: ColorRes.primaryColor,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/terms-of-service',
                                                );
                                              },
                                      ),
                                      TextSpan(
                                        text: " ${context.l10n?.and ?? ""} ",
                                        style: styleW400S16.copyWith(
                                          color: ColorRes.grey4,
                                        ),
                                      ),
                                      TextSpan(
                                        text: context.l10n?.privacyPolicy ?? "",
                                        style: styleW400S16.copyWith(
                                          color: ColorRes.primaryColor,
                                        ),
                                        recognizer:
                                            TapGestureRecognizer()
                                              ..onTap = () {
                                                Navigator.pushNamed(
                                                  context,
                                                  '/privacy-policy',
                                                );
                                              },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          30.ph.spaceVertical,

                          SubmitButton(
                            title: context.l10n?.signUp ?? "",
                            loading: provider.loader,
                            onTap: () {
                              provider.onSignUpTap(context);
                            },
                            bgColor:
                                provider.isFormValid
                                    ? ColorRes.primaryColor
                                    : ColorRes.grey3, // 🔹 dynamic color
                          ),
                          30.ph.spaceVertical,
                          InkWell(
                            onTap: () {
                              context.navigator.pushNamed(
                                SignInScreen.routeName,
                              );
                            },
                            child: ColumnWithRichText(
                              title: context.l10n?.alreadyHaveAnAccount ?? "",
                              value: context.l10n?.login ?? "",
                              style: styleW500S16.copyWith(
                                color: ColorRes.primaryColor,
                              ),
                            ),
                          ),
                          49.ph.spaceVertical,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
