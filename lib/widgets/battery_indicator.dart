import 'dart:async';
import 'package:genesis_shell/models.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:gokai/devices/power.dart';
import 'package:provider/provider.dart';

class BatteryIndicator extends StatefulWidget {
  const BatteryIndicator({
    super.key,
    required this.device,
    this.withIcon = true,
    this.withLabel = true,
  });

  final GokaiPowerDevice device;
  final bool withIcon;
  final bool withLabel;

  @override
  State<BatteryIndicator> createState() => _BatteryIndicatorState();
}

class _BatteryIndicatorState extends State<BatteryIndicator> {
  double _level = 0.0;
  bool _isCharging = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    _update();
    timer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _update();
    });
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
  }

  void _update() async {
    final level = await widget.device.level;
    final isCharging = await widget.device.isCharging;

    setState(() {
      _level = level;
      _isCharging = isCharging;
    });
  }

  Widget _buildIcon(BuildContext context) {
    IconData icon = Icons.batteryEmpty;
    if (_level == 1.0) icon = Icons.batteryFull;
    else if (_level <= 75) icon = Icons.batteryThreeQuarters;
    else if (_level <= 50) icon = Icons.batteryHalf;
    else if (_level <= 25) icon = Icons.batteryQuarter;
    else icon = Icons.batteryEmpty;
    return Icon(icon);
  }

  Widget _buildLabel(BuildContext context) {
    final label = (_level * 100).round();
    return Text('$label%');
  }

  @override
  Widget build(BuildContext context) =>
    Row(
      children: [
        if (widget.withIcon) _buildIcon(context),
        if (widget.withLabel) _buildLabel(context),
      ],
    );
}
