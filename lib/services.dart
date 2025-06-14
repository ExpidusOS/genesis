import 'package:flutter/foundation.dart';
import 'services/fallback/networking.dart';
import 'services/linux/networking.dart';
import 'services/networking.dart';
export 'services/networking.dart';

typedef ServiceFactoryCallback<T> = Future<T> Function();

class SystemServices {
  const SystemServices.linux()
    : createNetworking = LinuxNetworkingService.create;
  const SystemServices.fallback()
    : createNetworking = FallbackNetworkingService.create;

  final ServiceFactoryCallback<NetworkingService> createNetworking;

  static SystemServices create() {
    if (!kIsWeb) {
      return switch (defaultTargetPlatform) {
        TargetPlatform.linux => const SystemServices.linux(),
        _ => const SystemServices.fallback(),
      };
    }
    return const SystemServices.fallback();
  }
}
