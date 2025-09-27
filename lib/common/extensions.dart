import 'package:intl/intl.dart';
import 'package:aura_real/aura_real.dart';
import 'package:path/path.dart' as path;

// Corrected extension for your specific rating system
extension RatingExtension on double {
  /// Convert any rating format to star count for display
  double toStarRating() {
    // Handle both integer format (1.0, 2.0, 3.0) and decimal format (0.02, 0.04, 0.06)
    if (this >= 1.0) {
      // Integer format: 1.0 = 1 star, 2.0 = 2 stars, etc.
      return this.clamp(0.0, 5.0);
    } else {
      // Decimal format: handle cumulative ratings too
      // For cumulative ratings like 0.16 (3+5 stars), we need to show total stars
      double totalStars = (this / 0.02).clamp(0.0, 5.0);
      return totalStars > 5.0 ? 5.0 : totalStars; // Cap at 5 stars for display
    }
  }

  /// Convert star rating to raw decimal format for API
  double toRawRating() {
    // Convert star rating (1-5) to decimal format (0.02-0.10)
    switch (this.round()) {
      case 5: return 0.10;
      case 4: return 0.08;
      case 3: return 0.06;
      case 2: return 0.04;
      case 1: return 0.02;
      default: return 0.0;
    }
  }

  /// Add new rating to existing cumulative rating
  double addRating(double newStarRating) {
    double currentRating = this; // This is the existing cumulative rating
    double newRawRating = newStarRating.toRawRating(); // Convert new star rating to raw
    return currentRating + newRawRating;
  }

  /// Get display rating (for showing like "0.16/10" or average)
  String getDisplayRating() {
    return "${this.toStringAsFixed(2)}/10";
  }

  /// Get average star rating from cumulative rating
  double getAverageStars(int totalRatings) {
    if (totalRatings == 0) return 0.0;
    double totalStarValue = this / 0.02; // Convert cumulative to total star count
    return (totalStarValue / totalRatings).clamp(0.0, 5.0);
  }

  /// Convert star rating to integer format for API
  int toIntegerRating() {
    return this.round().clamp(0, 5);
  }

  /// Get integer star count directly
  int toStarCount() {
    return toStarRating().round();
  }
}
// extension RatingExtension on double {
//   /// Convert any rating format to star count for display
//   double toStarRating() {
//     // Handle both integer format (1.0, 2.0, 3.0) and decimal format (0.02, 0.04, 0.06)
//     if (this >= 1.0) {
//       // Integer format: 1.0 = 1 star, 2.0 = 2 stars, etc.
//       return this.clamp(0.0, 5.0);
//     } else {
//       // Decimal format: 0.02 = 1 star, 0.04 = 2 stars, etc.
//       if (this >= 0.10) return 5.0;
//       if (this >= 0.08) return 4.0;
//       if (this >= 0.06) return 3.0;
//       if (this >= 0.04) return 2.0;
//       if (this >= 0.02) return 1.0;
//       return 0.0;
//     }
//   }
//
//   /// Convert star rating to raw decimal format for display
//   double toRawRating() {
//     // Convert star rating (1-5) to decimal format (0.02-0.10)
//     switch (this.round()) {
//       case 5: return 0.10;
//       case 4: return 0.08;
//       case 3: return 0.06;
//       case 2: return 0.04;
//       case 1: return 0.02;
//       default: return 0.0;
//     }
//   }
//
//   /// Convert star rating to integer format for API
//   int toIntegerRating() {
//     return this.round().clamp(0, 5);
//   }
//
//   /// Get integer star count directly
//   int toStarCount() {
//     return toStarRating().round();
//   }
// }
// extension RatingExtension on double {
//   double toStarRating() {
//     // Convert raw rating (0.0–0.1) to star rating (0–5)
//     // API gives: 0.02 = 1 star, 0.04 = 2 stars, 0.06 = 3 stars, 0.08 = 4 stars, 0.1 = 5 stars
//     return (this * 50.0).clamp(0.0, 5.0);
//   }
//
//   double toRawRating() {
//     // Convert star rating (0–5) to raw rating (0.0–0.1)
//     return (this / 50.0).clamp(0.0, 0.1);
//   }
// }

extension StringPathExtension on String {
  /// Converts forward slashes (/) to backslashes (\) in a string.
  String toBackslashPath() {
    return replaceAll('\\', '/');
  }
}

extension IntExtension on int {
  SizedBox get spaceVertical => SizedBox(height: toDouble());

  SizedBox get spaceHorizontal => SizedBox(width: toDouble());
}

extension ValidationExt on String {
  bool isEmailValid() {
    return RegExp(
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\.[a-zA-Z]+$",
    ).hasMatch(this);
  }

  bool hasSpaces() {
    return contains(' ');
  }

  bool isFullNameValid() {
    return isNotEmpty && trim().length >= 3;
  }

  bool hasSpecialCharacters() {
    // Allow only letters (including Arabic, English), spaces, and common name characters
    // This regex allows: letters, spaces, hyphens, apostrophes
    final RegExp nameRegex = RegExp(
      r"^[a-zA-Z\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s\-\'\.]+$",
    );
    return !nameRegex.hasMatch(this);
  }

  bool isPhoneValid() {
    return RegExp(r"(^(?:[+0]9)?[0-9]{10,12}$)").hasMatch(this);
  }

  bool isNumeric() {
    final numericRegex = RegExp(r'^\d+$');
    return numericRegex.hasMatch(this);
  }

  /// ✅ Minimum length check
  bool hasMinLength([int minLength = 6]) {
    return length >= minLength;
  }

  /// ✅ Strong password validation
  /// Must contain: uppercase, lowercase, number, special char, min 8 length
  bool isValidPassword() {
    final hasMinLength = length >= 8;
    // final hasUppercase = contains(RegExp(r'[A-Z]'));
    final hasLowercase = contains(RegExp(r'[a-z]'));
    final hasNumber = contains(RegExp(r'[0-9]'));
    final hasSymbol = contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\[\]\\/~`+=-]'));

    return hasMinLength &&
        // hasUppercase &&
        hasLowercase &&
        hasNumber &&
        hasSymbol;
  }

  /// ✅ Confirm password check
  bool isSamePassword(String other) {
    return this == other;
  }
}

extension StringFormatingExt on String {
  Color? get toColor {
    try {
      String colorString = this;
      // Remove the '#' if it exists
      colorString = colorString.replaceFirst('#', '');

      // If it's a 6-character color, add full opacity (FF)
      if (colorString.length == 6) {
        colorString = 'FF$colorString';
      }

      // Convert hex to integer and create a Color object
      return Color(int.parse(colorString, radix: 16));
    } catch (e) {
      return null;
    }
  }

  double? get tryDouble {
    try {
      final value = double.tryParse(this);
      if (value != null && !value.isNaN) {
        return value;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  DateTime? get tryDateTimeFromUtc {
    try {
      return DateFormat("yyyy-MM-dd hh:mm:ss").tryParse(this, true);
    } catch (e) {
      return null;
    }
  }

  DateTime? get tryDate {
    try {
      return DateFormat("yyyy-MM-dd").tryParse(this);
    } catch (e) {
      return null;
    }
  }

  DateTime? get tryDateDdMmmmYyyy {
    try {
      return DateFormat("dd MMMM yyyy").tryParse(this);
    } catch (e) {
      return null;
    }
  }

  String? get getLeaveTypeLabel {
    try {
      if (toLowerCase() == "confirm") {
        return "To Approve";
      } else if (toLowerCase() == "refuse") {
        return "Refused";
      } else if (toLowerCase() == "validate1") {
        return "Second Approval";
      } else if (toLowerCase() == "validate") {
        return "Approved";
      } else if (toLowerCase() == "cancel") {
        return "Cancelled";
      }
      return "-";
    } catch (e) {
      return null;
    }
  }
}

String enumToCapitalizedString(dynamic enumValue) {
  final name = enumValue.toString().split('.').last;
  return name[0].toUpperCase() + name.substring(1);
}

String getFormattedDateTime() {
  final now = DateTime.now();
  final formatted =
      "${now.year.toString().padLeft(4, '0')}-"
      "${now.month.toString().padLeft(2, '0')}-"
      "${now.day.toString().padLeft(2, '0')} "
      "${now.hour.toString().padLeft(2, '0')}:"
      "${now.minute.toString().padLeft(2, '0')}:"
      "${now.second.toString().padLeft(2, '0')}:"
      "${now.millisecond.toString().padLeft(3, '0')}";

  return formatted;
}

extension NumFormatingExt on num {
  String? get toAmount {
    try {
      final formatter = NumberFormat('#,##,###');
      return formatter.format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toHoursTime {
    try {
      final totalMinutes = (this * 60).round();
      final h = (totalMinutes ~/ 60).toString().padLeft(2, '0');
      final m = (totalMinutes % 60).toString().padLeft(2, '0');
      return "$h:$m Hrs";
    } catch (e) {
      return null;
    }
  }
}

extension DateFormatingExt on DateTime {
  String? get toDdMmYyyy {
    try {
      return DateFormat("dd/MM/yyyy").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toDdMmmmYyyy {
    try {
      return DateFormat("dd MMMM yyyy").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toMmmDdYyyy {
    try {
      return DateFormat("MMM dd, yyyy").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toHhMmA {
    try {
      return DateFormat("hh:mm a").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toYyyyMmDd {
    try {
      return DateFormat("yyyy-MM-dd").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toYyyyMm {
    try {
      return DateFormat("yyyy-MM").format(this);
    } catch (e) {
      return null;
    }
  }

  String? get toYyyyMmDdHhMmSsUtc {
    try {
      return DateFormat("yyyy-MM-dd HH:mm:ss").format(toUtc());
    } catch (e) {
      return null;
    }
  }

  String? get toDdMmm {
    try {
      return DateFormat("dd MMM").format(this);
    } catch (e) {
      return null;
    }
  }

  double get toDecimalHours {
    return hour + (minute / 60) + (second / 3600);
  }
}

extension PowerFormatterExt on double? {
  String get toKwh => ((this ?? 0.0) / 1).toStringAsFixed(2);

  /// Converts nullable kW to MWh (based on hours = 1)
  String get toMwh => ((this ?? 0.0) / 1000).toStringAsFixed(2);
}

extension NavigatorExtention on BuildContext {
  AppLocalizations? get l10n => AppLocalizations.of(this);

  NavigatorState get navigator => Navigator.of(this);

  Object? get args => ModalRoute.of(this)?.settings.arguments;
}

extension NumUtils on num {
  Duration get milliseconds => Duration(microseconds: (this * 1000).round());

  Duration get seconds => Duration(milliseconds: (this * 1000).round());

  Duration get minutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  Duration get hours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  Duration get days => Duration(hours: (this * Duration.hoursPerDay).round());
}

extension SpaceExtention on num {
  /// Vertical Space
  Widget get spaceVertical => SizedBox(height: toDouble());

  /// Horizontal Space
  Widget get spaceHorizontal => SizedBox(width: toDouble());
}

extension ThemeExtention on int {
  /// Vertical Space
  Color get indexedColor {
    List<Color> colors = [ColorRes.primaryColor, ColorRes.red];

    return colors[this % colors.length];
  }
}

/// IterableExtension
extension IterableExtension<T> on Iterable<T> {
  /// The first element satisfying [test], or `null` if there are none.
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// DoubleExtension
extension DoubleExtension on double {
  /// prettify
  String get prettify =>
  // toStringAsFixed guarantees the specified number of fractional
  // digits, so the regular expression is simpler than it would need to
  // be for more general cases.
  toStringAsFixed(2).replaceFirst(RegExp(r'\.?0*$'), '');
}

extension FileExtension on File {
  /// prettify
  String get getFileName => path.split('/').last;

  String get getDirectoryPath {
    final pathList = path.split("/");
    return pathList.sublist(0, pathList.length - 1).join("/");
  }
}

extension DurationExt on Duration {
  /// Converts a Duration to decimal hour format
  /// Example: Duration(hours: 8, minutes: 7) => 8.11666
  double get toDecimalHours {
    return inSeconds / 3600;
  }
}
