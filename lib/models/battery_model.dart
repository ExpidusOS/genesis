import 'dart:collection';
import 'package:event/event.dart';
import 'package:gokai/gokai.dart';
import 'package:gokai/devices/power.dart';
import 'package:gokai/services.dart';
import 'package:flutter/foundation.dart';

class BatteryModel extends ChangeNotifier {
  final GokaiPowerManager powerManager;
  final List<GokaiPowerDevice> _items = [];

  BatteryModel(GokaiContext context)
    : powerManager = context.services['PowerManager'] as GokaiPowerManager {
    powerManager.onChange.subscribe(_onChange);
    _onChange(null);
  }

  UnmodifiableListView<GokaiPowerDevice> get items => UnmodifiableListView(_items);
  UnmodifiableListView<GokaiPowerDevice> get integratedItems => UnmodifiableListView(_items.where((e) => e.isIntegrated));

  static Future<BatteryModel> init() async =>
    BatteryModel(await GokaiContext().init());

  void _onChange(Value<String?>? args) {
    powerManager.getAll().then((value) {
      _items.clear();
      _items.addAll(value);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    powerManager.onChange.unsubscribe(_onChange);
    super.dispose();
  }
}
