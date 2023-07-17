import 'dart:math' as math;
import 'package:gokai/widgets.dart';
import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:genesis_shell/gestures.dart';
import 'package:genesis_shell/widgets.dart';
import 'package:gokai/user/account.dart';
import 'package:gokai/view/window.dart';
import 'package:gokai/gokai.dart';
import 'package:gokai/services.dart';

class GenesisShellDesktop extends StatefulWidget {
  const GenesisShellDesktop({super.key});

  @override
  State<GenesisShellDesktop> createState() => _GenesisShellDesktopState();
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
    } else {
      print(event);
    }
    return result;
  }
}

class _GenesisShellDesktopState extends State<GenesisShellDesktop> {
  final _scaffold = GlobalKey<material.ScaffoldState>();
  GokaiContext? _gokaiContext;
  GokaiWindowManager? _windowManager;
  GokaiUserAccount? _account;
  List<GokaiWindow> _windows = [];
  Map<String, Rect> _windowRects = {};

  @override
  void initState() {
    super.initState();

    GokaiContext().init().then((ctx) async {
      final accountManager = ctx.services['AccountManager'] as GokaiAccountManager;
      final account = await accountManager.getCurrent();

      final windowManager = ctx.services['WindowManager'] as GokaiWindowManager;
      windowManager.onChange.add(() {
        windowManager.getViewable().then((value) => setState(() {
          _windows = value;
        }));
      });
      final windows = await windowManager.getViewable();

      setState(() {
        _gokaiContext = ctx;
        _account = account;
        _windowManager = windowManager;
        _windows = windows;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      manager: _DesktopShortcutsManager(
        shortcuts: {
          CharacterActivator('a', meta: true): _ActionCenterIntent(),
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
        child: Focus(
          autofocus: true,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/wallpaper/desktop/default.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              material.Scaffold(
                key: _scaffold,
                backgroundColor: Colors.transparent,
                appBar: const GenesisShellPanel(),
                endDrawer: ActionCenter(userAccount: _account),
                body: Stack(
                  clipBehavior: Clip.none,
                  children: _windows.map(
                    (e) => Positioned(
                      left: (_windowRects[e.id] ?? e.rect).left,
                      top: (_windowRects[e.id] ?? e.rect).top,
                      child: GokaiWindowView(
                        id: e.id,
                        windowManager: _windowManager!,
                        size: (_windowRects[e.id] ?? e.rect).size,
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
                                          ) - const Offset(0, kToolbarHeight + 10);
                                          final size = (_windowRects[win.id] ?? win.rect).size;
                                          final rect = Rect.fromPoints(pos, Offset(size.width, size.height));

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
                                    leading: const Icon(Icons.window),
                                    title: Text(win.title ?? 'Untitled Window'),
                                    onMinimize: () {},
                                    onClose: () {},
                                  ),
                                ),
                              ),
                              body: child,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
