import 'package:expidus/expidus.dart';
import 'package:flutter/services.dart';
import '../widgets/action_center.dart';

class GenesisShellActionCenterView extends StatelessWidget {
  const GenesisShellActionCenterView({super.key});

  Widget build(BuildContext context) =>
      ActionCenter(onClosePressed: () => SystemNavigator.pop());

  static Size? getWindowSize() => const Size(360, 0);

  static ExpidusWindowLayerConfig? getLayerConfig({String? monitor}) =>
      ExpidusWindowLayerConfig(
        monitor: monitor,
        fixedSize: true,
        top: ExpidusWindowLayerAnchor(toEdge: true, margin: 8),
        bottom: ExpidusWindowLayerAnchor(toEdge: true, margin: 8),
        right: ExpidusWindowLayerAnchor(toEdge: true, margin: 8),
      );
}
