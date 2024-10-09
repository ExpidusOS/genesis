import 'dart:io';
import 'package:expidus/expidus.dart';
import '../widgets/user_drawer.dart';

class UserDrawerView extends StatefulWidget {
  const UserDrawerView({
    super.key,
    this.monitor,
  });

  final String? monitor;

  @override
  State<UserDrawerView> createState() => _UserDrawerViewState();
}

class _UserDrawerViewState extends State<UserDrawerView> {
  @override
  void initState() {
    super.initState();

    ExpidusMethodChannel.instance.setLayering(
        ExpidusWindowLayerConfig(
          layer: ExpidusWindowLayer.top,
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
  Widget build(BuildContext context) => Overlay(
        initialEntries: [
          OverlayEntry(
              builder: (context) => ModalBarrier(
                    color: Colors.transparent,
                    onDismiss: () => exit(0),
                  )),
          OverlayEntry(
            builder: (context) => Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5),
              child: Row(
                children: [
                  const Spacer(),
                  const UserDrawer(),
                ],
              ),
            ),
          ),
        ],
      );
}
