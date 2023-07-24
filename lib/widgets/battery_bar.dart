import 'package:genesis_shell/models.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:provider/provider.dart';
import 'battery_icon.dart';

class BatteryBar extends StatelessWidget {
  const BatteryBar({
    super.key,
    this.direction = Axis.horizontal,
  });

  final Axis direction;

  @override
  Widget build(BuildContext context) =>
    Consumer<BatteryModel>(
      builder: (context, model, child) {
        if (model.integratedItems.isEmpty) {
          return const SizedBox();
        }

        return Flex(
          direction: direction,
          children: model.integratedItems.map(
            (device) => BatteryIcon(device: device)
          ).toList(),
        );
      },
    );
}
