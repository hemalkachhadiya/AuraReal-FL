import 'package:aura_real/aura_real.dart';

class ColumnWithRichText extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle? style;

  const ColumnWithRichText({
    super.key,
    required this.title,
    required this.value,  this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// Title Text
        Text(
          title,
          style: styleW500S16.copyWith(
            color: ColorRes.black.withValues(alpha: 0.6),
          ),
        ),

        /// Space
        4.ph.spaceHorizontal,

        /// Value Text
        RichText(
          text: TextSpan(
            children: _getStyledTextSpans(value),
            style: style??styleW600S16, // default style for normal text
          ),
        ),
      ],
    );
  }


  List<TextSpan> _getStyledTextSpans(String text) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(
      r'\d+(\.\d+)?',
    ); // matches integers or doubles like 123 or 45.67

    int start = 0;

    for (final match in regExp.allMatches(text)) {
      // Add normal text before the number
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: style??styleW400S16.copyWith(
              color: ColorRes.black.withValues(alpha: 0.7),
            ), // normal style
          ),
        );
      }

      // Add the number part in bold
      spans.add(
        TextSpan(
          text: match.group(0),
          style:style?? styleW600S16, // bold style
        ),
      );

      start = match.end;
    }

    // Add any remaining normal text after last number
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start), style:style?? styleW400S16));
    }

    return spans;
  }
}
