import 'package:expidus/expidus.dart';
import 'package:flutter/foundation.dart';

abstract class UserService extends ChangeNotifier {
  UserService();

  Future<void> destroy() async {}
}
