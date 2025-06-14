import 'dart:async';
import 'dart:collection';
import 'package:collection/collection.dart';
import 'package:dbus/dbus.dart';
import 'package:nm/nm.dart';
import '../networking.dart';

class LinuxAccessPointNetworkConnection extends AccessPointNetworkConnection {
  LinuxAccessPointNetworkConnection(this.conn, {required super.ssid});

  final NetworkManagerSettingsConnection conn;

  @override
  Future<String> getPasskey() async {
    final settings = await conn.getSettings();
    final type = (settings['connection']!['type']! as DBusString).value;
    final security = (settings[type]!['security']! as DBusString).value;

    final secrets = await conn.getSecrets(security);
    return (secrets[security]!['psk'] as DBusString).value;
  }

  @override
  Future<void> setPasskey(String psk) async {
    final settings = await conn.getSettings();
    final type = (settings['connection']!['type']! as DBusString).value;
    final security =
        (settings[type]!['security'] as DBusString?)?.value ??
        '802-11-wireless-security';

    await conn.update({
      ...settings,
      security: {
        'auth-alg': DBusString('open'),
        'psk': DBusString(psk),
        'key-mgmt': DBusString('wpa-psk'),
      },
    });
  }
}

class LinuxNetworkAccessPoint extends NetworkAccessPoint {
  LinuxNetworkAccessPoint(this.wireless, this.accessPoint, this._connections);

  final LinuxWirelessNetworkDevice wireless;
  final NetworkManagerAccessPoint accessPoint;
  List<AccessPointNetworkConnection> _connections;

  @override
  UnmodifiableListView<AccessPointNetworkConnection> get connections =>
      UnmodifiableListView(_connections);

  @override
  double get strength => accessPoint.strength / 100;

  @override
  List<int> get ssid => accessPoint.ssid;

  @override
  bool get requiresAuth =>
      accessPoint.rsnFlags.indexOf(
        NetworkManagerWifiAccessPointSecurityFlag.keyManagementPsk,
      ) >
      -1;

  @override
  Future<void> activateConnection(AccessPointNetworkConnection conn) async {
    final lconn = conn as LinuxAccessPointNetworkConnection;
    await wireless.device.service.client.activateConnection(
      device: wireless.device.device,
      connection: lconn.conn,
      accessPoint: accessPoint,
    );
    wireless.device.notifyListeners();
  }

  @override
  Future<AccessPointNetworkConnection> createConnection([String? psk]) async {
    final conn = LinuxAccessPointNetworkConnection(
      await wireless.device.service.client.settings.addConnection({
        'connection': {
          'id': DBusString(String.fromCharCodes(ssid)),
          'interface-name': DBusString(wireless.device.iface),
          'type': DBusString('802-11-wireless'),
        },
        '802-11-wireless': {'ssid': DBusArray.byte(ssid)},
      }),
      ssid: ssid,
    );

    if (psk != null) {
      await conn.setPasskey(psk!);
    }

    _connections.add(conn);
    notifyListeners();
    return conn;
  }
}

class LinuxWirelessNetworkDevice extends WirelessNetworkDevice {
  LinuxWirelessNetworkDevice(this.device, this.wireless) : _accessPoints = [] {
    _propsChanged = wireless.propertiesChanged.listen((_) {
      for (final ap in _accessPoints) ap.destroy();
      _accessPoints = [];

      if (_currentAccessPoint != null) {
        _currentAccessPoint!.destroy();
        _currentAccessPoint = null;
      }

      _sync().then(
        (_) => notifyListeners(),
        onError: (e, trace) {
          print('$e $trace');
        },
      );
    });

    _sync().then(
      (_) => notifyListeners(),
      onError: (e, trace) {
        print('$e $trace');
      },
    );
  }

  final LinuxNetworkDevice device;
  final NetworkManagerDeviceWireless wireless;

  late StreamSubscription<List<String>> _propsChanged;

  List<NetworkAccessPoint> _accessPoints;

  @override
  UnmodifiableListView<NetworkAccessPoint> get accessPoints =>
      UnmodifiableListView(_accessPoints);

  NetworkAccessPoint? _currentAccessPoint;

  @override
  NetworkAccessPoint? get currentAccessPoint => _currentAccessPoint;

  Future<void> _sync() async {
    for (final ap in wireless.accessPoints) {
      final a = await _createAccessPoint(ap);
      _accessPoints.add(a);
    }

    if (wireless.activeAccessPoint != null) {
      _currentAccessPoint = await _createAccessPoint(
        wireless.activeAccessPoint!,
      );
    }
  }

  Future<NetworkAccessPoint> _createAccessPoint(
    NetworkManagerAccessPoint ap,
  ) async {
    var connections = <AccessPointNetworkConnection>[];
    for (final conn in device.device.availableConnections) {
      final settings = await conn.getSettings();
      final type = (settings['connection']!['type']! as DBusString).value;
      final ssid = (settings[type]!['ssid']! as DBusArray).children
          .map((i) => (i as DBusByte).value)
          .toList();

      if (ssid.equals(ap.ssid)) {
        connections.add(LinuxAccessPointNetworkConnection(conn, ssid: ssid));
      }
    }
    return LinuxNetworkAccessPoint(this, ap, connections);
  }

  @override
  Future<void> scan() => wireless.requestScan();

  @override
  Future<void> destroy() async {
    await super.destroy();
    _propsChanged.cancel();
    await _currentAccessPoint?.destroy();
    for (final ap in _accessPoints) ap.destroy();
  }
}

class LinuxNetworkDevice extends NetworkDevice {
  LinuxNetworkDevice(this.service, this.device) {
    _propsChanged = device.propertiesChanged.listen((_) {
      notifyListeners();
    });
  }

  final LinuxNetworkingService service;
  final NetworkManagerDevice device;
  late StreamSubscription<List<String>> _propsChanged;

  @override
  NetworkDeviceType get type => switch (device.deviceType) {
    NetworkManagerDeviceType.ethernet => NetworkDeviceType.eth,
    NetworkManagerDeviceType.wifi => NetworkDeviceType.wifi,
    NetworkManagerDeviceType.modem => NetworkDeviceType.cell,
    NetworkManagerDeviceType.tun => NetworkDeviceType.tun,
    NetworkManagerDeviceType.bridge => NetworkDeviceType.bridge,
    NetworkManagerDeviceType.bluetooth => NetworkDeviceType.bluetooth,
    _ => NetworkDeviceType.unknown,
  };

  @override
  NetworkDeviceStatus get status => switch (device.state) {
    NetworkManagerDeviceState.unavailable => NetworkDeviceStatus.unavailable,
    NetworkManagerDeviceState.prepare => NetworkDeviceStatus.connecting,
    NetworkManagerDeviceState.config => NetworkDeviceStatus.connecting,
    NetworkManagerDeviceState.needAuth => NetworkDeviceStatus.unauthorized,
    NetworkManagerDeviceState.ipConfig => NetworkDeviceStatus.connecting,
    NetworkManagerDeviceState.ipCheck => NetworkDeviceStatus.connecting,
    NetworkManagerDeviceState.activated => NetworkDeviceStatus.active,
    NetworkManagerDeviceState.deactivating => NetworkDeviceStatus.disconnected,
    NetworkManagerDeviceState.failed => NetworkDeviceStatus.failed,
    _ => NetworkDeviceStatus.unknown,
  };

  @override
  String get hwAddress => device.hwAddress;

  @override
  String get iface => device.interface;

  WirelessNetworkDevice? _wireless;

  @override
  WirelessNetworkDevice? get wireless {
    if (device.wireless != null && _wireless == null) {
      _wireless = LinuxWirelessNetworkDevice(this, device.wireless!);
    }
    return _wireless;
  }

  @override
  Future<void> disconnect() => device.disconnect();

  @override
  Future<void> destroy() async {
    await super.destroy();
    _propsChanged.cancel();
    await _wireless?.destroy();
  }
}

class LinuxNetworkingService extends NetworkingService {
  LinuxNetworkingService(this.client) : _devices = [] {
    _devices = client.devices
        .map((dev) => LinuxNetworkDevice(this, dev))
        .toList();

    _deviceAdded = client.deviceAdded.listen((dev) {
      _devices.add(LinuxNetworkDevice(this, dev));
      notifyListeners();
    });

    _deviceRemoved = client.deviceRemoved.listen((dev) {
      final d = _devices.firstWhere(
        (d) => (d as LinuxNetworkDevice).device == dev,
      );
      _devices.remove(d);
      d.destroy();
      notifyListeners();
    });
  }

  final NetworkManagerClient client;
  late StreamSubscription<NetworkManagerDevice> _deviceAdded;
  late StreamSubscription<NetworkManagerDevice> _deviceRemoved;

  List<NetworkDevice> _devices;
  UnmodifiableListView<NetworkDevice> get devices =>
      UnmodifiableListView(_devices);

  @override
  Future<void> destroy() async {
    await super.destroy();
    _deviceAdded.cancel();
    _deviceRemoved.cancel();
    for (final dev in _devices) await dev.destroy();
    await client.close();
  }

  static Future<NetworkingService> create() async {
    var client = NetworkManagerClient();
    await client.connect();
    return LinuxNetworkingService(client);
  }
}
