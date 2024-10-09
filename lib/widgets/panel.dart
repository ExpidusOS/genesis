import 'package:expidus/expidus.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    this.padding = const EdgeInsets.all(5.0),
    this.hasDrawer = false,
    this.onDrawerToggle,
    this.onEndDrawerToggle,
  });

  final EdgeInsetsGeometry padding;
  final bool hasDrawer;
  final VoidCallback? onDrawerToggle;
  final VoidCallback? onEndDrawerToggle;

  @override
  Widget build(BuildContext context) => Padding(
        padding: padding,
        child: HeaderBar(
          showActions: false,
          hasDrawer: hasDrawer,
          onDrawerToggle: onDrawerToggle,
          titleWidget: const SizedBox(),
          end: [
            Button.flat(
              child: Row(
                children: [
                  const DigitalClock.periodic(),
                ],
              ),
              onPressed: onEndDrawerToggle,
            ),
          ],
        ),
      );
}
