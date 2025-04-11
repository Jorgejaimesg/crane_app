import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:crane_app/screens/connected_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'rotate_direction_screen.dart';
import 'rotate_direction_screen_2.dart';

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
  late int degreesTop;
  late int degreesBottom;
  Timer? _timerTop;
  Timer? _timerBottom;
  bool isRotatingRightTop = false;
  bool isRotatingLeftTop = false;
  bool isRotatingRightBottom = false;
  bool isRotatingLeftBottom = false;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    degreesTop = widget.initialDegrees ?? 0;
    degreesBottom = 0;
    _startRotationTimers();
  }

  @override
  void dispose() {
    _timerTop?.cancel();
    _timerBottom?.cancel();
    _passwordController.dispose();
    super.dispose();
  }

  void _startRotationTimers() {
    // Timer for top controls
    _timerTop = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (isRotatingRightTop && degreesTop < 90) {
        setState(() {
          degreesTop = (degreesTop + 1).clamp(-90, 90);
        });
      } else if (isRotatingLeftTop && degreesTop > -90) {
        setState(() {
          degreesTop = (degreesTop - 1).clamp(-90, 90);
        });
      }
    });

    // Timer for bottom controls
    _timerBottom = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (isRotatingRightBottom && !isApproachingLimit(1)) {
        setState(() {
          degreesBottom = (degreesBottom + 1).clamp(-90, 90);
        });
      } else if (isRotatingLeftBottom && !isApproachingLimit(-1)) {
        setState(() {
          degreesBottom = (degreesBottom - 1).clamp(-90, 90);
        });
      }
    });
  }

  // Check if approaching the limit (within 15 degrees of 180, -180, or 0)
  bool isApproachingLimit(int direction) {
    int totalDegrees = degreesTop + degreesBottom;
    
    // Check if approaching 180
    if (direction > 0 && totalDegrees > 165) {
      return true;
    }
    
    // Check if approaching -180
    if (direction < 0 && totalDegrees < -165) {
      return true;
    }
    
    // Check if approaching 0
    if ((direction > 0 && totalDegrees > -15 && totalDegrees < 0) ||
        (direction < 0 && totalDegrees < 15 && totalDegrees > 0)) {
      return true;
    }
    
    return false;
  }

  Future<void> _sendCommand(String command) async {
    try {
      await _bluetoothClassicPlugin.write(command);
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  // Show emergency password dialog
  Future<void> _showEmergencyDialog() async {
    _passwordController.clear();
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'EMERGENCY ACCESS',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                const Text('Enter password to access connected screen:'),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Password',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirm'),
              onPressed: () {
                if (_passwordController.text == '0000') {
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ConnectedScreen(device: widget.device),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Incorrect password'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopControlButton(String command, IconData icon, {bool isCenter = false}) {
    if (isCenter && degreesTop == 0) {
      return const SizedBox(width: 60, height: 60);
    }
    bool isDisabled = (command == '20' && degreesTop >= 90) || (command == '30' && degreesTop <= -90);
    return GestureDetector(
      onTapDown: (isCenter || isDisabled) ? null : (_) {
        _sendCommand(command);
        setState(() {
          if (command == '20') isRotatingRightTop = true;
          if (command == '30') isRotatingLeftTop = true;
        });
      },
      onTapUp: (isCenter || isDisabled) ? null : (_) {
        _sendCommand('40');
        setState(() {
          isRotatingRightTop = false;
          isRotatingLeftTop = false;
        });
      },
      onTapCancel: (isCenter || isDisabled) ? null : () {
        _sendCommand('40');
        setState(() {
          isRotatingRightTop = false;
          isRotatingLeftTop = false;
        });
      },
      onTap: isCenter && degreesTop != 0 ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RotateDirectionScreen(
              currentDegrees: degreesTop,
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

  Widget _buildBottomControlButton(String command, IconData icon, {bool isCenter = false}) {
    if (isCenter) {
      if (degreesBottom == 0) {
        return const SizedBox(width: 60, height: 60);
      }
      return GestureDetector(
        onTap: () {
          // Import rotate_direction_screen_2.dart at the top of the file
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RotateDirectionScreen2(
                currentDegrees: degreesBottom,
                device: widget.device,
              ),
            ),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.circle,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    }
    
    bool isDisabled = false;
    
    // Check individual limits
    if (command == '60' && degreesBottom >= 90) {
      isDisabled = true;
    } else if (command == '70' && degreesBottom <= -90) {
      isDisabled = true;
    }
    
    // Check combined limits
    if (command == '60' && isApproachingLimit(1)) {
      isDisabled = true;
    } else if (command == '70' && isApproachingLimit(-1)) {
      isDisabled = true;
    }
    
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) {
        _sendCommand(command);
        setState(() {
          if (command == '60') isRotatingRightBottom = true;
          if (command == '70') isRotatingLeftBottom = true;
        });
      },
      onTapUp: isDisabled ? null : (_) {
        _sendCommand('40');
        setState(() {
          isRotatingRightBottom = false;
          isRotatingLeftBottom = false;
        });
      },
      onTapCancel: isDisabled ? null : () {
        _sendCommand('40');
        setState(() {
          isRotatingRightBottom = false;
          isRotatingLeftBottom = false;
        });
      },
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
        child: Stack(
          children: [
            Padding(
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
                  
                  const SizedBox(height: 20),
                  
                  // Top row controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTopControlButton('30', Icons.rotate_left),
                      _buildTopControlButton('40', Icons.circle, isCenter: true),
                      _buildTopControlButton('20', Icons.rotate_right),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Top degrees display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Grades: $degreesTop',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bottom row controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildBottomControlButton('70', Icons.rotate_left),
                      _buildBottomControlButton('40', Icons.circle, isCenter: true),
                      _buildBottomControlButton('60', Icons.rotate_right),
                    ],
                  ),
                  
                  const SizedBox(height: 15),
                  
                  // Bottom degrees display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Grades: $degreesBottom',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  // Reduced spacer to move elements up
                  const Spacer(flex: 1),
                  
                  // Total degrees display - moved up
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Total Grades: ${degreesTop + degreesBottom}',
                      style: const TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  if (degreesTop == 0 && degreesBottom == 0)
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
                  
                  // Added extra space at the bottom to avoid overlap with emergency button
                  const SizedBox(height: 80),
                ],
              ),
            ),
            
            // Emergency button in bottom right corner
            Positioned(
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: _showEmergencyDialog,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
