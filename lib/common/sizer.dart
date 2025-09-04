import 'package:aura_real/aura_real.dart';
import 'package:aura_real/constants/constants.dart';

extension SizerExt on num {
  /// Calculates the height depending on the device's screen size
  ///
  /// Eg: 20.h -> will take 20% of the screen's height
  double get h => this * Constants.deviceHeight / 100;

  /// Calculates the width depending on the device's screen size
  ///
  /// Eg: 20.w -> will take 20% of the screen's width
  double get w => this * Constants.deviceWidth / 100;

  /// Calculates the sp (Scalable Pixel) depending on the device's screen size
  double get ph => (this * Constants.deviceHeight) / Constants.figmaPageHeight;

  double get pw => (this * Constants.deviceWidth) / Constants.figmaPageWidth;
}
