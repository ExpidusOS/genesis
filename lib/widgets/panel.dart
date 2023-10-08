import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:flutter/material.dart' as material;
import 'app_launcher.dart';
import 'battery_bar.dart';
import 'clock.dart';

enum GenesisShellPanelStyle {
  pill,
  flat,
  bubbles,
}

class GenesisShellPanel extends StatelessWidget implements PreferredSizeWidget {
  const GenesisShellPanel({
    super.key,
    this.showLeading = true,
    this.start,
    this.end,
    this.style = GenesisShellPanelStyle.pill,
    this.transparency = 1.0,
  });

  final bool showLeading;
  final Widget? start;
  final Widget? end;
  final GenesisShellPanelStyle style;
  final double? transparency;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Widget? _buildLeading(BuildContext context) =>
    showLeading ? start ?? IconButton(
      icon: const Icon(Icons.boxes), // TODO: use an apps icon when that exists.
      onPressed: () => showDialog(
        context: context,
        builder: (context) => const AppLauncher(),
      ),
    ) : null;

  Widget _buildEnd(BuildContext context) =>
    end ?? InkWell(
      onTap: () => material.Scaffold.of(context).openEndDrawer(),
      child: Row(
        children: [
          const BatteryBar(),
          DigitalClock(
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ].map(
          (child) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: child,
          )
        ).toList(),
      ),
    );

  Widget _buildBar(BuildContext context) =>
    AppBar(
      centerTitle: true,
      elevation: 30,
      shape: style == GenesisShellPanelStyle.pill ? RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
      ) : null,
      backgroundColor: style == GenesisShellPanelStyle.bubbles ? Colors.transparent :
        (transparency != null ? AppBarTheme.of(context).backgroundColor!.withOpacity(transparency!) : null),
      automaticallyImplyLeading: showLeading,
      leading: style == GenesisShellPanelStyle.bubbles ? Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
        ),
        color: transparency != null ?
          AppBarTheme.of(context).backgroundColor!.withOpacity(transparency!)
        : null,
        child: _buildLeading(context),
      ) : _buildLeading(context),
      actions: [
        style == GenesisShellPanelStyle.bubbles ? Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          color: transparency != null ?
            AppBarTheme.of(context).backgroundColor!.withOpacity(transparency!)
          : null,
          child: _buildEnd(context),
        ) : _buildEnd(context),
      ],
    );

  @override
  Widget build(BuildContext context) =>
    style == GenesisShellPanelStyle.flat ? _buildBar(context)
      : Padding(
          padding: const EdgeInsets.all(5.0),
          child: _buildBar(context)
        );
}
