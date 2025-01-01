import 'dart:io';

import 'package:expidus/expidus.dart';

import 'views/desktop.dart';

void main(List<String> args) {
  runApp(ExpidusAppConfig(
    ExpidusApp(
      title: 'Genesis Shell',
      home: const DesktopView(),
    ),
  ));
}
