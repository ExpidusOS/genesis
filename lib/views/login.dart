import 'dart:io';
import 'package:event/event.dart';
import 'package:libtokyo_flutter/libtokyo.dart' hide ColorScheme;
import 'package:genesis_shell/widgets.dart';
import 'package:gokai/user/account.dart';
import 'package:gokai/gokai.dart';
import 'package:gokai/services.dart';

class GenesisShellLogIn extends StatefulWidget {
  const GenesisShellLogIn({super.key});

  @override
  State<GenesisShellLogIn> createState() => _GenesisShellLogInState();
}

class _GenesisShellLogInState extends State<GenesisShellLogIn> {
  Key _accounts_key = UniqueKey();

  GokaiContext? _gokai_context;
  GokaiUserAccount? _selected_account;

  void _onAccountManagerChange(EventArgs? args) {
    final accountManager = _gokai_context!.services['AccountManager'] as GokaiAccountManager;
    accountManager.getAll().then((accounts) => setState(() {
      _accounts_key = UniqueKey();
    }));
  }

  @override
  void initState() {
    super.initState();

    GokaiContext().init().then((ctx) {
      final accountManager = ctx.services['AccountManager'] as GokaiAccountManager;

      setState(() {
        _gokai_context = ctx;
        accountManager.onChange.subscribe(_onAccountManagerChange);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();

    if (_gokai_context != null) {
      final accountManager = _gokai_context!.services['AccountManager'] as GokaiAccountManager;
      accountManager.onChange.unsubscribe(_onAccountManagerChange);
    }
  }

  @override
  Widget build(BuildContext context) =>
    Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wallpaper/desktop/dark-sand.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: convertFromColor(Colors.transparent),
          appBar: const GenesisShellPanel(
            showLeading: false,
          ),
          endDrawer: const ActionCenter(),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  width: 600,
                  height: _selected_account == null ? 300 : 410,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Log In',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        _gokai_context == null
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(),
                            )
                          : FutureBuilder(
                              key: _accounts_key,
                              future: (_gokai_context!.services['AccountManager'] as GokaiAccountManager).getAll(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SizedBox(
                                    height: 210,
                                    child: ListView(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.all(8.0),
                                      shrinkWrap: true,
                                      children: snapshot.data!.map((account) =>
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            style: _selected_account == account
                                              ? TextButton.styleFrom(
                                                  backgroundColor: Theme.of(context).textTheme.displaySmall!.color!.withOpacity(0.12),
                                                )
                                              : null,
                                            onPressed: () => setState(() {
                                              _selected_account = account;
                                            }),
                                            child: Column(
                                              children: [
                                                account.picture == null
                                                  ? const Icon(Icons.account_circle, size: 150)
                                                  : Image.file(
                                                      File(account.picture!),
                                                      width: 150,
                                                      height: 150,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return const Icon(Icons.account_circle, size: 150);
                                                      }
                                                    ),
                                                Text(account.displayName),
                                              ],
                                            ),
                                          ),
                                        )
                                      ).toList(),
                                    ),
                                  );
                                }

                                if (snapshot.hasError) {
                                  return Container(
                                    height: 80,
                                    child: Card(
                                      color: Theme.of(context).colorScheme.errorContainer,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Center(
                                          child: Text(
                                            'Failed to get user accounts: ${snapshot.error!.toString()}',
                                            style: Theme.of(context).textTheme.displaySmall!.copyWith(
                                              color: Theme.of(context).colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                                return const Padding(
                                  padding: EdgeInsets.all(32.0),
                                  child: CircularProgressIndicator(),
                                );
                              },
                            ),
                        ...(_selected_account == null
                          ? []
                          : [
                              const SizedBox(
                                width: 400,
                                child: TextField(
                                  decoration: InputDecoration(
                                    labelText: 'Password',
                                  ),
                                  obscureText: true,
                                  obscuringCharacter: '*',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_circle_right),
                                iconSize: 60,
                                // TODO: use Gokai to figure out a way to determine what DE to start.
                                onPressed: () => Navigator.pushReplacementNamed(context, '/desktop'),
                              ),
                            ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
}
