/// accessibilità per utenti con deficit di visione cromatica.
enum ColorBlindMode {
  /// Nessun filtro applicato
  none,

  /// Protanopia — deficit del rosso (~1% della popolazione maschile)
  protanopia,

  /// Deuteranopia — deficit del verde (~1% della popolazione maschile)
  deuteranopia,

  /// Tritanopia — deficit del blu (~0.003% della popolazione)
  tritanopia,
}