import 'dart:collection';
import 'package:expidus/expidus.dart';
import 'package:flutter/foundation.dart';

enum NetworkDeviceType { cell, wifi, eth, bridge, tun, bluetooth, unknown }

enum NetworkDeviceStatus {
  unavailable,
  disconnected,
  connecting,
  unauthorized,
  active,
  failed,
  unknown,
}

class AccessPointNetworkConnection {
  const AccessPointNetworkConnection({required this.ssid});

  final List<int> ssid;

  Future<String> getPasskey() {
    return Future.error(Exception('Not implemented'));
  }

  Future<void> setPasskey(String psk) {
    return Future.error(Exception('Not implemented'));
  }
}

abstract class NetworkAccessPoint extends ChangeNotifier {
  NetworkAccessPoint();

  double get strength => 0;
  List<int> get ssid => [];

  UnmodifiableListView<AccessPointNetworkConnection> get connections =>
      UnmodifiableListView([]);

  bool get requiresAuth => false;

  IconData get icon => switch (strength) {
    >= 0.75 => Icons.network_wifi,
    >= 0.6 => Icons.network_wifi_3_bar,
    >= 0.4 => Icons.network_wifi_2_bar,
    >= 0.1 => Icons.network_wifi_1_bar,
    _ => Icons.signal_wifi_statusbar_null,
  };

  Future<void> destroy() async {}

  Future<void> activateConnection(AccessPointNetworkConnection conn) {
    return Future.error(Exception('Not implemented'));
  }

  Future<AccessPointNetworkConnection> createConnection([String? psk]) {
    return Future.error(Exception('Not implemented'));
  }
}

abstract class WirelessNetworkDevice extends ChangeNotifier {
  WirelessNetworkDevice();

  UnmodifiableListView<NetworkAccessPoint> get accessPoints =>
      UnmodifiableListView([]);
  NetworkAccessPoint? get currentAccessPoint => null;

  Future<void> scan() async {}
  Future<void> destroy() async {}
}

abstract class NetworkDevice extends ChangeNotifier {
  NetworkDevice();

  NetworkDeviceType get type => NetworkDeviceType.unknown;
  NetworkDeviceStatus get status => NetworkDeviceStatus.unknown;

  String get hwAddress => '00:00:00:00:00:00';
  String get iface => '';

  bool get showInActionCenter =>
      type == NetworkDeviceType.wifi ||
      type == NetworkDeviceType.eth ||
      type == NetworkDeviceType.bridge ||
      type == NetworkDeviceType.tun;

  bool get showInPanel =>
      type == NetworkDeviceType.wifi || type == NetworkDeviceType.eth;

  IconData? get icon => switch (type) {
    NetworkDeviceType.wifi => switch (status) {
      NetworkDeviceStatus.unavailable => Icons.wifi_find,
      NetworkDeviceStatus.disconnected => Icons.wifi_off,
      NetworkDeviceStatus.connecting => Icons.wifi_protected_setup,
      NetworkDeviceStatus.unauthorized => Icons.wifi_password,
      NetworkDeviceStatus.failed => Icons.wifi_off,
      NetworkDeviceStatus.active =>
        wireless?.currentAccessPoint?.icon ?? Icons.wifi,
      NetworkDeviceStatus.unknown => Icons.wifi_off,
    },
    NetworkDeviceType.eth => Icons.lan,
    NetworkDeviceType.bridge => Icons.router,
    NetworkDeviceType.tun => Icons.domain,
    _ => null,
  };

  WirelessNetworkDevice? get wireless => null;

  Future<void> disconnect() async {}

  Future<void> destroy() async {}
}

abstract class NetworkingService extends ChangeNotifier {
  NetworkingService();

  UnmodifiableListView<NetworkDevice> get devices;

  Future<void> destroy() async {}
}
