import 'package:expidus/expidus.dart';

class DesktopView extends StatelessWidget {
  const DesktopView({super.key, this.child});

  final Widget? child;

  Widget build(BuildContext context) => Container(
    // TODO: use the Genesis Shell settings daemon
    color: Colors.grey[600],
    child: child,
  );
}
