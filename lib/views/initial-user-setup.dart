import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:genesis_shell/widgets.dart';

class GenesisShellInitialUserSetup extends StatefulWidget {
  const GenesisShellInitialUserSetup({ super.key });

  @override
  State<GenesisShellInitialUserSetup> createState() => _GenesisShellInitialUserSetupState();
}

class _GenesisShellInitialUserSetupState extends State<GenesisShellInitialUserSetup> {
  @override
  Widget build(BuildContext context) =>
    Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/wallpaper/desktop/mountains.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Scaffold(
          backgroundColor: convertFromColor(Colors.transparent),
          appBar: GenesisShellPanel(
            showLeading: false,
            end: Row(
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
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          // TODO: figure out if we're on a Linux distro and display the distro name and logo
                          'Welcome to Genesis Shell',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: IconButton(
                          icon: Icon(Icons.arrowRight),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
}
