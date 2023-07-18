import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:flutter/material.dart' as material;
import 'app_launcher.dart';
import 'clock.dart';

class GenesisShellPanel extends StatelessWidget implements PreferredSizeWidget {
  const GenesisShellPanel({ super.key, this.showLeading = true, this.start, this.end });

  final bool showLeading;
  final Widget? start;
  final Widget? end;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) =>
    Padding(
      padding: const EdgeInsets.all(5.0),
      child: AppBar(
        centerTitle: true,
        elevation: 30,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        automaticallyImplyLeading: showLeading,
        leading: showLeading ? start ?? IconButton(
          icon: const Icon(Icons.apps),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AppLauncher(),
          ),
        ) : null,
        actions: [
          end ?? TextButton(
            child: DigitalClock(
              style: Theme.of(context).textTheme.titleLarge,
            ),
            onPressed: () => material.Scaffold.of(context).openEndDrawer(),
          )
        ],
      ),
    );
}
