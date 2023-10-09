import 'dart:io';
import 'package:args/args.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/services.dart';
import 'package:genesis_shell/models.dart';
import 'package:genesis_shell/views.dart';
import 'package:gokai/gokai.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pubspec/pubspec.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:gokai/services/window_manager.dart';
import 'package:libtokyo/libtokyo.dart' show ColorScheme;
import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:provider/provider.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

final kCommitHash = (const String.fromEnvironment('COMMIT_HASH', defaultValue: 'AAAAAAA')).substring(0, 7);

Future<void> main(List<String> args) async {
  final parser = ArgParser();
  parser.addFlag('login', defaultsTo: false);

  final results = parser.parse(args);

  WidgetsFlutterBinding.ensureInitialized();

  final pinfo = await PackageInfo.fromPlatform();

  final pubspec = PubSpec.fromYamlString(await rootBundle.loadString('pubspec.yaml')).copy(
    version: Version.parse("${pinfo.version}+$kCommitHash"),
  );

  final context = await GokaiContext().init();
  runApp(GenesisShell(
    login: results['login'],
    context: context,
    pubspec: pubspec,
  ));
}

class GenesisShell extends StatefulWidget {
  const GenesisShell({
    super.key,
    this.login = false,
    required this.context,
    required this.pubspec,
  });

  final bool login;
  final GokaiContext context;
  final PubSpec pubspec;

  @override
  State<GenesisShell> createState() => _GenesisShellState();

  static PubSpec getPubSpec(BuildContext context) => context.findAncestorWidgetOfExactType<GenesisShell>()!.pubspec;
}

class _GenesisShellState extends State<GenesisShell> {
  DBusAddress? _dbusAddress;
  DBusServer? _dbusServer;

  @override
  void initState() {
    super.initState();

    _startDBus();
  }

  void _startDBus() async {
    if (!kIsWeb) {
      switch (defaultTargetPlatform) {
        case TargetPlatform.linux:
          try {
            final session = DBusClient.session();
            await session.ping();
            session.close();
          } catch(e) {
            _dbusAddress = DBusAddress.unix(path: '${xdg.runtimeDir!.path}/bus');
          }
          break;
        default:
          break;
      }
    }

    if (_dbusAddress != null) {
      Platform.environment['DBUS_SESSION_BUS_ADDRESS'] = _dbusAddress!.value;
      _dbusServer = DBusServer();
      await _dbusServer!.listenAddress(_dbusAddress!);
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (_dbusServer != null) {
      _dbusServer!.close();
    }
  }

  @override
  Widget build(BuildContext context) =>
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => WindowViewModel(widget.context)),
        ChangeNotifierProvider(create: (context) => BatteryModel(widget.context)),
        Provider(create: (context) => widget.context),
      ],
      child: TokyoApp(
        title: 'Genesis Shell',
        themeMode: ThemeMode.dark,
        colorScheme: ColorScheme.night,
        colorSchemeDark: ColorScheme.night,
        initialRoute: widget.login ? '/' : '/desktop',
        routes: {
          '/': (ctx) => const GenesisShellLogIn(),
          '/desktop': (ctx) => const GenesisShellDesktop(),
        },
      ),
    );
}
