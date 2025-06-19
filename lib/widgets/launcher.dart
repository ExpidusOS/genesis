import 'package:expidus/expidus.dart';

class Launcher extends StatelessWidget {
  const Launcher({super.key, this.onClosePressed});

  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        HeaderBar(
          showMenuButton: false,
          showActions: false,
          titleWidget: const SizedBox(),
          start: [
            Button.flat(
              isActive: false,
              onPressed: onClosePressed,
              child: Icon(Icons.arrow_left),
            ),
          ],
        ),
      ],
    ),
  );
}
