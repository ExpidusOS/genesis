import 'dart:io';
import 'package:expidus/expidus.dart';
import '../logic/runner.dart';
import '../widgets/panel.dart';

class GenesisShellPanelView extends StatefulWidget {
  const GenesisShellPanelView({super.key, this.monitor});

  final String? monitor;

  @override
  State<GenesisShellPanelView> createState() => _GenesisShellPanelViewState();

  static Size? getWindowSize() => const Size(0, 60);

  static ExpidusWindowLayerConfig? getLayerConfig({String? monitor}) =>
      ExpidusWindowLayerConfig(
        monitor: monitor,
        fixedSize: true,
        exclusiveZone: 60,
        top: ExpidusWindowLayerAnchor(toEdge: true),
        left: ExpidusWindowLayerAnchor(toEdge: true),
        right: ExpidusWindowLayerAnchor(toEdge: true),
      );
}

class _GenesisShellPanelViewState extends State<GenesisShellPanelView> {
  Process? subComponent;

  Future<Process?> run(String? initialRoute) async {
    if (subComponent != null) {
      subComponent!.kill();
      subComponent = null;
      return null;
    }

    subComponent = await runComponent(
      component: 'action-center',
      monitor: widget.monitor,
      initialRoute: initialRoute,
    );
    subComponent!.exitCode.then((e) {
      setState(() {
        subComponent = null;
      });
    });
    return subComponent;
  }

  Widget build(BuildContext context) => Panel(
    onNetworkingPressed: () {
      run('/networking');
    },
    onClockPressed: () {
      run('/clock');
    },
    onPowerPressed: () {
      run('/power');
    },
  );
}
