import 'package:expidus/expidus.dart';

const _kMarginSize = 5;

class PanelView extends StatefulWidget {
  const PanelView({super.key});

  @override
  State<PanelView> createState() => _PanelViewState();
}

class _PanelViewState extends State<PanelView> {
  late FlapController _flapController;

  void _updateState() {
    ExpidusMethodChannel.instance
        .setLayering(
            ExpidusWindowLayerConfig(
              layer: _flapController.isOpen
                  ? ExpidusWindowLayer.overlay
                  : ExpidusWindowLayer.top,
              autoExclusiveZone: !_flapController.isOpen,
              fixedSize: true,
              keyboardMode: _flapController.isOpen
                  ? ExpidusWindowLayerKeyboardMode.exclusive
                  : ExpidusWindowLayerKeyboardMode.none,
              top: ExpidusWindowLayerAnchor(
                  toEdge: true,
                  margin: _flapController.isOpen ? 0 : _kMarginSize),
              left: ExpidusWindowLayerAnchor(
                  toEdge: true,
                  margin: _flapController.isOpen ? 0 : _kMarginSize),
              right: ExpidusWindowLayerAnchor(
                  toEdge: true,
                  margin: _flapController.isOpen ? 0 : _kMarginSize),
              bottom: ExpidusWindowLayerAnchor(
                  toEdge: _flapController.isOpen,
                  margin: _flapController.isOpen ? 0 : _kMarginSize),
            ),
            _flapController.isOpen ? const Size(0, 0) : const Size(0, 50))
        .then((size) {
      appWindow!.size = size;
      setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _flapController = FlapController();

    _flapController.addListener(() {
      _updateState();
    });

    _updateState();
  }

  @override
  Widget build(BuildContext context) => InputShapeCombineRegions(
        child: ExpidusScaffold(
          flapController: _flapController,
          flapOptions: FlapOptions(listenResize: false, visible: false),
          flap: (isDrawer) => Padding(
            padding: const EdgeInsets.all(_kMarginSize * 1.0),
            child: InputShapeRegion(
              enable: _flapController.isOpen,
              child: Sidebar(
                currentIndex: 0,
                isDrawer: isDrawer,
                onSelected: (i) {},
                children: [],
              ),
            ),
          ),
          headerBarPadding: EdgeInsets.all(
              _flapController.isOpen ? _kMarginSize.toDouble() : 0.0),
          wrapHeaderBar: (context, child) => InputShapeRegion(child: child),
          showActions: false,
          titleWidget: const SizedBox(),
          transparentBody: true,
        ),
      );
}
