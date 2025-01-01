import 'dart:io';
import 'package:expidus/expidus.dart';

import '../widgets/action_dialog.dart';
import '../widgets/panel.dart';
import '../widgets/user_drawer.dart';

class DesktopView extends StatefulWidget {
  const DesktopView({
    super.key,
  });

  @override
  State<DesktopView> createState() => _DesktopViewState();
}

class _DesktopViewState extends State<DesktopView> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  bool? _isDialogOpen;
  late FlapController _flapController;

  @override
  Widget build(BuildContext context) => Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        endDrawer: Padding(
          padding: const EdgeInsets.only(top: 55, right: 5, bottom: 5),
          child: InputShapeRegion(
            child: const UserDrawer(),
          ),
        ),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Panel(
              padding: EdgeInsets.all(5),
              hasDrawer: true,
              onDrawerToggle: () {
                setState(() {
                  _isDialogOpen = true;

                  showDialog(
                    context: context,
                    builder: (context) => const ActionDialog(),
                  ).whenComplete(() {
                    setState(() {
                      _isDialogOpen = null;
                    });
                  });
                });
              },
              onEndDrawerToggle: () =>
                  _scaffoldKey.currentState!.isEndDrawerOpen
                      ? _scaffoldKey.currentState!.closeEndDrawer()
                      : _scaffoldKey.currentState!.openEndDrawer(),
          ),
        ),
        extendBody: true,
        body: const SizedBox.expand(),
      );
}
