import 'package:args/args.dart';
import 'package:expidus/expidus.dart';
import 'package:provider/provider.dart';
import 'services.dart';
import 'view/action_center.dart';
import 'view/desktop.dart';
import 'view/launcher.dart';
import 'view/panel.dart';
import 'view/shell.dart';

Size? _getWindowSize({required String component}) => switch (component) {
  'panel' => GenesisShellPanelView.getWindowSize(),
  'action-center' => GenesisShellActionCenterView.getWindowSize(),
  'launcher' => GenesisShellLauncherView.getWindowSize(),
  _ => null,
};

ExpidusWindowLayerConfig? _getLayerConfig({
  String? monitor,
  required String component,
}) => switch (component) {
  'panel' => GenesisShellPanelView.getLayerConfig(monitor: monitor),
  'desktop' => GenesisShellDesktopView.getLayerConfig(monitor: monitor),
  'action-center' => GenesisShellActionCenterView.getLayerConfig(
    monitor: monitor,
  ),
  'launcher' => GenesisShellLauncherView.getLayerConfig(monitor: monitor),
  _ => null,
};

void main(List<String> args) {
  final parser = ArgParser()
    ..addOption(
      'component',
      allowed: ['shell', 'panel', 'desktop', 'action-center', 'launcher'],
      defaultsTo: 'shell',
    )
    ..addOption('monitor')
    ..addOption('initial-route');

  var results = parser.parse(args);

  runApp(
    ExpidusAppConfig(
      windowSize: _getWindowSize(component: results.option('component')!),
      windowLayer: _getLayerConfig(
        component: results.option('component')!,
        monitor: results.option('monitor'),
      ),
      GenesisShellApp(
        component: results.option('component')!,
        monitor: results.option('monitor'),
        initialRoute: results.option('initial-route'),
      ),
    ),
  );
}

class GenesisShellApp extends StatelessWidget {
  const GenesisShellApp({
    super.key,
    required this.component,
    this.monitor,
    this.initialRoute,
  });

  final String component;
  final String? monitor;
  final String? initialRoute;

  Map<String, WidgetBuilder> get _routes => switch (component) {
    'shell' => {'/': (context) => const GenesisShellView()},
    'panel' => {'/': (context) => GenesisShellPanelView(monitor: monitor)},
    'desktop' => {'/': (context) => const GenesisShellDesktopView()},
    'action-center' => {'/': (context) => const GenesisShellActionCenterView()},
    'launcher' => {'/': (context) => const GenesisShellLauncherView()},
    _ => {},
  };

  @override
  Widget build(BuildContext context) => Provider(
    create: (_) => SystemServices.create(),
    child: ExpidusApp(
      title: 'Genesis Shell',
      routes: _routes,
      initialRoute: initialRoute,
    ),
  );
}
