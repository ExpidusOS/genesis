import 'package:expidus/expidus.dart';

enum Breakpoint {
  mobile(maxWidth: 640),
  tablet(minWidth: 641, maxWidth: 1007),
  desktop(minWidth: 1008);

  const Breakpoint({this.minWidth = null, this.maxWidth = null});

  final double? minWidth;
  final double? maxWidth;

  static Breakpoint of(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    for (final val in values) {
      if (val.minWidth != null) {
        if (size.width < val.minWidth!) continue;
      }

      if (val.maxWidth != null) {
        if (size.width > val.maxWidth!) continue;
      }

      return val;
    }

    return Breakpoint.mobile;
  }
}
