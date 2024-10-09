import 'dart:io';
import 'package:expidus/expidus.dart';
import '../widgets/panel.dart';

class PanelView extends StatefulWidget {
  const PanelView({
    super.key,
    this.monitor,
  });

  final String? monitor;

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  Map<String, Process> _procMan = {};

  void _updateLayering() {
    ExpidusMethodChannel.instance.setLayering(
        ExpidusWindowLayerConfig(
          layer: ExpidusWindowLayer.top,
          exclusiveZone: 60,
          fixedSize: true,
          monitor: widget.monitor,
          top: ExpidusWindowLayerAnchor(toEdge: true),
          left: ExpidusWindowLayerAnchor(toEdge: true),
          right: ExpidusWindowLayerAnchor(toEdge: true),
        ),
        const Size(0, 85.0));
  }

  Future<void> toggleMode(String mode) async {
    if (!_procMan.containsKey(mode)) {
      _procMan[mode] = await Process.start(Platform.resolvedExecutable,
          [mode, if (widget.monitor != null) widget.monitor!]);
      _updateLayering();
      _procMan[mode]!.exitCode.then((_) {
        _procMan.remove(mode);
        _updateLayering();
      });
    } else {
      _procMan[mode]!.kill();
      _procMan!.remove(mode);
      _updateLayering();
    }
  }

  @override
  void initState() {
    super.initState();
    _updateLayering();
  }

  @override
  void dispose() {
    super.dispose();

    _procMan.forEach((_, v) {
      v.kill();
    });
  }

  @override
  Widget build(BuildContext context) => Panel(
        padding: EdgeInsets.all(5),
        hasDrawer: true,
        onDrawerToggle: () => toggleMode('action-dialog'),
        onEndDrawerToggle: () => toggleMode('user-drawer'),
      );
}
