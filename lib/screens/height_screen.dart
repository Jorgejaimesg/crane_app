import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'dart:async';

// Variable global para almacenar la altura actual
double globalHeight = 2.00;

class HeightScreen extends StatefulWidget {
  final Device device;

  const HeightScreen({super.key, required this.device});

  @override
  State<HeightScreen> createState() => _HeightScreenState();
}

class _HeightScreenState extends State<HeightScreen> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  Timer? _timer;
  bool isMovingUp = false;
  bool isMovingDown = false;

  @override
  void initState() {
    super.initState();
    _startHeightUpdateTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startHeightUpdateTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isMovingUp && globalHeight < 3.00) {
        setState(() {
          globalHeight = (globalHeight + 0.01).clamp(2.00, 3.00);
        });
      } else if (isMovingDown && globalHeight > 2.00) {
        setState(() {
          globalHeight = (globalHeight - 0.01).clamp(2.00, 3.00);
        });
      }
    });
  }

  Future<void> _sendCommand(String command) async {
    try {
      await _bluetoothClassicPlugin.write(command);
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  Widget _buildControlButton(String command, IconData icon, bool isEnabled) {
    return GestureDetector(
      onTapDown: isEnabled ? (_) {
        _sendCommand(command);
        setState(() {
          if (command == '50') isMovingUp = true;
          if (command == '51') isMovingDown = true;
        });
      } : null,
      onTapUp: isEnabled ? (_) {
        _sendCommand('52');
        setState(() {
          isMovingUp = false;
          isMovingDown = false;
        });
      } : null,
      onTapCancel: isEnabled ? () {
        _sendCommand('52');
        setState(() {
          isMovingUp = false;
          isMovingDown = false;
        });
      } : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[900],
          shape: BoxShape.circle,
          boxShadow: isEnabled ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          icon,
          color: isEnabled ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canMoveUp = globalHeight < 3.00;
    bool canMoveDown = globalHeight > 2.00;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'HEIGHT CONTROL',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Device Name
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.device.name ?? widget.device.address,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Control Buttons
              _buildControlButton('50', Icons.keyboard_arrow_up, canMoveUp),
              const SizedBox(height: 40),
              _buildControlButton('51', Icons.keyboard_arrow_down, canMoveDown),
              
              const Spacer(),
              
              // Height Display
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Height: ${globalHeight.toStringAsFixed(2)}m',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Go Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[900],
                  minimumSize: const Size(double.infinity, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Go back to',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}