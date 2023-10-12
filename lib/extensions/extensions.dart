extension StringNullableExtensions on String? {
  bool get isEmpty => this == null || this == "";

  bool get isNotEmpty => this != null && this != "";
}

extension SetExtensions<T> on Set<T> {
  Set<T> without(T element) => where((current) => current != element).toSet();

  Set<T> copyAdd(T element) => {...this, element};

  Set<T> copyUpdate(T? from, T to) {
    remove(from);
    return copyAdd(to);
  }
}

extension MapExtensions<K, V> on Map<K, V>? {
  Map<K, V> copyAdd(K key, V value) => {...this ?? {}, key: value};

  Map<K, V> without(K key) => {...this ?? {}}..removeWhere((checkingKey, value) => checkingKey == key);

  Map<K, V> copyUpdate(K key, V value) {
    final currentValue = (this ?? {})[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(key, value);
  }

  Map<K, V> copyReplaceKey(K key, K newKey) {
    if (key == newKey) return {...this ?? {}};
    final self = (this ?? {});
    final currentValue = self[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(newKey, currentValue)..remove(key);
  }

  Map<K, V> copyReplaceValue(K key, K newKey, V newValue) {
    if (key == newKey) return copyUpdate(key, newValue);
    return copyAdd(newKey, newValue)..remove(key);
  }

  Map<K, V> copyModify(K key, V Function(V value) current) {
    final currentValue = (this ?? {})[key];
    if (currentValue == null) return this ?? {};
    return copyAdd(key, current(currentValue));
  }
}

extension ListExtensions<T> on List<T> {
  List<T> copyAdd(T element) => [...this, element];

  List<T> copyUpdate(T from, T to) => toSet().copyUpdate(from, to).toList();

  List<T> without(T element) => where((current) => current != element).toList();

  List<O> mapIndexed<O>(O Function(int index, T element) callback) {
    var index = 0;
    final returnList = <O>[];

    for (var element in this) {
      returnList.add(callback(index, element));
      index++;
    }

    return returnList;
  }
}
