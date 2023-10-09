import 'package:genesis_shell/widgets.dart';
import 'package:libtokyo/libtokyo.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GenesisShellSettings<T> {
  wallpaper<String?>(null),
  panelTransparency<double?>(null),
  panelStyle(GenesisShellPanelStyle.pill),
  colorScheme(ColorScheme.night),
  firstRun(true),
  optInErrorReporting(false);

  const GenesisShellSettings(this.defaultValue);

  final T defaultValue;
  T valueFor(SharedPreferences prefs) => (prefs.get(name) as T?) ?? defaultValue;
  Future<T> get value async => valueFor(await SharedPreferences.getInstance());

  @override
  toString() => '$name:${T.toString()}';
}
