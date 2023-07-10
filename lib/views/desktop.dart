import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:genesis_shell/widgets.dart';
import 'package:gokai/user/account.dart';
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
  _DesktopShortcutsManager({ super.shortcuts });

  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      print('Handled shortcut $event in $context');
    } else {
      print(RawKeyboard.instance.keysPressed);
      print(RawKeyboard.instance.physicalKeysPressed);
      print(event);
    }
    return result;
  }
}

class _GenesisShellDesktopState extends State<GenesisShellDesktop> {
  final _scaffold = GlobalKey<material.ScaffoldState>();
  GokaiContext? _gokai_context;
  GokaiUserAccount? _account;

  @override
  void initState() {
    super.initState();

    GokaiContext().init().then((ctx) async {
      final accountManager = ctx.services['AccountManager'] as GokaiAccountManager;
      final account = await accountManager.getCurrent();

      setState(() {
        _gokai_context = ctx;
        _account = account;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts.manager(
      manager: _DesktopShortcutsManager(
        shortcuts: {
          SingleActivator(LogicalKeyboardKey.keyA, meta: true): _ActionCenterIntent(),
          LogicalKeySet(LogicalKeyboardKey.metaLeft, LogicalKeyboardKey.metaRight): _AppLauncherIntent(),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
