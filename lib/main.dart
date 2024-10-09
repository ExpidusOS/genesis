import 'dart:io';

import 'package:expidus/expidus.dart';

import 'views/action_dialog.dart';
import 'views/backdrop.dart';
import 'views/desktop.dart';
import 'views/panel.dart';
import 'views/user_drawer.dart';

void main(List<String> args) {
  final mode = args.length > 0 ? args[0] : 'desktop';
  final monitor = args.length > 1 ? args[1] : null;

  runApp(ExpidusAppConfig(
    ExpidusApp(
      title: 'Genesis Shell',
      home: switch (mode) {
        'action-dialog' => ActionDialogView(monitor: monitor),
        'backdrop' => BackdropView(monitor: monitor),
        'desktop' => DesktopView(monitor: monitor),
        'panel' => PanelView(monitor: monitor),
        'user-drawer' => UserDrawerView(monitor: monitor),
        (_) => throw Exception('Invalid mode $mode'),
      },
    ),
    windowSize: const Size(0, 50),
    windowLayer: ExpidusWindowLayerConfig(
      fixedSize: true,
      monitor: monitor,
    ),
  ));
}
