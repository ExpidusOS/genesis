import 'dart:collection';
import '../networking.dart';

class FallbackNetworkingService extends NetworkingService {
  FallbackNetworkingService();

  UnmodifiableListView<NetworkDevice> get devices => UnmodifiableListView([]);

  static Future<NetworkingService> create() async =>
      FallbackNetworkingService();
}
