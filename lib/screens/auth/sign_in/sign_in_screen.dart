import 'package:aura_real/aura_real.dart';
import 'package:aura_real/screens/auth/password_reset/password_reset_screen.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  static const routeName = "sign_in";

  static Widget builder(BuildContext context) {
    return ChangeNotifierProvider<SignInProvider>(
      create: (c) => SignInProvider(),
      child: const SignInScreen(),
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
                                provider.onEmailChanged(value, context);
                              },
                            ),
                            20.ph.spaceVertical,
                            AppTextField(
                              controller: provider.passwordController,
                              error: provider.pwdError,
                              hintText:
                                  AppLocalizations.of(context)?.password ??
                                  "Password",
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
                                provider.onEmailChanged(value, context);
                              },
                            ),
                            14.ph.spaceVertical,
                            InkWell(
                              onTap: () {

                                context.navigator.pushNamed(
                                  PasswordRestScreen.routeName,
                                  arguments: {"isComeFromSignUp": false},
                                );
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
                            InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgAsset(imagePath: AssetRes.googleIcon),
                                    15.pw.spaceHorizontal,
                                    Text(
                                      AppLocalizations.of(
                                            context,
                                          )?.signInWithGoogle ??
                                          "Sign In with Google",
                                      style: styleW600S18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
