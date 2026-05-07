import 'package:flutter/material.dart';

class TabHistoryController extends ChangeNotifier {
  final List<int> _history = <int>[0];

  int get currentIndex => _history.last;

  List<int> get history => List.unmodifiable(_history);

  bool get canGoBack => _history.length > 1;

  void push(int index) {
    if (_history.isNotEmpty && _history.last == index) return;

    _history.add(index);
    notifyListeners();
  }

  int? pop() {
    if (!canGoBack) return null;

    _history.removeLast();
    notifyListeners();

    return _history.last;
  }

  void reset(int index) {
    _history
      ..clear()
      ..add(index);

    notifyListeners();
  }
}
