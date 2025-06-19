import 'package:expidus/expidus.dart';
import 'package:flutter/services.dart';
import '../widgets/launcher.dart';

class GenesisShellLauncherView extends StatelessWidget {
  const GenesisShellLauncherView({super.key});

  Widget build(BuildContext context) => Overlay(
    initialEntries: [
      OverlayEntry(
        builder: (context) => ModalBarrier(
          color: Colors.black.withOpacity(0.8),
          onDismiss: () => SystemNavigator.pop(),
        ),
      ),
      OverlayEntry(
        builder: (context) => Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Launcher(onClosePressed: () => SystemNavigator.pop()),
          ),
        ),
      ),
    ],
  );

  static Size? getWindowSize() => const Size(0, 0);

  static ExpidusWindowLayerConfig? getLayerConfig({String? monitor}) =>
      ExpidusWindowLayerConfig(
        layer: ExpidusWindowLayer.overlay,
        monitor: monitor,
        fixedSize: true,
        top: ExpidusWindowLayerAnchor(toEdge: true),
        bottom: ExpidusWindowLayerAnchor(toEdge: true),
        left: ExpidusWindowLayerAnchor(toEdge: true),
        right: ExpidusWindowLayerAnchor(toEdge: true),
      );
}
