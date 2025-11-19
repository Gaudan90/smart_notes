import 'package:flutter/material.dart';
import 'package:smart_notes/controllers/pin_security_presenter.dart';
import '../../screens/password_generator_view.dart';
import '../../screens/pin_setup_view.dart';
import '../../screens/pin_unlock_view.dart';

// Widget che decide automaticamente quale schermata mostrare
// in base allo stato di sicurezza e autenticazione
class PasswordSecurityGate extends StatefulWidget {
  const PasswordSecurityGate({super.key});

  @override
  State<PasswordSecurityGate> createState() => _PasswordSecurityGateState();
}

class _PasswordSecurityGateState extends State<PasswordSecurityGate> {
  final _manager = PinSecurityPresenter();
  bool _isLoading = true;
  Widget? _targetScreen;

  @override
  void initState() {
    super.initState();
    _determineScreen();
  }

  Future<void> _determineScreen() async {
    final isSetupComplete = await _manager.isSetupComplete();

    if (!isSetupComplete) {
      setState(() {
        _targetScreen = const PinSetupView();
        _isLoading = false;
      });
    } else if (_manager.isUnlocked) {
      setState(() {
        _targetScreen = const PasswordGeneratorView();
        _isLoading = false;
      });
    } else {
      setState(() {
        _targetScreen = const PinUnlockView();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Password Sicure')),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return _targetScreen!;
  }
}