import 'package:flutter/material.dart';

/// Controller to track tab navigation history for custom swipe-back on root tabs.
class TabHistoryController extends ChangeNotifier {
  final List<int> _history = [0]; // Start with first tab

  int get currentIndex => _history.last;
  List<int> get history => List.unmodifiable(_history);

  void push(int index) {
    if (_history.isEmpty || _history.last != index) {
      _history.add(index);
      notifyListeners();
    }
  }

  bool canPop() => _history.length > 1;

  void pop() {
    if (canPop()) {
      _history.removeLast();
      notifyListeners();
    }
  }

  void reset(int index) {
    _history.clear();
    _history.add(index);
    notifyListeners();
  }
}
