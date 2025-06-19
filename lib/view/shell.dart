import 'package:expidus/expidus.dart';
import '../widgets/action_center.dart';
import '../widgets/desktop.dart';
import '../widgets/launcher.dart';
import '../widgets/panel.dart';

class GenesisShellView extends StatelessWidget {
  const GenesisShellView({super.key});

  Future<void> showLauncher(BuildContext context) => showDialog(
    context: context,
    builder: (context) => Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(
        width: 360,
        child: Launcher(onClosePressed: () => Navigator.pop(context)),
      ),
    ),
  );

  Future<void> showActionCenter(BuildContext context) => showDialog(
    context: context,
    builder: (context) => Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 360,
        child: ActionCenter(onClosePressed: () => Navigator.pop(context)),
      ),
    ),
  );

  Widget build(BuildContext context) => DesktopView(
    child: Column(
      children: [
        Panel(
          onAppsPressed: () {
            showLauncher(context);
          },
          onNetworkingPressed: () {
            showActionCenter(context);
          },
          onClockPressed: () {
            showActionCenter(context);
          },
          onPowerPressed: () {
            showActionCenter(context);
          },
        ),
        const Spacer(),
      ],
    ),
  );
}
