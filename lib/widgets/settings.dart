import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:libtokyo_flutter/widgets/about_page_builder.dart';
import 'package:genesis_shell/main.dart';
import 'package:genesis_shell/logic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'panel.dart';

class _SettingsAppearanceDialog extends StatefulWidget {
  const _SettingsAppearanceDialog({
    super.key,
    required this.prefs,
    required this.reload,
  });

  final SharedPreferences prefs;
  final VoidCallback reload;

  @override
  State<_SettingsAppearanceDialog> createState() => _SettingsAppearanceDialogState();
}

class _SettingsAppearanceDialogState extends State<_SettingsAppearanceDialog> {
  ColorScheme colorScheme = ColorScheme.night;
  double? panelTransparency;
  GenesisShellPanelStyle panelStyle = GenesisShellPanelStyle.pill;

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  void _loadSettings() {
    colorScheme = ColorScheme.values.asNameMap()[widget.prefs.getString(GenesisShellSettings.colorScheme.name) ?? 'night']!;
    panelTransparency = GenesisShellSettings.panelTransparency.valueFor(widget.prefs);
    panelStyle = GenesisShellPanelStyle.values.asNameMap()[widget.prefs.getString(GenesisShellSettings.panelStyle.name) ?? 'pill']!;
  }

  Widget build(BuildContext context) =>
    Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Appearance'),
        ),
        body: ListTileTheme(
          tileColor: Theme.of(context).cardTheme.color
            ?? Theme.of(context).cardColor,
          shape: Theme.of(context).cardTheme.shape,
          contentPadding: Theme.of(context).cardTheme.margin,
          child: ListView(
            children: [
              ListTile(
                title: const Text('Theme'),
                onTap: () =>
                  showDialog<ColorScheme>(
                    context: context,
                    builder: (context) =>
                      Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: [
                              RadioListTile(
                                title: const Text('Storm'), // TODO: i18n
                                value: ColorScheme.storm,
                                groupValue: colorScheme,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                              RadioListTile(
                                title: const Text('Night'), // TODO: i18n
                                value: ColorScheme.night,
                                groupValue: colorScheme,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                              RadioListTile(
                                title: const Text('Moon'), // TODO: i18n
                                value: ColorScheme.moon,
                                groupValue: colorScheme,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                              RadioListTile(
                                title: const Text('Day'), // TODO: i18n
                                value: ColorScheme.day,
                                groupValue: colorScheme,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ).then((value) {
                    if (value != null) {
                      widget.prefs.setString(
                        GenesisShellSettings.colorScheme.name,
                        value.name
                      );

                      setState(() {
                        colorScheme = value;
                        widget.reload();
                      });
                    }
                  }),
              ),
              ListTile(
                title: const Text('Panel style'),
                onTap: () =>
                  showDialog<GenesisShellPanelStyle>(
                    context: context,
                    builder: (context) =>
                      Dialog(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView(
                            children: [
                              RadioListTile(
                                title: const Text('Pill'), // TODO: i18n
                                value: GenesisShellPanelStyle.pill,
                                groupValue: panelStyle,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                              RadioListTile(
                                title: const Text('Bubbles'), // TODO: i18n
                                value: GenesisShellPanelStyle.bubbles,
                                groupValue: panelStyle,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                              RadioListTile(
                                title: const Text('Flat'), // TODO: i18n
                                value: GenesisShellPanelStyle.flat,
                                groupValue: panelStyle,
                                onChanged: (value) => Navigator.pop(context, value),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ).then((value) {
                    if (value != null) {
                      widget.prefs.setString(
                        GenesisShellSettings.panelStyle.name,
                        value.name
                      );

                      setState(() {
                        panelStyle = value;
                        widget.reload();
                      });
                    }
                  }),
              ),
              ListTile(
                title: const Text('Panel transparency'),
                onTap: () =>
                  showDialog(
                    context: context,
                    builder: (context) =>
                      StatefulBuilder(
                        builder: (context, setState) =>
                          Dialog(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Slider(
                                value: (panelTransparency ?? 1.0) * 100,
                                max: 100.0,
                                label: ((panelTransparency ?? 1.0) * 100).round().toString(),
                                onChanged: (value) =>
                                  setState(() {
                                    panelTransparency = value / 100;

                                    widget.prefs.setDouble(

                                      GenesisShellSettings.panelTransparency.name,
                                      panelTransparency ?? 1.0
                                    );

                                    widget.reload();
                                  }),
                              ),
                            ),
                          ),
                        ),
                  ),
              ),
            ],
          ),
        ),
      ),
    );
}

class _SettingsPrivacyDialog extends StatelessWidget {
  const _SettingsPrivacyDialog({
    super.key,
    required this.prefs,
  });

  final SharedPreferences prefs;

  Widget build(BuildContext context) =>
    Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy'),
        ),
        body: ListTileTheme(
          tileColor: Theme.of(context).cardTheme.color
            ?? Theme.of(context).cardColor,
          shape: Theme.of(context).cardTheme.shape,
          contentPadding: Theme.of(context).cardTheme.margin,
          child: ListView(
            children: [
            ],
          ),
        ),
      ),
    );
}

class _SettingsAboutDialog extends StatelessWidget {
  const _SettingsAboutDialog({ super.key });

  Widget build(BuildContext context) =>
    Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('About'),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: AboutPageBuilder(
              appTitle: 'Genesis Shell',
              appDescription: GenesisShell.getPubSpec(context).description!,
              pubspec: GenesisShell.getPubSpec(context),
            ),
          ),
        ),
      ),
    );
}

class GenesisShellSettingsDialog extends StatelessWidget {
  const GenesisShellSettingsDialog({
    super.key,
    required this.prefs,
    required this.reload,
  });

  final SharedPreferences prefs;
  final VoidCallback reload;

  Widget build(BuildContext context) =>
    Dialog(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListTileTheme(
          tileColor: Theme.of(context).cardTheme.color
            ?? Theme.of(context).cardColor,
          shape: Theme.of(context).cardTheme.shape,
          contentPadding: Theme.of(context).cardTheme.margin,
          child: ListView(
            children: [
              ListTile(
                leading: Icon(Icons.palette),
                title: const Text('Appearance'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => _SettingsAppearanceDialog(
                      prefs: prefs,
                      reload: reload,
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.doorClosed),
                title: const Text('Privacy'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => _SettingsPrivacyDialog(prefs: prefs),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.computer),
                title: const Text('About'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _SettingsAboutDialog(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
}
