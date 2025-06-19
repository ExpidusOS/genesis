import '../users.dart';

class FallbackUserService extends UserService {
  FallbackUserService();

  static Future<UserService> create() async =>
    FallbackUserService();
}
