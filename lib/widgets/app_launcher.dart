import 'package:genesis_shell/models.dart';
import 'package:gokai/widgets.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:provider/provider.dart';

class AppLauncher extends StatelessWidget {
  const AppLauncher({ super.key });

  @override
  Widget build(BuildContext context) {
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
                  child: Consumer<WindowViewModel>(
                    builder: (context, model, child) {
                      if (model.items.isEmpty) {
                        return Text(
                          'No applications are opened',
                          style: Theme.of(context).textTheme.displayMedium,
                        );
                      }

                      return ListView(
                        scrollDirection: Axis.horizontal,
                        children: model.activeFirstItems.map(
                          (win) => Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Card(
                              child: InkWell(
                                onTap: () {
                                  for (final activeWindow in model.active) {
                                    activeWindow.setActive(false);
                                  }

                                  win.setActive(true);
                                  Navigator.of(context, rootNavigator: true).pop();
                                },
                                child: SizedBox(
                                  width: win.rect.width,
                                  height: win.rect.height + kWindowBarHeight,
                                  child: Scaffold(
                                    windowBar: WindowBar(
                                      useBitsdojo: false,
                                      leading: const Icon(Icons.windows),
                                      title: Text(win.title ?? 'Untitled Window'),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(WindowBarTheme.of(context).borderRadius),
                                          topRight: Radius.circular(WindowBarTheme.of(context).borderRadius),
                                        ),
                                      ),
                                    ),
                                    body: GokaiWindowView(
                                      id: win.id,
                                      windowManager: model.windowManager,
                                      interactive: false,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ).toList(),
                      );
                    }
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
