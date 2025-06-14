import 'package:expidus/expidus.dart';
import '../widgets/desktop.dart';

class GenesisShellDesktopView extends StatelessWidget {
  const GenesisShellDesktopView({super.key});

  Widget build(BuildContext context) => const DesktopView();

  static ExpidusWindowLayerConfig? getLayerConfig({String? monitor}) =>
      ExpidusWindowLayerConfig(
        layer: ExpidusWindowLayer.background,
        monitor: monitor,
        fixedSize: true,
        top: ExpidusWindowLayerAnchor(toEdge: true),
        bottom: ExpidusWindowLayerAnchor(toEdge: true),
        left: ExpidusWindowLayerAnchor(toEdge: true),
        right: ExpidusWindowLayerAnchor(toEdge: true),
      );
}
