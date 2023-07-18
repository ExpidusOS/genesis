import 'dart:collection';

import 'package:gokai/gokai.dart';
import 'package:gokai/services.dart';
import 'package:gokai/view/window.dart';
import 'package:flutter/foundation.dart';

class WindowViewModel extends ChangeNotifier {
  final GokaiWindowManager windowManager;
  final List<GokaiWindow> _items = [];

  WindowViewModel(GokaiContext context)
    : windowManager = context.services['WindowManager'] as GokaiWindowManager {
    windowManager.onChange.add(_onChange);
    windowManager.onMapped.add(_onMapped);
    _onChange();
  }

  UnmodifiableListView<GokaiWindow> get items => UnmodifiableListView(_items);
  UnmodifiableListView<GokaiWindow> get activeFirstItems => UnmodifiableListView(_items..sort((a, b) => a.isActive == b.isActive ? 0 : -1));
  UnmodifiableListView<GokaiWindow> get active => UnmodifiableListView(_items.where((e) => e.isActive));

  static Future<WindowViewModel> init() async =>
    WindowViewModel(await GokaiContext().init());

  void refresh() => _onChange();

  void _onChange() {
    _items.clear();
    notifyListeners();

    print(windowManager);

    windowManager.getViewable().then((value) {
      _items.clear();
      _items.addAll(value);
      notifyListeners();
    });
  }

  void _onMapped(String id) => _onChange();

  @override
  void dispose() {
    windowManager.onChange.remove(_onChange);
    windowManager.onMapped.remove(_onMapped);
    super.dispose();
  }
}