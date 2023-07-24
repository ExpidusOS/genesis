import 'dart:io';
import 'package:args/args.dart';
import 'package:dbus/dbus.dart';
import 'package:flutter/services.dart';
import 'package:genesis_shell/models.dart';
import 'package:genesis_shell/views.dart';
import 'package:gokai/gokai.dart';
import 'package:flutter/foundation.dart';
import 'package:gokai/services/window_manager.dart';
import 'package:libtokyo/libtokyo.dart' show ColorScheme;
import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:provider/provider.dart';
import 'package:xdg_directories/xdg_directories.dart' as xdg;

void main(List<String> args) {
  final parser = ArgParser();
  parser.addFlag('login', defaultsTo: false);

  final results = parser.parse(args);
  runApp(GenesisShell(login: results['login']));
}

class GenesisShell extends StatefulWidget {
  const GenesisShell({
    super.key,
    this.login = false,
  });

  final bool login;

  @override
  State<GenesisShell> createState() => _GenesisShellState();
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
    FutureBuilder(
      future: GokaiContext().init(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (context) => WindowViewModel(snapshot.data!)),
              ChangeNotifierProvider(create: (context) => BatteryModel(snapshot.data!)),
              Provider(create: (context) => snapshot.data!),
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
        return const SizedBox();
      },
    );
}
