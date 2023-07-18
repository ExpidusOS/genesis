import 'dart:math' as math;
import 'package:genesis_shell/models.dart';
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
import 'package:provider/provider.dart';

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
    }
    return result;
  }
}

class _GenesisShellDesktopState extends State<GenesisShellDesktop> {
  final _scaffold = GlobalKey<material.ScaffoldState>();
  final Map<String, Rect> _windowRects = {};

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
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
                endDrawer: FutureBuilder(
                  future: (Provider.of<GokaiContext>(context).services['AccountManager'] as GokaiAccountManager).getCurrent(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ActionCenter(userAccount: snapshot.data!);
                    }
                    return const ActionCenter(userAccount: null);
                  }
                ),
                body: AdaptiveLayout(
                  body: SlotLayout(
                    config: {
                      Breakpoints.small: SlotLayout.from(
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
                                                  leading: const Icon(Icons.window),
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
      ),
    );
  }
}
