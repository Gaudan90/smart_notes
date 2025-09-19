import 'package:flutter/material.dart';
import '../theme/color_picker_painter.dart';
import '../theme/theme_provider.dart';

class ThemeSettingsView extends StatefulWidget {
  final ThemeProvider themeProvider;

  const ThemeSettingsView({super.key, required this.themeProvider});

  @override
  State<ThemeSettingsView> createState() => _ThemeSettingsViewState();
}

class _ThemeSettingsViewState extends State<ThemeSettingsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  final TextEditingController _customColorController = TextEditingController();
  Color _selectedCustomColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _customColorController.dispose();
    super.dispose();
  }

  void _selectColor(Color color) {
    _controller.forward(from: 0);
    widget.themeProvider.setPrimaryColor(color);
  }

  void _showCustomColorDialog() {
    double touchX = 0.5;
    double touchY = 0.5;
    const double pickerWidth = 250.0;
    const double pickerHeight = 150.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aggiungi Colore Personalizzato'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _customColorController,
                decoration: const InputDecoration(
                  labelText: 'Nome colore',
                  hintText: 'Es: Azzurro cielo',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: pickerWidth,
                height: pickerHeight,
                child: StatefulBuilder(
                  builder: (context, setDialogState) {
                    return GestureDetector(
                      onPanStart: (details) {
                        setDialogState(() {
                          touchX = (details.localPosition.dx / pickerWidth).clamp(0.0, 1.0);
                          touchY = (details.localPosition.dy / pickerHeight).clamp(0.0, 1.0);

                          final hue = touchX * 360;
                          final saturation = 1.0;
                          final lightness = 0.3 + (1 - touchY) * 0.5;

                          _selectedCustomColor = HSLColor.fromAHSL(
                            1.0, hue, saturation, lightness,
                          ).toColor();
                        });
                      },
                      onPanUpdate: (details) {
                        setDialogState(() {
                          touchX = (details.localPosition.dx / pickerWidth).clamp(0.0, 1.0);
                          touchY = (details.localPosition.dy / pickerHeight).clamp(0.0, 1.0);

                          final hue = touchX * 360;
                          final saturation = 1.0;
                          final lightness = 0.3 + (1 - touchY) * 0.5;

                          _selectedCustomColor = HSLColor.fromAHSL(
                            1.0, hue, saturation, lightness,
                          ).toColor();
                        });
                      },
                      onTapDown: (details) {
                        setDialogState(() {
                          touchX = (details.localPosition.dx / pickerWidth).clamp(0.0, 1.0);
                          touchY = (details.localPosition.dy / pickerHeight).clamp(0.0, 1.0);

                          final hue = touchX * 360;
                          final saturation = 1.0;
                          final lightness = 0.3 + (1 - touchY) * 0.5;

                          _selectedCustomColor = HSLColor.fromAHSL(
                            1.0, hue, saturation, lightness,
                          ).toColor();
                        });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          children: [
                            CustomPaint(
                              painter: ColorPickerPainter(),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            Positioned(
                              left: (touchX * pickerWidth) - 20,
                              top: (touchY * pickerHeight) - 20,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _selectedCustomColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_customColorController.text.isNotEmpty) {
                widget.themeProvider.addCustomColor(
                  _customColorController.text,
                  _selectedCustomColor,
                );
                Navigator.pop(context);
                _customColorController.clear();
              }
            },
            child: const Text('Aggiungi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final _ = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalizza Tema'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modalità tema
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modalità Tema',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SegmentedButton<ThemeMode>(
                      selected: {widget.themeProvider.themeMode},
                      onSelectionChanged: (Set<ThemeMode> modes) {
                        widget.themeProvider.setThemeMode(modes.first);
                      },
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode),
                          label: Text('Chiaro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode),
                          label: Text('Scuro'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.auto_mode),
                          label: Text('Sistema'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Colore primario
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Colore Tema',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: _showCustomColorDialog,
                          tooltip: 'Aggiungi colore personalizzato',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: widget.themeProvider.availableColors.entries.map((entry) {
                        final isSelected = widget.themeProvider.primaryColor.value == entry.value.value;
                        return GestureDetector(
                          onTap: () => _selectColor(entry.value),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: isSelected ? 60 : 50,
                            height: isSelected ? 60 : 50,
                            decoration: BoxDecoration(
                              color: entry.value,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onSurface
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: entry.value.withValues(alpha: 0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ] : [],
                            ),
                            child: isSelected
                                ? ScaleTransition(
                              scale: _scaleAnimation,
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 24,
                              ),
                            )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Anteprima
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Anteprima',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.palette,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Colore Primario',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: const Text('Bottone'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  child: const Text('Outlined'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}