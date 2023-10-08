import 'dart:io';
import 'dart:math';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:genesis_shell/models.dart';
import 'package:genesis_shell/logic.dart';
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

    final displaySize = MediaQuery.sizeOf(context);
    final activeBreakpoint = findActiveBreakpoint(context) as WidthPlatformBreakpoint;
    final shouldFill = !Breakpoints.large.isActive(context);
    final width = activeBreakpoint.begin ?? displaySize.width / 3;
    return Padding(
      padding: EdgeInsets.all(shouldFill ? 5.0 : 16.0),
      child: Drawer(
        width: Breakpoints.small.isActive(context) && width > 0 ? width : 410,
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
                      style: Theme.of(context).textTheme.headlineLarge,
                      format: DateFormat.yMMMd(),
                    ),
                    DigitalClock(
                      style: Theme.of(context).textTheme.headlineLarge,
                    ),
                    IconButton(
                      iconSize: 36,
                      icon: Icon(shouldFill ? Icons.angleRight : Icons.xmark),
                      onPressed: () =>
                        Navigator.pop(context),
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
                            ? const Icon(Icons.user, size: 40)
                            : Image.file(
                            File(userAccount!.picture!),
                            width: 40,
                            height: 40,
                            frameBuilder: (context, child, frame, wasAsync) =>
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(64.0),
                                  child: child,
                                ),
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.user, size: 40);
                            }
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          userAccount!.displayName,
                          style: Theme.of(context).textTheme.displaySmall,
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
                          dimension: 35,
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
                      child: const Icon(Icons.powerOff, size: 24),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.errorContainer,
                        foregroundColor: coloredTextTheme.labelMedium!.color,
                      ),
                      onPressed: () {}
                    ),
                    OutlinedButton(
                      child: const Icon(Icons.refresh, size: 24),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                        foregroundColor: coloredTextTheme.labelMedium!.color,
                      ),
                      onPressed: () {}
                    ),
                    ...(userAccount != null
                      ? [
                          OutlinedButton(
                            child: const Icon(Icons.xmark, size: 24), // TODO: use a proper logout logo when that exists
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: coloredTextTheme.labelMedium!.color,
                            ),
                            onPressed: () =>
                              Navigator.popUntil(context, ModalRoute.withName('/')),
                          ),
                          OutlinedButton(
                            child: const Icon(Icons.lock, size: 24),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                              foregroundColor: coloredTextTheme.labelMedium!.color,
                            ),
                            onPressed: () {}
                          ),
                          OutlinedButton(
                            child: const Icon(Icons.gears, size: 24),
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
