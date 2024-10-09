import 'dart:io';
import 'package:expidus/expidus.dart';
import '../widgets/action_dialog.dart';

class ActionDialogView extends StatefulWidget {
  const ActionDialogView({
    super.key,
    this.monitor,
  });

  final String? monitor;

  @override
  State<ActionDialogView> createState() => _ActionDialogViewState();
}

class _ActionDialogViewState extends State<ActionDialogView> {
  @override
  void initState() {
    super.initState();

    ExpidusMethodChannel.instance.setLayering(
        ExpidusWindowLayerConfig(
          layer: ExpidusWindowLayer.overlay,
          fixedSize: true,
          monitor: widget.monitor,
          keyboardMode: ExpidusWindowLayerKeyboardMode.exclusive,
          top: ExpidusWindowLayerAnchor(toEdge: true),
          left: ExpidusWindowLayerAnchor(toEdge: true),
          right: ExpidusWindowLayerAnchor(toEdge: true),
          bottom: ExpidusWindowLayerAnchor(toEdge: true),
        ),
        const Size(0, 0));
  }

  @override
  Widget build(BuildContext context) => Overlay(
        initialEntries: [
          OverlayEntry(
              builder: (context) => ModalBarrier(
                    color: Colors.black54,
                    onDismiss: () => exit(0),
                  )),
          OverlayEntry(builder: (context) => const ActionDialog()),
        ],
      );
}
