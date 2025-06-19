import 'package:expidus/expidus.dart';
import 'package:flutter/material.dart' show ExpansionTile, ListTileTheme;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services.dart';
import 'access_point_tile.dart';

class ActionCenter extends StatelessWidget {
  const ActionCenter({
    super.key,
    this.clockFormat,
    this.onSettingsPressed,
    this.onClosePressed,
  });

  final DateFormat? clockFormat;
  final VoidCallback? onSettingsPressed;
  final VoidCallback? onClosePressed;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        HeaderBar(
          showMenuButton: false,
          showActions: false,
          titleWidget: DefaultTextStyle(
            style: Theme.of(context).textTheme.titleMedium!,
            child: DigitalClock.periodic(),
          ),
          start: [
            Button.flat(
              isActive: false,
              onPressed: onSettingsPressed,
              child: Icon(Icons.settings),
            ),
          ],
          end: [
            Button.flat(
              isActive: false,
              onPressed: onClosePressed,
              child: Icon(Icons.arrow_right),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
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
                      builder: (context, _) => ListTileTheme(
                        tileColor: Theme.of(context).colorScheme.background,
                        child: Column(
                          children: net.devices
                              .where((dev) => dev.showInActionCenter)
                              .map(
                                (dev) => ListenableBuilder(
                                  listenable: dev,
                                  builder: (context, _) => Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: dev.wireless != null
                                        ? ListenableBuilder(
                                            listenable: dev.wireless!,
                                            builder: (context, _) =>
                                                ExpansionTile(
                                                  leading: Icon(dev.icon!),
                                                  title: Text(dev.iface),
                                                  trailing: Button(
                                                    isActive:
                                                        dev.status ==
                                                        NetworkDeviceStatus
                                                            .active,
                                                    child: Icon(Icons.link_off),
                                                    onPressed: () {
                                                      dev.disconnect();
                                                    },
                                                  ),
                                                  children: [
                                                    SizedBox(
                                                      height: 250,
                                                      child: ListView(
                                                        children: dev
                                                            .wireless!
                                                            .accessPoints
                                                            .map(
                                                              (ap) =>
                                                                  AccessPointTile(
                                                                    accessPoint:
                                                                        ap,
                                                                  ),
                                                            )
                                                            .toList(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          )
                                        : ActionRow(
                                            start: Icon(dev.icon!),
                                            title: dev.iface,
                                            end: Button(
                                              isActive:
                                                  dev.status ==
                                                  NetworkDeviceStatus.active,
                                              child: Icon(Icons.link_off),
                                              onPressed: () {
                                                dev.disconnect();
                                              },
                                            ),
                                          ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
