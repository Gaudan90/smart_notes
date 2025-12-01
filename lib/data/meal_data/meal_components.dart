class MealComponents {
  final String? breakfast;
  final String? first;
  final String? second;
  final String? side;
  final String? pizza;
  final String? dessert;

  MealComponents({
    this.breakfast,
    this.first,
    this.second,
    this.side,
    this.pizza,
    this.dessert,
  });

  // Converte in lista di stringhe per visualizzazione
  List<String> toDisplayList() {
    final items = <String>[];

    if (breakfast != null) items.add('🥐 $breakfast');
    if (pizza != null) {
      items.add('🍕 $pizza');
    } else {
      if (first != null) items.add('🍝 $first');
      if (second != null) items.add('🍖 $second');
      if (side != null) items.add('🥗 $side');
    }
    if (dessert != null) items.add('🍰 $dessert');

    return items;
  }

  bool get isEmpty =>
      breakfast == null &&
          first == null &&
          second == null &&
          side == null &&
          pizza == null &&
          dessert == null;
}