import 'dart:io';
import 'package:flutter/foundation.dart';

Map<String, String> readOsRelease() {
  if (kIsWeb) return {};
  if (defaultTargetPlatform != TargetPlatform.linux) return {};

  return Map.fromEntries(File('/etc/os-release').readAsLinesSync().map((line) {
    final sp = line.split('=');
    return MapEntry(sp[0], sp[1].replaceAll('"', ''));
  }).toList());
}
