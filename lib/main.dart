import 'package:expidus/expidus.dart';
import 'views/panel.dart';

void main() {
  runApp(const ExpidusAppConfig(
    const GenesisShell(),
    windowSize: const Size(0, 50),
    windowLayer: const ExpidusWindowLayerConfig(
      autoExclusiveZone: true,
      fixedSize: true,
      top: ExpidusWindowLayerAnchor(toEdge: true, margin: 10),
      left: ExpidusWindowLayerAnchor(toEdge: true, margin: 10),
      right: ExpidusWindowLayerAnchor(toEdge: true, margin: 10),
    ),
  ));
}

class GenesisShell extends StatelessWidget {
  const GenesisShell({super.key});

  @override
  Widget build(BuildContext context) {
    return ExpidusApp(
      title: 'Genesis Shell',
      home: const PanelView(),
    );
  }
}
