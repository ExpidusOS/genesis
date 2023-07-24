import 'dart:async';
import 'package:genesis_shell/models.dart';
import 'package:libtokyo_flutter/libtokyo.dart';
import 'package:gokai/devices/power.dart';
import 'package:provider/provider.dart';

class BatteryIcon extends StatefulWidget {
  const BatteryIcon({
    super.key,
    required this.device,
  });

  final GokaiPowerDevice device;

  @override
  State<BatteryIcon> createState() => _BatteryIconState();
}

class _BatteryIconState extends State<BatteryIcon> {
  double _level = 0.0;
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
    setState(() {
      _level = level;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('$_level');
  }
}
