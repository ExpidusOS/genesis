import 'dart:async';
import '../../power.dart';

class DummyPowerManager extends PowerManager {
  DummyPowerManager() : super();

  @override
  Stream<PowerDevice> get deviceAdded {
    return Stream.empty();
  }

  @override
  Stream<PowerDevice> get deviceRemoved {
    return Stream.empty();
  }

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  Future<List<PowerDevice>> devices() async {
    return List.empty();
  }

  @override
  Future<bool> canAction(PowerAction action) async {
    return false;
  }

  @override
  Future<void> doAction(PowerAction action) async {
    throw Exception('Unimplemented action: ${action.name}');
  }
}
