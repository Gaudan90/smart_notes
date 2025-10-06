import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import '../data/alarm_manager.dart';
import '../states/alarm_model.dart';

class AlarmOverlay extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onDismiss;

  const AlarmOverlay({
    super.key,
    required this.alarm,
    required this.onDismiss,
  });

  @override
  State<AlarmOverlay> createState() => _AlarmOverlayState();
}

class _AlarmOverlayState extends State<AlarmOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _timeTimer;
  String _currentTime = '';
  bool _audioStarted = false;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _updateTime();
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());

    // AVVIA L'AUDIO IMMEDIATAMENTE
    _startAlarmSound();
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _currentTime = '${now.hour.toString().padLeft(2, '0')}'
          ':${now.minute.toString().padLeft(2, '0')}';
    });
  }

  Future<void> _startAlarmSound() async {
    if (_audioStarted) return;
    _audioStarted = true;

    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/alarm.mp3'));
      print('AlarmOverlay: Audio avviato');
    } catch (e) {
      print('AlarmOverlay: Errore audio: $e');
    }
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    widget.onDismiss();
  }

  Future<void> _snoozeAlarm() async {
    await _audioPlayer.stop();

    // Aggiungi snooze di 5 minuti tramite AlarmManager
    final AlarmManager alarmManager = AlarmManager();
    await alarmManager.snoozeAlarm(widget.alarm.id, 5);

    widget.onDismiss();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sveglia posticipata di 5 minuti'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.blue.shade900,
                Colors.purple.shade900,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _pulseAnimation,
                child: Icon(
                  Icons.alarm,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 40),

              Text(
                _currentTime,
                style: const TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w200,
                  color: Colors.white,
                  letterSpacing: 8,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                widget.alarm.title,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white70,
                ),
              ),

              const SizedBox(height: 80),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _snoozeAlarm,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white54, width: 2),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.snooze,
                                color: Colors.white,
                                size: 40,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'POSPONI',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _stopAlarm,
                        borderRadius: BorderRadius.circular(100),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red,
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.alarm_off,
                                color: Colors.white,
                                size: 50,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'FERMA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    _timeTimer?.cancel();
    super.dispose();
  }
}