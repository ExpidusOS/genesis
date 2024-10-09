import 'dart:io';
import 'package:expidus/expidus.dart';
import '../widgets/backdrop.dart';

class BackdropView extends StatefulWidget {
  const BackdropView({
    super.key,
    this.monitor,
  });

  final String? monitor;

  @override
  State<BackdropView> createState() => _BackdropViewState();
}

class _BackdropViewState extends State<BackdropView> {
  @override
  void initState() {
    super.initState();

    ExpidusMethodChannel.instance.setLayering(
        ExpidusWindowLayerConfig(
          layer: ExpidusWindowLayer.background,
          exclusiveZone: -1,
          fixedSize: true,
          monitor: widget.monitor,
          top: ExpidusWindowLayerAnchor(toEdge: true),
          left: ExpidusWindowLayerAnchor(toEdge: true),
          right: ExpidusWindowLayerAnchor(toEdge: true),
          bottom: ExpidusWindowLayerAnchor(toEdge: true),
        ),
        const Size(0, 0));
  }

  @override
  Widget build(BuildContext context) => const Backdrop();
}
