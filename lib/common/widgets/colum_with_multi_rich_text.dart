import 'package:aura_real/aura_real.dart';

class ClickableSpan {
  final String text;
  final VoidCallback? onTap;
  final TextStyle? style;

  const ClickableSpan({
    required this.text,
    this.onTap,
    this.style,
  });
}

class ColumnWithRichText2 extends StatelessWidget {
  final String title;
  final String value;
  final TextStyle? style;
  final List<ClickableSpan>? clickableSpans;
  final bool highlightNumbers;

  const ColumnWithRichText2({
    super.key,
    required this.title,
    required this.value,
    this.style,
    this.clickableSpans,
    this.highlightNumbers = true,
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

        /// Value Text with clickable spans
        Flexible(
          child: RichText(
            text: TextSpan(
              children: _getStyledTextSpans(value),
              style: style ?? styleW400S16.copyWith(
                color: ColorRes.black.withValues(alpha: 0.7),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<TextSpan> _getStyledTextSpans(String text) {
    final List<TextSpan> spans = [];

    // If no clickable spans provided, use the original number highlighting logic
    if (clickableSpans == null || clickableSpans!.isEmpty) {
      return _getNumberHighlightedSpans(text);
    }

    int currentIndex = 0;

    // Sort clickable spans by their position in the text
    List<ClickableSpan> sortedSpans = List.from(clickableSpans!);
    sortedSpans.sort((a, b) {
      int indexA = text.toLowerCase().indexOf(a.text.toLowerCase());
      int indexB = text.toLowerCase().indexOf(b.text.toLowerCase());
      return indexA.compareTo(indexB);
    });

    for (ClickableSpan clickableSpan in sortedSpans) {
      // Find the position of this clickable text (case insensitive)
      int spanStart = text.toLowerCase().indexOf(
          clickableSpan.text.toLowerCase(),
          currentIndex
      );

      if (spanStart == -1) continue; // Skip if not found

      int spanEnd = spanStart + clickableSpan.text.length;

      // Add normal text before clickable span
      if (spanStart > currentIndex) {
        String normalText = text.substring(currentIndex, spanStart);
        spans.addAll(_getNumberHighlightedSpans(normalText));
      }

      // Add clickable span
      spans.add(
        TextSpan(
          text: text.substring(spanStart, spanEnd),
          style: clickableSpan.style ?? _getClickableStyle(),
          recognizer: TapGestureRecognizer()..onTap = clickableSpan.onTap,
        ),
      );

      currentIndex = spanEnd;
    }

    // Add remaining text after last clickable span
    if (currentIndex < text.length) {
      String remainingText = text.substring(currentIndex);
      spans.addAll(_getNumberHighlightedSpans(remainingText));
    }

    return spans;
  }

  List<TextSpan> _getNumberHighlightedSpans(String text) {
    if (!highlightNumbers) {
      return [
        TextSpan(
          text: text,
          style: style ?? styleW400S16.copyWith(
            color: ColorRes.black.withValues(alpha: 0.7),
          ),
        )
      ];
    }

    final List<TextSpan> spans = [];
    final regExp = RegExp(r'\d+(\.\d+)?');
    int start = 0;

    for (final match in regExp.allMatches(text)) {
      // Add normal text before the number
      if (match.start > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, match.start),
            style: style ?? styleW400S16.copyWith(
              color: ColorRes.black.withValues(alpha: 0.7),
            ),
          ),
        );
      }

      // Add the number part in bold
      spans.add(
        TextSpan(
          text: match.group(0),
          style: style ?? styleW600S16,
        ),
      );

      start = match.end;
    }

    // Add any remaining normal text after last number
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: style ?? styleW400S16.copyWith(
            color: ColorRes.black.withValues(alpha: 0.7),
          ),
        ),
      );
    }

    return spans;
  }

  TextStyle _getClickableStyle() {
    return (style ?? styleW500S16).copyWith(
      color: ColorRes.primaryColor, // or your app's primary color
      decoration: TextDecoration.underline,
      decorationColor: ColorRes.primaryColor,
    );
  }
}