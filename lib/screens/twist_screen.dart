import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:crane_app/screens/connected_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'rotate_direction_screen.dart';

class TwistScreen extends StatefulWidget {
  final Device device;
  final int? initialDegrees;

  const TwistScreen({
    super.key, 
    required this.device,
    this.initialDegrees,
  });

  @override
  State<TwistScreen> createState() => _TwistScreenState();
}

class _TwistScreenState extends State<TwistScreen> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  late int degrees;
  Timer? _timer;
  bool isRotatingRight = false;
  bool isRotatingLeft = false;

  @override
  void initState() {
    super.initState();
    degrees = widget.initialDegrees ?? 0;
    _startRotationTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startRotationTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 42), (timer) {
      if (isRotatingRight && degrees < 90) {
        setState(() {
          degrees = (degrees + 1).clamp(-90, 90);
        });
      } else if (isRotatingLeft && degrees > -90) {
        setState(() {
          degrees = (degrees - 1).clamp(-90, 90);
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

  Widget _buildControlButton(String command, IconData icon, {bool isCenter = false}) {
    if (isCenter && degrees == 0) {
      return const SizedBox(width: 60, height: 60);
    }
    bool isDisabled = (command == '20' && degrees >= 90) || (command == '30' && degrees <= -90);
    return GestureDetector(
      onTapDown: (isCenter || isDisabled) ? null : (_) {
        _sendCommand(command);
        setState(() {
          if (command == '20') isRotatingRight = true;
          if (command == '30') isRotatingLeft = true;
        });
      },
      onTapUp: (isCenter || isDisabled) ? null : (_) {
        _sendCommand('40');
        setState(() {
          isRotatingRight = false;
          isRotatingLeft = false;
        });
      },
      onTapCancel: (isCenter || isDisabled) ? null : () {
        _sendCommand('40');
        setState(() {
          isRotatingRight = false;
          isRotatingLeft = false;
        });
      },
      onTap: isCenter && degrees != 0 ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RotateDirectionScreen(
              currentDegrees: degrees,
              device: widget.device,
            ),
          ),
        );
      } : null,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[700] : Colors.grey[900],
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: isDisabled ? Colors.grey : Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'ROTATE CONTROL',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
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
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton('30', Icons.rotate_left),
                  _buildControlButton('40', Icons.circle, isCenter: true),
                  _buildControlButton('20', Icons.rotate_right),
                ],
              ),
              
              const Spacer(),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Grades: $degrees',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              if (degrees == 0)
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConnectedScreen(device: widget.device),
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[900],
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'GO BACK',
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

