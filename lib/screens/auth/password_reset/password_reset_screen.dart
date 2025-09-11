import 'package:aura_real/aura_real.dart';

class PasswordRestScreen extends StatelessWidget {
  const PasswordRestScreen({super.key});

  static const routeName = "password_rest_screen";

  static Widget builder(BuildContext context) {
    final args =
        context.args is Map<String, dynamic>
            ? context.args as Map<String, dynamic>
            : {'isComeFromSignUp': false};
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PasswordResetProvider>(
          create:
              (c) => PasswordResetProvider(
                isComeFromSignUp: args['isComeFromSignUp'] as bool? ?? false,
                args['email'] as String?,
                args['fullName'] as String?,
                args['phoneNumber'] as String?,
                args['password'] as String?,
              ),
        ),
        ChangeNotifierProvider<SignUpProvider>(
          create: (c) => SignUpProvider(args: args),
        ),
      ],
      child: const PasswordRestScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PasswordResetProvider>.value(
          value: Provider.of<PasswordResetProvider>(context, listen: false),
        ),
        ChangeNotifierProvider<SignUpProvider>.value(
          value: Provider.of<SignUpProvider>(context, listen: false),
        ),
      ],
      child: Consumer2<PasswordResetProvider, SignUpProvider>(
        builder: (context, provider, signUpProvider, child) {
          // Get email and phone number from provider
          final displayEmail =
              provider.email?.isNotEmpty == true
                  ? provider.email!
                  : 'john****@gmail.com';
          final displayPhone =
              provider.phoneNumber?.isNotEmpty == true
                  ? provider.phoneNumber!
                  : '+91 98XXXXXXXX';
          return Scaffold(
            backgroundColor: ColorRes.white,
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Constants.horizontalPadding,
                vertical: 20,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: SubmitButton(
                  loading: provider.loader,
                  bgColor:
                      provider.selectedMethod != null
                          ? ColorRes.primaryColor
                          : ColorRes.grey3,
                  onTap:
                      provider.selectedMethod != null
                          ? provider.isComeFromSignUp
                              ? () => provider.signUpAPI(context)
                              : () => provider.onSendTap(context)
                          : null,

                  title: context.l10n?.send ?? "",
                ),
              ),
            ),

            body: SafeArea(
              child: CustomSingleChildScroll(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    8.ph.spaceVertical,

                    AppBackIcon(),

                    25.ph.spaceVertical,

                    // Title
                    Center(
                      child: Text(
                        provider.isComeFromSignUp
                            ? context.l10n?.sendOTP ?? ""
                            : context.l10n?.passwordReset ?? "",
                        style: styleW700S24,
                      ),
                    ),

                    10.ph.spaceVertical,

                    // Subtitle
                    Center(
                      child: Text(
                        provider.isComeFromSignUp
                            ? context.l10n?.pleasePutYourMobileNumberToVerify ??
                                ""
                            : context.l10n?.pleasePutYourMobileNumberToReset ??
                                "",
                        style: styleW400S14.copyWith(color: ColorRes.grey6),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    37.ph.spaceVertical,
                    // SMS Option
                    InkWell(
                      onTap: () => provider.selectResetMethod('SMS'),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                provider.selectedMethod == 'SMS'
                                    ? ColorRes.primaryColor
                                    : ColorRes.grey3,
                            width: provider.selectedMethod == 'SMS' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              provider.selectedMethod == 'SMS'
                                  ? ColorRes.primaryColor.withValues(
                                    alpha: 0.05,
                                  )
                                  : ColorRes.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: ColorRes.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.sms,
                                color: ColorRes.white,
                                size: 24,
                              ),
                            ),

                            30.pw.spaceHorizontal,

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n?.sms ?? "",
                                    style: styleW600S16.copyWith(
                                      color: ColorRes.black,
                                    ),
                                  ),
                                  10.ph.spaceVertical,

                                  Text(
                                    displayPhone,
                                    style: styleW400S14.copyWith(
                                      color: ColorRes.grey4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (provider.selectedMethod == 'SMS')
                              Icon(
                                Icons.check_circle,
                                color: ColorRes.primaryColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),

                    20.ph.spaceVertical,

                    // Email Option
                    InkWell(
                      onTap: () => provider.selectResetMethod('Email'),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                provider.selectedMethod == 'Email'
                                    ? ColorRes.primaryColor
                                    : ColorRes.grey3,
                            width: provider.selectedMethod == 'Email' ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          color:
                              provider.selectedMethod == 'Email'
                                  ? ColorRes.primaryColor.withValues(
                                    alpha: 0.05,
                                  )
                                  : ColorRes.white,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: ColorRes.primaryColor,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Icon(
                                Icons.email,
                                color: ColorRes.white,
                                size: 24,
                              ),
                            ),

                            30.pw.spaceHorizontal,

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n?.email ?? "",
                                    style: styleW600S16.copyWith(
                                      color: ColorRes.black,
                                    ),
                                  ),
                                  10.ph.spaceVertical,
                                  Text(
                                    displayEmail,
                                    style: styleW400S14.copyWith(
                                      color: ColorRes.grey4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            if (provider.selectedMethod == 'Email')
                              Icon(
                                Icons.check_circle,
                                color: ColorRes.primaryColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Illustration
                    Center(
                      child: SizedBox(
                        height: 260,
                        child: AssetsImg(imagePath: AssetRes.resetImg),
                      ),
                    ),

                    // Send Button
                    32.ph.spaceVertical,
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
