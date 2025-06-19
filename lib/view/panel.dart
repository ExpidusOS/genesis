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

  Future<Process?> run(String component, String? initialRoute) async {
    if (subComponent != null) {
      subComponent!.kill();
      subComponent = null;
      return null;
    }

    subComponent = await runComponent(
      component: component,
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
    onAppsPressed: () {
      run('launcher', '/');
    },
    onNetworkingPressed: () {
      run('action-center', '/networking');
    },
    onClockPressed: () {
      run('action-center', '/clock');
    },
    onPowerPressed: () {
      run('action-center', '/power');
    },
  );
}
