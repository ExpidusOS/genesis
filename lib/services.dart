import 'package:flutter/foundation.dart';

import 'services/fallback/networking.dart';
import 'services/fallback/user.dart';

import 'services/linux/networking.dart';

import 'services/networking.dart';
import 'services/users.dart';

export 'services/networking.dart';
export 'services/users.dart';

typedef ServiceFactoryCallback<T> = Future<T> Function();

class SystemServices {
  const SystemServices.linux()
    : createNetworking = LinuxNetworkingService.create,
      createUser = FallbackUserService.create;
  const SystemServices.fallback()
    : createNetworking = FallbackNetworkingService.create,
      createUser = FallbackUserService.create;

  final ServiceFactoryCallback<NetworkingService> createNetworking;
  final ServiceFactoryCallback<UserService> createUser;

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
