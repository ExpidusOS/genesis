import 'package:libtokyo_flutter/libtokyo.dart';

class AppLauncher extends StatelessWidget {
  const AppLauncher({ super.key });

  @override
  Widget build(BuildContext context) {
    final coloredTextTheme = Theme.of(context).colorScheme.brightness == Brightness.dark
      ? Theme.of(context).typography.white
      : Theme.of(context).typography.black;
    return ConstrainedBox(
      constraints: BoxConstraints.expand(width: MediaQuery.sizeOf(context).width),
      child: Center(
        child: Container(
          width: 800,
          height: 900,
          child: Card(),
        ),
      ),
    );
  }
}
