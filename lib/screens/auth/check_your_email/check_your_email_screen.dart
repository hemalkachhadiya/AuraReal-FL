import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/widgets/common_widget.dart';

class CheckYourEmailScreen extends StatelessWidget {
  const CheckYourEmailScreen({super.key});

  static const routeName = "check_your_email";

  static Widget builder(BuildContext context) {
    Map<String, dynamic>? args;
    if (context.args is Map<String, dynamic>) {
      args = context.args as Map<String, dynamic>;
    }
    return ChangeNotifierProvider<CheckYourMailProvider>(
      create:
          (c) => CheckYourMailProvider(
            email: args?['email'] ?? "",
            isComeFromSignUp: args?['isComeFromSignUp'],
            isReset: args?["isReset"],
            otpType: args?["otp_type"],
            phoneNumber: args?["phoneNumber"],
          ),
      child: const CheckYourEmailScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CheckYourMailProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: ColorRes.white,
          bottomNavigationBar:
          /// Submit Button
          Padding(
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
                    provider.loader ? ColorRes.primaryColor : ColorRes.grey3,

                onTap:
                    provider.loader
                        ? null
                        : () => provider.onVerifyOTPTap(context),
                title: context.l10n?.submit ?? "",
              ),
            ),
          ),

          body: SafeArea(
            child: CustomSingleChildScroll(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  8.ph.spaceVertical,
                  const AppBackIcon(),
                  25.ph.spaceVertical,

                  /// Title
                  Center(
                    child: Text(
                      (provider.otpType != null && provider.otpType == "1")
                          ? context.l10n?.checkYourPhone ?? "Check your phone"
                          : context.l10n?.checkYourMail ?? "Check your mail",
                      style: styleW700S24,
                    ),
                  ),
                  10.ph.spaceVertical,

                  /// Subtitle
                  Center(
                    child: Text(
                      (provider.otpType != null && provider.otpType == "1")
                          ? context.l10n?.pleasePutThe4DigitSentToYou ??
                              "Please put the 4 digits sent to you"
                          : context.l10n?.pleasePutThe4DigitSentToYou ??
                              "Please put the 6 digits sent to you",
                      style: styleW400S14.copyWith(color: ColorRes.grey6),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  37.ph.spaceVertical,

                  /// Pinput
                  Center(
                    child: Pinput(
                      length: provider.otpType == "1" ? 4 : 6,
                      onChanged: (val) => provider.setOtp(context, val),
                      errorText: provider.otpError,
                      defaultPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: styleW600S16.copyWith(color: ColorRes.black),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorRes.grey5),
                          // default border
                          color: ColorRes.lightGrey3, // default background
                        ),
                      ),

                      // When selected (focused)
                      focusedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: styleW600S16.copyWith(color: ColorRes.black),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorRes.primaryColor,
                            width: 2,
                          ),
                          color: ColorRes.white,
                        ),
                      ),

                      // When already filled
                      submittedPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: styleW600S16.copyWith(color: ColorRes.black),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColorRes.primaryColor),
                          color: ColorRes.primaryColor.withOpacity(0.1),
                        ),
                      ),

                      // When error
                      errorPinTheme: PinTheme(
                        width: 56,
                        height: 56,
                        textStyle: styleW600S16.copyWith(color: Colors.red),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red),
                          color: Colors.red.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ),

                  ErrorText(error: provider.otpError, topPadding: 5.ph),
                  87.ph.spaceVertical,

                  /// Illustration
                  Center(
                    child: SizedBox(
                      height: 260,
                      child: AssetsImg(imagePath: AssetRes.checkMailImg),
                    ),
                  ),
                  139.ph.spaceVertical,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
