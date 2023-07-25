import 'dart:io';

import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:genesis_shell/models.dart';
import 'package:gokai/user/account.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'battery_indicator.dart';
import 'clock.dart';

class ActionCenter extends StatelessWidget {
  const ActionCenter({
    super.key,
    this.userAccount
  });

  final GokaiUserAccount? userAccount;

  @override
  Widget build(BuildContext context) {
    final coloredTextTheme = Theme.of(context).colorScheme.brightness == Brightness.dark
      ? Theme.of(context).typography.white
      : Theme.of(context).typography.black;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Drawer(
        width: 600,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    DigitalClock(
                      style: Theme.of(context).textTheme.displayMedium,
                      format: DateFormat.yMMMd(),
                    ),
                    DigitalClock(
                      style: Theme.of(context).textTheme.displayMedium,
                    ),
                  ],
                ),
              ),
              ...(userAccount != null ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: userAccount!.picture == null
                            ? const Icon(Icons.account_circle, size: 75)
                            : Image.file(
                            File(userAccount!.picture!),
                            width: 75,
                            height: 75,
                            frameBuilder: (context, child, frame, wasAsync) =>
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(64.0),
                                  child: child,
                                ),
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.account_circle, size: 75);
                            }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: Text(
                          userAccount!.displayName,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      )
                    ],
                  ),
                )
              ] : []),
              Consumer<BatteryModel>(
                builder: (context, model, child) {
                  return ListView(
                    shrinkWrap: true,
                    children: model.items.where((device) => !device.isIntegrated ? device.name.isNotEmpty : true).map(
                      (device) => ListTile(
                        leading: SizedBox.square(
                          dimension: 30,
                          child: BatteryIndicator(
                            device: device,
                            withLabel: false,
                          ),
                        ),
                        title: Text(device.name),
                        subtitle: BatteryIndicator(
                          device: device,
                          withIcon: false,
                        ),
                      )
                    ).toList(),
                  );
                },
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    OutlinedButton(
                      child: const Icon(Icons.power_off, size: 64),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: coloredTextTheme.labelMedium!.color,
                      ),
                      onPressed: () {}
                    ),
                    OutlinedButton(
                      child: const Icon(Icons.restart_alt, size: 64),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor: coloredTextTheme.labelMedium!.color,
                      ),
                      onPressed: () {}
                    ),
                    ...(userAccount != null
                      ? [
                          OutlinedButton(
                            child: const Icon(Icons.logout, size: 64),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: coloredTextTheme.labelMedium!.color,
                            ),
                            onPressed: () {}
                          ),
                          OutlinedButton(
                            child: const Icon(Icons.lock, size: 64),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: coloredTextTheme.labelMedium!.color,
                            ),
                            onPressed: () {}
                          ),
                          OutlinedButton(
                            child: const Icon(Icons.settings, size: 64),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: coloredTextTheme.labelMedium!.color,
                            ),
                            onPressed: () {}
                          ),
                        ]
                      : [])
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
