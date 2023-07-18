import 'dart:collection';
import 'package:event/event.dart';
import 'package:gokai/gokai.dart';
import 'package:gokai/services.dart';
import 'package:gokai/view/window.dart';
import 'package:flutter/foundation.dart';

class WindowViewModel extends ChangeNotifier {
  final GokaiWindowManager windowManager;
  final List<GokaiWindow> _items = [];

  WindowViewModel(GokaiContext context)
    : windowManager = context.services['WindowManager'] as GokaiWindowManager {
    windowManager.onChange.subscribe(_onChange);
    _onChange(null);
  }

  UnmodifiableListView<GokaiWindow> get items => UnmodifiableListView(_items);
  UnmodifiableListView<GokaiWindow> get activeFirstItems => UnmodifiableListView(_items..sort((a, b) => a.isActive == b.isActive ? 0 : -1));
  UnmodifiableListView<GokaiWindow> get active => UnmodifiableListView(_items.where((e) => e.isActive));

  static Future<WindowViewModel> init() async =>
    WindowViewModel(await GokaiContext().init());

  void refresh() => _onChange(null);

  void _onChange(EventArgs? args) {
    _items.clear();
    notifyListeners();

    windowManager.getViewable().then((value) {
      _items.clear();
      _items.addAll(value);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    windowManager.onChange.unsubscribe(_onChange);
    super.dispose();
  }
}