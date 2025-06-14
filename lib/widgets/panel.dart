import 'dart:ui';
import 'package:expidus/expidus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../logic/breakpoint.dart';
import '../services.dart';

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    this.clockFormat,
    this.onNetworkingPressed,
    this.onClockPressed,
    this.onPowerPressed,
  });

  final DateFormat? clockFormat;
  final VoidCallback? onNetworkingPressed;
  final VoidCallback? onClockPressed;
  final VoidCallback? onPowerPressed;

  Widget _buildButton(Widget child, VoidCallback onPressed) => Button.flat(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
    margin: EdgeInsets.zero,
    isActive: false,
    onPressed: onPressed,
    backgroundColorBuilder:
        (context, backgroundColor, status, {bool opaque = false}) =>
            Button.flatBackgroundColorBuilder(
              context,
              Theme.of(context).colorScheme!.primary,
              status,
              opaque: opaque,
            ) ??
            Theme.of(context).appBarTheme.backgroundColor,
    child: child,
  );

  Widget _buildOptionlButton(Widget child, VoidCallback? onPressed) =>
      onPressed != null ? _buildButton(child, onPressed!) : child;

  Widget build(BuildContext context) => Padding(
    padding: Breakpoint.of(context) == Breakpoint.mobile
        ? EdgeInsets.zero
        : EdgeInsets.all(8),
    child: HeaderBar(
      showActions: false,
      title: '',
      end: [
        FutureProvider(
          initialData: null,
          create: (_) =>
              Provider.of<SystemServices>(context).createNetworking(),
          dispose: (_, net) => net?.dispose(),
          builder: (context, _) {
            final net = Provider.of<NetworkingService?>(context);
            if (net != null) {
              return ListenableBuilder(
                listenable: net,
                builder: (context, _) => _buildOptionlButton(
                  Row(
                    children: net.devices
                        .where((dev) => dev.showInPanel)
                        .map(
                          (dev) => ListenableBuilder(
                            listenable: dev,
                            builder: (context, _) => Icon(dev.icon!),
                          ),
                        )
                        .toList(),
                  ),
                  onNetworkingPressed,
                ),
              );
            }
            return const CircularProgressIndicator();
          },
        ),
        _buildOptionlButton(
          DigitalClock.periodic(format: clockFormat),
          onClockPressed,
        ),
        if (onPowerPressed != null)
          _buildButton(Icon(Icons.power_settings_new), onPowerPressed!),
      ],
    ),
  );
}
