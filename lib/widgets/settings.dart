import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:libtokyo_flutter/widgets/about_page_builder.dart';
import 'package:genesis_shell/main.dart';

class _SettingsAppearanceDialog extends StatelessWidget {
  const _SettingsAppearanceDialog({ super.key });

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
            ],
          ),
        ),
      ),
    );
}

class _SettingsPrivacyDialog extends StatelessWidget {
  const _SettingsPrivacyDialog({ super.key });

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
  const GenesisShellSettingsDialog({ super.key });

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
                    builder: (_) => const _SettingsAppearanceDialog(),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.doorClosed),
                title: const Text('Privacy'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => const _SettingsPrivacyDialog(),
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
