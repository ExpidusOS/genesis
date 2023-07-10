import 'package:args/args.dart';
import 'package:libtokyo/libtokyo.dart' show ColorScheme;
import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:genesis_shell/views.dart';
import 'package:gokai/gokai.dart';

void main(List<String> args) {
  final parser = ArgParser();
  parser.addFlag('login', defaultsTo: false);

  final results = parser.parse(args);
  runApp(GenesisShell(login: results['login']));
}

class GenesisShell extends StatelessWidget {
  const GenesisShell({
    super.key,
    this.login = false,
  });

  final bool login;

  @override
  Widget build(BuildContext context) =>
    TokyoApp(
      title: 'Genesis Shell',
      themeMode: ThemeMode.dark,
      colorScheme: ColorScheme.night,
      colorSchemeDark: ColorScheme.night,
      initialRoute: login ? '/' : '/desktop',
      routes: {
        '/': (ctx) => const GenesisShellLogIn(),
        '/desktop': (ctx) => const GenesisShellDesktop(),
      },
    );
}
