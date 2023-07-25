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
    IconData icon = Icons.battery_unknown;
    if (_isCharging) icon = Icons.battery_charging_full;
    else {
      if (_level == 1.0) icon = Icons.battery_full;
      else if (_level <= 98) icon = Icons.battery_6_bar;
      else if (_level <= 84) icon = Icons.battery_5_bar;
      else if (_level <= 70) icon = Icons.battery_4_bar;
      else if (_level <= 56) icon = Icons.battery_3_bar;
      else if (_level <= 42) icon = Icons.battery_2_bar;
      else if (_level <= 28) icon = Icons.battery_1_bar;
      else if (_level <= 14) icon = Icons.battery_0_bar;
    }
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
