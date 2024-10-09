import 'dart:io';
import 'package:expidus/expidus.dart';
import '../widgets/panel.dart';
import '../widgets/user_drawer.dart';

class DesktopView extends StatefulWidget {
  const DesktopView({
    super.key,
    this.monitor,
  });

  final String? monitor;

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  GlobalKey<InputShapeCombineRegionsState> _inputShapeRegionsKey = GlobalKey();

  late FlapController _flapController;

  void _updateLayering() {
    ExpidusMethodChannel.instance.setLayering(
        ExpidusWindowLayerConfig(
          layer: ExpidusWindowLayer.top,
          exclusiveZone: 60,
          fixedSize: true,
          keyboardMode: (_scaffoldKey.currentState?.isEndDrawerOpen ?? false) ?
            ExpidusWindowLayerKeyboardMode.demand
          : ExpidusWindowLayerKeyboardMode.none,
          monitor: widget.monitor,
          top: ExpidusWindowLayerAnchor(toEdge: true),
          left: ExpidusWindowLayerAnchor(toEdge: true),
          right: ExpidusWindowLayerAnchor(toEdge: true),
          bottom: ExpidusWindowLayerAnchor(toEdge: true),
        ),
        const Size(0, 0));
  }

  @override
  void initState() {
    super.initState();

    _updateLayering();
  }

  @override
  Widget build(BuildContext context) =>
    InputShapeCombineRegions(
      key: _inputShapeRegionsKey,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        onEndDrawerChanged: (_) {
          _updateLayering();
          setState(() {
            _inputShapeRegionsKey.currentState!.updateRegions();
          });
        },
        endDrawer: Padding(
          padding: const EdgeInsets.only(top: 55, right: 5, bottom: 5),
          child: InputShapeRegion(
            child: const UserDrawer(),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: InputShapeRegion(
            child: Panel(
              padding: EdgeInsets.all(5),
              hasDrawer: true,
              onDrawerToggle: () {},
              onEndDrawerToggle: () => _scaffoldKey.currentState!.isEndDrawerOpen ? _scaffoldKey.currentState!.closeEndDrawer() :  _scaffoldKey.currentState!.openEndDrawer(),
            ),
          ),
        ),
        body: InputShapeRegion(
          enable: _scaffoldKey.currentState?.isEndDrawerOpen ?? false,
          child: const SizedBox.expand(),
        ),
      ),
    );
}
