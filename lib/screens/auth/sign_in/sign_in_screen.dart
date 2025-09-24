import 'package:aura_real/aura_real.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const routeName = "sign_in";

  // static Widget builder(BuildContext context) {
  //   return ChangeNotifierProvider<SignInProvider>(
  //     create: (c) => SignInProvider(args: ),
  //     child: const SignInScreen(),
  //   );
  // }
  static Widget builder(BuildContext context) {
    Map<String, dynamic>? args;

    // Check if context.args is a Map and assign it
    if (context.args is Map<String, dynamic>) {
      args = context.args as Map<String, dynamic>;
    }
    return ChangeNotifierProvider<SignInProvider>(
      create: (c) => SignInProvider(args: args),
      child: const SignInScreen(),
    );
  }


  void showForgotDialog(BuildContext context, SignInProvider provider) {
    final TextEditingController emailController = TextEditingController();
    String? emailError;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing during logout
      builder:
          (dialogContext) => AlertDialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Constants.horizontalPadding,
            ),
            title: Column(
              children: [

                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(bottom: 15),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                        },
                        borderRadius: BorderRadius.circular(50),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: ColorRes.red,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.close,
                                color: ColorRes.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                20.ph.spaceVertical,
                Text(
                  context.l10n?.forgotYourPassword ?? "Forgot Your Password",
                  style: styleW700S20,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            content: SizedBox(
              // Constrain the height to prevent overflow
              height: 150.ph, // Adjust based on your design
              child: SingleChildScrollView(
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        20.ph.spaceVertical,
                        AppTextField(
                          controller: emailController,
                          error: emailError,
                          hintText:
                              context.l10n?.emailAddress ?? "Email Address",
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(18.0),
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
                            setState(() {
                              // Basic email validation
                              if (value.isEmpty) {
                                emailError =
                                    context.l10n?.emailIsRequired ??
                                    "Email is required";
                              } else if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                emailError =
                                    context.l10n?.invalidEmail ??
                                    "Invalid email format";
                              } else {
                                emailError = null;
                              }
                            });
                          },
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            actions: [
              Center(
                child: Container(
                  width: 225.pw,
                  padding: EdgeInsets.only(top: 15.ph),
                  child: SubmitButton(
                    height: 45.ph,
                    loading: provider.loader,
                    title: context.l10n?.reset ?? "Reset",
                    raduis: 15,
                    onTap:
                        provider.loader
                            ? null
                            : () async {
                              final email = emailController.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n?.emailIsRequired ??
                                          "Email is required",
                                    ),
                                  ),
                                );
                                return;
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(email)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n?.invalidEmail ??
                                          "Invalid email format",
                                    ),
                                  ),
                                );
                                return;
                              }
                              await provider.reqPasswordReset(context, email);
                            },
                    style: styleW600S12.copyWith(color: ColorRes.white),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<SignInProvider>(
        builder: (context, provider, child) {
          return SizedBox(
            width: 100.w,
            child: Directionality(
              textDirection:
                  AppLocalizations.of(context)?.localeName == 'ar'
                      ? TextDirection.rtl
                      : TextDirection.ltr,
              child: Column(
                children: [
                  CustomHeader(
                    title: AppLocalizations.of(context)?.login ?? "Login",
                    description:
                        AppLocalizations.of(
                          context,
                        )?.enterYourEmailAndPassword ??
                        "Enter your email and password",
                    backgroundColor: ColorRes.primaryColor,
                    centerTitle: true,
                  ),
                  37.ph.spaceVertical,
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Constants.horizontalPadding,
                      ),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            AppTextField(
                              controller: provider.emailController,
                              error: provider.emailError,
                              hintText:
                                  AppLocalizations.of(context)?.emailAddress ??
                                  "Email Address",
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(18.0),
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
                                provider.onEmailChanged(value,);
                              },
                            ),
                            20.ph.spaceVertical,
                            AppTextField(
                              controller: provider.passwordController,
                              error: provider.pwdError,
                              hintText:
                                  AppLocalizations.of(context)?.password ??
                                  "Password",
                              prefixIcon: const Padding(
                                padding: EdgeInsets.all(18.0),
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
                                      provider.isPwdVisible
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
                                provider.onEmailChanged(value,);
                              },
                            ),
                            14.ph.spaceVertical,
                            InkWell(
                              onTap: () {
                                showForgotDialog(context, provider);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  AppLocalizations.of(
                                        context,
                                      )?.forgotYourPassword ??
                                      "Forgot your password?",
                                  style: styleW500S12.copyWith(
                                    color: ColorRes.primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            22.ph.spaceVertical,
                            SubmitButton(
                              title:
                                  AppLocalizations.of(context)?.login ??
                                  "Login",
                              loading: provider.loader,
                              bgColor:
                                  provider.isFormValid
                                      ? ColorRes.primaryColor
                                      : ColorRes.grey3,
                              onTap: () {
                                provider.onLoginTap(context);
                              },
                            ),
                            30.ph.spaceVertical,
                            InkWell(
                              onTap: () {
                                context.navigator.pushNamed(
                                  SignUpScreen.routeName,
                                );
                              },
                              child: ColumnWithRichText(
                                title:
                                    AppLocalizations.of(
                                      context,
                                    )?.doNotHaveAnAccount ??
                                    "Don't have an account?",
                                value:
                                    AppLocalizations.of(context)?.signUp ??
                                    "Sign Up",
                                style: styleW500S16.copyWith(
                                  color: ColorRes.primaryColor,
                                ),
                              ),
                            ),
                            49.ph.spaceVertical,
                            Text(
                              AppLocalizations.of(context)?.or ?? "OR",
                              style: styleW500S16,
                            ),
                            40.ph.spaceVertical,
                            // provider.loaderGoogleLogin
                            //     ? const CircularProgressIndicator()
                            //     : InkWell(
                            //       borderRadius: BorderRadius.circular(8),
                            //       onTap: () {
                            //         provider.googleSignIn(context);
                            //       },
                            //       child: Padding(
                            //         padding: const EdgeInsets.all(8.0),
                            //         child: Row(
                            //           mainAxisAlignment:
                            //               MainAxisAlignment.center,
                            //           crossAxisAlignment:
                            //               CrossAxisAlignment.center,
                            //           children: [
                            //             const SvgAsset(
                            //               imagePath: AssetRes.googleIcon,
                            //             ),
                            //             15.pw.spaceHorizontal,
                            //             Text(
                            //               AppLocalizations.of(
                            //                     context,
                            //                   )?.signInWithGoogle ??
                            //                   "Sign In with Google",
                            //               style: styleW600S18,
                            //             ),
                            //           ],
                            //         ),
                            //       ),
                            //     ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
