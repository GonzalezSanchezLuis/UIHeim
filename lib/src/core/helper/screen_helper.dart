import 'package:screen_brightness/screen_brightness.dart';

class ScreenHelper {
  static double? _originalBrightness;

  static Future<void> enableTravelMode({double reducedBrightness = 0.3}) async {
    try {
      if (_originalBrightness != null) {
        _originalBrightness = await ScreenBrightness().current;
      }

      await ScreenBrightness().setScreenBrightness(reducedBrightness);
    } catch (e) {
      print("Error activando modo viaje");
    }
  }

  static Future<void> disableTravelMode() async {
    try {
      if (_originalBrightness != null) {
        await ScreenBrightness().setScreenBrightness(_originalBrightness!);
        _originalBrightness = null;
      }
    } catch (e) {
      print("Error estaurando brilo $e");
    }
  }
}
