import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EmojiIcons {
  static const List<IconData> commonIcons = [
    Icons.cake,
    Icons.school,
    Icons.flight,
    Icons.celebration,
    Icons.favorite,
    Icons.emoji_events,
    Icons.calendar_today,
    Icons.ads_click,
    Icons.forest,
    Icons.star,
    Icons.beach_access,
    Icons.card_giftcard,
    Icons.theater_comedy,
    Icons.music_note,
    Icons.sports_soccer,
    Icons.directions_run,
    Icons.work,
    Icons.medical_services,
  ];

  // Chiavi di traduzione per i nomi delle icone
  static const List<String> _iconNameKeys = [
    'icon_birthday',
    'icon_graduation',
    'icon_trip',
    'icon_party',
    'icon_heart',
    'icon_award',
    'icon_date',
    'icon_goal',
    'icon_christmas',
    'icon_star',
    'icon_beach',
    'icon_gift',
    'icon_theater',
    'icon_music',
    'icon_soccer',
    'icon_running',
    'icon_work',
    'icon_medicine',
  ];

  /// Ritorna i nomi delle icone tradotti
  static List<String> get iconNames =>
      _iconNameKeys.map((key) => key.tr()).toList();

  /// Ritorna il nome tradotto per un indice specifico
  static String getIconName(int index) {
    if (index >= 0 && index < _iconNameKeys.length) {
      return _iconNameKeys[index].tr();
    }
    return '';
  }

  static IconData? getIconFromCodePoint(String? codePointString) {
    if (codePointString == null) return null;

    final codePoint = int.tryParse(codePointString);
    if (codePoint == null) return null;

    for (var icon in commonIcons) {
      if (icon.codePoint == codePoint) {
        return icon;
      }
    }

    return null;
  }
}