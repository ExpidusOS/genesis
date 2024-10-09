import 'dart:math' as math;
import 'package:expidus/expidus.dart';

class Backdrop extends StatelessWidget {
  const Backdrop({super.key});

  @override
  Widget build(BuildContext context) => Container(
        color: Theme.of(context).colorScheme.secondary,
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: const SizedBox(),
      );
}
