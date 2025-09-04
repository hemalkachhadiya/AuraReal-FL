import 'package:aura_real/aura_real.dart';
import 'package:aura_real/common/methods.dart';
import 'package:aura_real/common/widgets/common_widget.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.textInputType,
    this.textInputAction,
    this.error,
    this.onChanged,
    this.onTap,
    this.maxLength,
    this.maxLine = 1,
    this.minLine = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.textCapitalization = TextCapitalization.none,
    this.showMandatoryIcon = false,
    this.readOnly = false,
    this.isMandatory = false,
    this.headerColor,
    this.onSuffixTap,
    this.isDense,
    this.header,
    this.maxWidth,
    this.borderRadius,
    this.fillColor,
    this.customBorder,
    this.customPadding,
    this.textAlign,
  });

  final String? hintText;
  final double? maxWidth;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final TextInputAction? textInputAction;
  final String? error;
  final int? maxLength;
  final int? maxLine;
  final int? minLine;
  final double? borderRadius;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextCapitalization textCapitalization;
  final bool showMandatoryIcon;
  final bool readOnly;
  final bool isMandatory;
  final Color? headerColor;
  final bool? isDense;
  final String? header;
  final Color? fillColor;
  final InputBorder? customBorder;
  final EdgeInsets? customPadding;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isArabic = localization?.localeName == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        if (header != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8.ph), // Reduced padding to match screenshot
            child: isMandatory
                ? RichText(
              text: TextSpan(
                text: '* ',
                style: TextStyle(color: Colors.red, fontSize: 14),
                children: [
                  TextSpan(
                    text: header,
                    style: styleW600S14.copyWith(
                      color: headerColor ?? ColorRes.black2,
                    ),
                  ),
                ],
              ),
            )
                : Text(
              header ?? "",
              style: styleW600S14.copyWith(
                color: headerColor ?? ColorRes.black2.withValues(alpha: 0.6),
              ),
            ),
          ),

        Container(
          decoration: BoxDecoration(
            color: Color(0xffF7F8F8), // Light gray background
            borderRadius: BorderRadius.circular(borderRadius ?? 40.ph), // Default to 40.ph
          ),
          child: TextField(
            style: styleW500S14.copyWith(color: ColorRes.black2),
            controller: controller,
            onTapOutside: (e) => hideKeyboard(context: context),
            keyboardType: textInputType,
            contextMenuBuilder: (context, editableTextState) {
              return const SizedBox.shrink(); // No context menu
            },
            textInputAction: textInputAction ?? TextInputAction.next,
            onChanged: onChanged,
            onTap: onTap,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            maxLines: obscureText ? 1 : maxLine,
            minLines: minLine ?? 1,
            obscureText: obscureText,
            obscuringCharacter: "*",
            readOnly: readOnly,
            textAlign: textAlign ??
                (isArabic ? TextAlign.right : TextAlign.left), // Dynamic text alignment
            buildCounter: (
                BuildContext context, {
                  required int currentLength,
                  required int? maxLength,
                  required bool isFocused,
                }) {
              return const SizedBox();
            },
            decoration: InputDecoration(
              hintText: hintText,
              fillColor: fillColor ?? Color(0xffF7F8F8), // Match container background
              isDense: isDense ?? true, // Match compact design
              filled: true,
              hintStyle: styleW400S14.copyWith(
                color: (error ?? '').isNotEmpty
                    ? ColorRes.red
                    : ColorRes.black.withValues(alpha: 0.3),
              ),
              contentPadding: customPadding ??
                  EdgeInsets.symmetric(horizontal: 16.pw, vertical: 12),
              // Increased padding
              border: customBorder ??
                  inputBorder(borderRadius: borderRadius ?? 40.ph), // Updated radius
              focusedBorder: (customBorder ?? inputBorder(borderRadius: borderRadius ?? 40.ph)).copyWith(
                borderSide: BorderSide(color: ColorRes.primaryColor),
              ),
              disabledBorder: customBorder ?? inputBorder(borderRadius: borderRadius ?? 40.ph),
              errorBorder: customBorder ?? inputBorder(borderRadius: borderRadius ?? 40.ph),
              focusedErrorBorder: customBorder ?? inputBorder(borderRadius: borderRadius ?? 40.ph),
              enabledBorder: customBorder ?? inputBorder(borderRadius: borderRadius ?? 40.ph),
              prefixIcon: prefixIcon,

              // prefixIcon: prefixIcon,
              suffixIconConstraints: BoxConstraints(
                maxWidth: maxWidth ?? 48,
                maxHeight: 48,
              ),
              suffixIcon: InkWell(
                onTap: onSuffixTap,
                borderRadius: BorderRadius.circular(borderRadius ?? 40.pw),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.all(8.pw),
                    child: suffixIcon,
                  ),
                ),
              ),
            ),
          ),
        ),
        ErrorText(error: error, topPadding: 4.ph),
      ],
    );
  }

  InputBorder inputBorder({double? borderRadius}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 40.ph), // Default to 40.ph
      borderSide: BorderSide(
        color: (error ?? '').isNotEmpty
            ? ColorRes.red
            : ColorRes.lightGrey2.withValues(alpha: 0.2),
      ),
    );
  }
}