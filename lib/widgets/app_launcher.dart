import 'package:gokai/gokai.dart';
import 'package:gokai/services/window_manager.dart';
import 'package:gokai/view/window.dart';
import 'package:gokai/widgets.dart';
import 'package:libtokyo_flutter/libtokyo.dart';

class AppLauncher extends StatefulWidget {
  const AppLauncher({ super.key });

  @override
  State<AppLauncher> createState() => _AppLauncherState();
}

class _AppLauncherState extends State<AppLauncher> {
  GokaiContext? _gokaiContext;
  GokaiWindowManager? _windowManager;
  List<GokaiWindow> _windows = [];

  @override
  void initState() {
    super.initState();

    GokaiContext().init().then((ctx) async {
      final windowManager = ctx.services['WindowManager'] as GokaiWindowManager;
      windowManager.onChange.add(() {
        windowManager.getViewable().then((value) => setState(() {
          _windows = value;
        }));
      });
      final windows = await windowManager.getViewable();

      setState(() {
        _gokaiContext = ctx;
        _windowManager = windowManager;
        _windows = windows;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final coloredTextTheme = Theme.of(context).colorScheme.brightness == Brightness.dark
      ? Theme.of(context).typography.white
      : Theme.of(context).typography.black;
    final displaySize = MediaQuery.sizeOf(context);
    return ConstrainedBox(
      constraints: BoxConstraints.expand(
        width: displaySize.width,
        height: displaySize.height,
      ),
      child: Center(
        child: Column(
          children: [
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: SizedBox(
                width: displaySize.width,
                height: displaySize.height / 2.5,
                child: Center(
                  child: _windows.isEmpty
                    ? Text(
                      'No applications are opened',
                      style: Theme.of(context).textTheme.displayMedium,
                    )
                    : ListView(
                        scrollDirection: Axis.horizontal,
                        children: _windows.map(
                          (e) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  e.setActive(true);
                                  Navigator.pop(context);
                                },
                                child: SizedBox(
                                  width: e.rect.width,
                                  height: e.rect.height + kWindowBarHeight,
                                  child: Scaffold(
                                    windowBar: WindowBar(
                                      useBitsdojo: false,
                                      leading: const Icon(Icons.window),
                                      title: Text(e.title ?? 'Untitled Window'),
                                    ),
                                    body: GokaiWindowView(
                                      id: e.id,
                                      windowManager: _windowManager!,
                                      interactive: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ).toList(),
                      ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
