import 'package:flutter/foundation.dart';

class ListNotifier<T> extends ValueNotifier<List<T>> {
  ListNotifier(List<T> value) : super(value);

  int get length => value.length;
  bool get isEmpty => value.isEmpty;
  bool get isNotEmpty => value.isNotEmpty;

  void add(T item, {bool notify = true}) {
    value.add(item);
    if (notify) notifyListeners();
  }

  bool remove(Object? item, {bool notify = true}) {
    final changed = value.remove(item);
    if (changed && notify) notifyListeners();
    return changed;
  }

  void addAll(Iterable<T> iterable, {bool Function(T element)? add, bool notify = true}) {
    if (add != null) {
      for (final element in iterable) {
        if (add(element)) {
          value.add(element);
        }
      }
    } else {
      value.addAll(iterable);
    }
    if (notify) notifyListeners();
  }

  void clear({bool notify = true}) {
    value.clear();
    if (notify) notifyListeners();
  }

  void insert(int index, T element, {bool notify = true}) {
    value.insert(index, element);
    if (notify) notifyListeners();
  }

  void insertAll(int index, Iterable<T> iterable, {bool notify = true}) {
    value.insertAll(index, iterable);
    if (notify) notifyListeners();
  }

  void removeWhere(bool Function(T element) test, {bool notify = true}) {
    value.removeWhere(test);
    if (notify) notifyListeners();
  }

  T operator [](int index) {
    return value[index];
  }

  void operator []=(int index, T element) {
    if (value[index] != element) {
      value[index] = element;
      notifyListeners();
    }
  }

  void sort(int Function(T a, T b) compare, {bool notify = true}) {
    value.sort(compare);
    if (notify) notifyListeners();
  }

  void triggerNotify() => notifyListeners();
}
