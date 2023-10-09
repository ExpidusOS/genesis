import 'dart:io' as io;
import 'dart:math' as math;
import 'package:genesis_shell/models.dart';
import 'package:gokai/widgets.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:path/path.dart' as path;
import 'package:file/file.dart';
import 'package:file/local.dart';
import 'package:genesis_shell/compat.dart';
import 'package:genesis_shell/gestures.dart';
import 'package:genesis_shell/logic.dart';
import 'package:genesis_shell/widgets.dart';
import 'package:gokai/user/account.dart';
import 'package:gokai/view/window.dart';
import 'package:gokai/gokai.dart';
import 'package:gokai/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenesisShellDesktop extends StatefulWidget {
  const GenesisShellDesktop({super.key});

  @override
  State<GenesisShellDesktop> createState() => GenesisShellDesktopState();

  static GenesisShellDesktopState? maybeOf(BuildContext context) => context.findAncestorStateOfType<GenesisShellDesktopState>();
  static GenesisShellDesktopState of(BuildContext context) => maybeOf(context)!;
}

class _AppLauncherIntent extends Intent {
  const _AppLauncherIntent();
}

class _ActionCenterIntent extends Intent {
  const _ActionCenterIntent();
}

class _DesktopShortcutsManager extends ShortcutManager {
  _DesktopShortcutsManager({ super.shortcuts, super.modal });

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final result = super.handleKeypress(context, event);
    if (result != KeyEventResult.handled) {
      if (event.data.isMetaPressed) {
        final matchedIntent = shortcuts[LogicalKeySet(event.logicalKey)];
        if (matchedIntent != null) {
          final primaryContext = primaryFocus?.context;
          if (primaryContext != null) {
            final action = Actions.maybeFind<Intent>(
              primaryContext,
              intent: matchedIntent,
            );
            if (action != null && action.isEnabled(matchedIntent)) {
              final invokeResult = Actions.of(primaryContext).invokeAction(action, matchedIntent, primaryContext);
              return action.toKeyEventResult(matchedIntent, invokeResult);
            }
          }
        }
      }
    }
    return result;
  }
}

class GenesisShellDesktopState extends State<GenesisShellDesktop> {
  final _selfKey = GlobalKey();
  final _scaffold = GlobalKey<material.ScaffoldState>();
  final _fs = const LocalFileSystem();
  final Map<String, Rect> _windowRects = {};
  Key _key = UniqueKey();
  SharedPreferencesStorePlatform? _prevSharedPreferences;
  SharedPreferences? _prefs;
  
  void reload() {
    setState(() {
      _key = UniqueKey();
    });
  }

  Future<GokaiUserAccount> _getAccount(BuildContext context, { bool listen = true }) async {
    final route = ModalRoute.of(context);
    if (route != null) {
      final args = route!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        if (args!['account'] != null) return args!['account'] as GokaiUserAccount;
      }
    }
    return (Provider.of<GokaiContext>(context, listen: listen).services['AccountManager'] as GokaiAccountManager).getCurrent();
  }

  Future<SharedPreferences> _getPrefs(BuildContext context, { bool listen = true }) async {
    final account = await _getAccount(context, listen: listen);
    _prevSharedPreferences = SharedPreferencesStorePlatform.instance;
    SharedPreferences.resetStatic();

    if (account.home != null) {
      SharedPreferencesStorePlatform.instance = SharedPreferencesGokai(
        file: _fs.file(path.join(account.home!, '.config', 'genesis-shell', 'shared_preferences.json')),
      );
    }

    SharedPreferences.setPrefix(account.id.toString() + '.');
    return await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _getPrefs(_selfKey.currentContext!, listen: false).then((prefs) => setState(() {
        _prefs = prefs;
      }));
    });
  }

  @override
  void dispose() {
    if (_prevSharedPreferences != null) {
      SharedPreferencesStorePlatform.instance = _prevSharedPreferences!;
      SharedPreferences.resetStatic();
    }

    super.dispose();
  }

  ImageProvider _buildWallpaper() {
    if (_prefs == null) return AssetImage('assets/wallpaper/desktop/default.jpg');

    final p = GenesisShellSettings.wallpaper.valueFor(_prefs!);
    if (p == null) return AssetImage('assets/wallpaper/desktop/default.jpg');
    return FileImage(io.File(p));
  }

  Future<material.ThemeData> _loadTheme(BuildContext context) async {
    final colorScheme = _prefs != null ? ColorScheme.values.asNameMap()[_prefs!.getString(GenesisShellSettings.colorScheme.name) ?? 'night']! : ColorScheme.night;
    final data = await rootBundle.loadString('packages/libtokyo/data/themes/${colorScheme.name}.json');
    final loaded = ThemeData.json(
      package: 'libtokyo',
      colorScheme: colorScheme,
      json: data,
    );
    return convertThemeData(
      context: context,
      source: loaded,
      brightness: colorScheme == ColorScheme.day ? Brightness.light : Brightness.dark,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      key: _selfKey,
      manager: _DesktopShortcutsManager(
        shortcuts: {
          CharacterActivator('a', meta: true): _ActionCenterIntent(),
          LogicalKeySet(LogicalKeyboardKey.tab): VoidCallbackIntent(() {}),
          LogicalKeySet(LogicalKeyboardKey.superKey): _AppLauncherIntent(),
        },
      ),
      child: Actions(
        actions: {
          _AppLauncherIntent: CallbackAction(
            onInvoke: (intent) => showDialog(
              context: context,
              builder: (context) => const AppLauncher(),
            ),
          ),
          _ActionCenterIntent: CallbackAction(
            onInvoke: (intent) => _scaffold.currentState!.isEndDrawerOpen
              ? _scaffold.currentState!.closeEndDrawer()
              : _scaffold.currentState!.openEndDrawer()
          ),
        },
        child: FutureBuilder(
          future: _loadTheme(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error!);
            }

            if (snapshot.hasData) {
              return Theme(
                data: snapshot.data!,
                child: Focus(
                  key: _key,
                  autofocus: true,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                          image: _buildWallpaper(),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    material.Scaffold(
                     key: _scaffold,
                      backgroundColor: Colors.transparent,
                      appBar: GenesisShellPanel(
                        transparency: _prefs == null ? null : GenesisShellSettings.panelTransparency.valueFor(_prefs!),
                        style: _prefs == null ? GenesisShellPanelStyle.pill : GenesisShellPanelStyle.values.asNameMap()[_prefs!.getString(GenesisShellSettings.panelStyle.name) ?? 'pill'] ?? GenesisShellPanelStyle.pill,
                      ),
                      endDrawer: FutureBuilder(
                        future: _getAccount(context),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return ActionCenter(
                              userAccount: snapshot.data!,
                              prefs: _prefs,
                              reload: () => reload(),
                            );
                          }

                          if (snapshot.hasError) {
                            print(snapshot.error!);
                          }
                           return const ActionCenter(userAccount: null);
                        }
                      ),
                      body: AdaptiveLayout(
                        body: SlotLayout(
                          config: {
                            Breakpoints.smallAndUp: SlotLayout.from(
                              key: const Key('smallBody'),
                              builder: (context) =>
                                Consumer<WindowViewModel>(
                                  builder: (context, model, child) {
                                    final displaySize = MediaQuery.sizeOf(context);
                                    final rect = Rect.fromLTWH(0, 0, displaySize.width, displaySize.height);

                                    if (model.active.isEmpty) {
                                      return const SizedBox();
                                    }

                                    final win = model.active.first;

                                    if (context.mounted) {
                                     win.setRect(rect);
                                    }

                                    return GokaiWindowView(
                                      id: win.id,
                                      size: displaySize,
                                      windowManager: model.windowManager,
                                      inputManager: Provider.of<GokaiContext>(context).services['InputManager'] as GokaiInputManager,
                                    );
                                  }
                                ),
                            ),
                            Breakpoints.large: SlotLayout.from(
                              key: const Key('largeBody'),
                              builder: (context) =>
                                Consumer<WindowViewModel>(
                                  builder: (context, model, child) =>
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: model.activeFirstItems.reversed.map(
                                        (win) => Positioned(
                                          left: (_windowRects[win.id] ?? win.rect).left,
                                          top: (_windowRects[win.id] ?? win.rect).top,
                                          child: GokaiWindowView(
                                            id: win.id,
                                            size: (_windowRects[win.id] ?? win.rect).size,
                                            windowManager: model.windowManager,
                                            inputManager: Provider.of<GokaiContext>(context).services['InputManager'] as GokaiInputManager,
                                            decorationBuilder: (context, child, win) => SizedBox(
                                              width: win.rect.width,
                                              height: win.rect.height + kWindowBarHeight,
                                              child: Card(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(20.0),
                                                ),
                                                child: Scaffold(
                                                  windowBar: PreferredSize(
                                                    preferredSize: Size(
                                                      MediaQuery.sizeOf(context).width,
                                                      WindowBar.preferredHeightFor(context, const Size.fromHeight(kWindowBarHeight)),
                                                    ),
                                                    child: RawGestureDetector(
                                                      gestures: {
                                                        AllowMultipleVerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleVerticalDragGestureRecognizer>(
                                                          () => AllowMultipleVerticalDragGestureRecognizer(),
                                                          (instance) {
                                                            instance.onUpdate = (details) {
                                                              final displaySize = MediaQuery.sizeOf(context);
                                                              final pos = Offset(
                                                                math.min(
                                                                  details.globalPosition.dx,
                                                                  displaySize.width,
                                                                ),
                                                                math.min(
                                                                  details.globalPosition.dy,
                                                                  displaySize.height,
                                                                )
                                                              ) - const Offset(5, kToolbarHeight + 5);
                                                              final size = (_windowRects[win.id] ?? win.rect).size;
                                                              final rect = Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

                                                              win.setRect(rect);
                                                              setState(() {
                                                                _windowRects[win.id] = rect;
                                                              });
                                                            };
                                                          }
                                                        ),
                                                      },
                                                      child: WindowBar(
                                                        useBitsdojo: false,
                                                        leading: const Icon(Icons.windows), // TODO: use the "window" icon when that is available.
                                                        title: Text(win.title ?? 'Untitled Window'),
                                                        onMaximize: () {},
                                                        onMinimize: () {},
                                                        onClose: () {},
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.only(
                                                            topLeft: Radius.circular(WindowBarTheme.of(context).borderRadius),
                                                            topRight: Radius.circular(WindowBarTheme.of(context).borderRadius),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  body: child,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ).toList(),
                                    ),
                                ),
                              ),
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}
