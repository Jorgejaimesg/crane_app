import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'twist_screen.dart';

class RotateDirectionScreen2 extends StatefulWidget {
  final int currentDegrees;
  final Device device;

  const RotateDirectionScreen2({
    super.key, 
    required this.currentDegrees,
    required this.device,
  });

  @override
  State<RotateDirectionScreen2> createState() => _RotateDirectionScreen2State();
}

class _RotateDirectionScreen2State extends State<RotateDirectionScreen2> {
  final _bluetoothClassicPlugin = BluetoothClassic();

  Future<void> _sendCommand(String command) async {
    try {
      await _bluetoothClassicPlugin.write(command);
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  String _getCommandValue(String position) {
    bool isPositive = widget.currentDegrees > 0;
    
    switch(position) {
      case 'topRight':
        return isPositive ? '76' : '86';
      case 'topMiddle':
        return isPositive ? '71' : '81';
      case 'topLeft':
        return isPositive ? '75' : '85';
      case 'middleRight':
        return isPositive ? '74' : '84';
      case 'middleLeft':
        return isPositive ? '73' : '83';
      case 'bottomRight':
        return isPositive ? '77' : '87';
      case 'bottomMiddle':
        return isPositive ? '72' : '82';
      case 'bottomLeft':
        return isPositive ? '78' : '88';
      default:
        return '40';
    }
  }

  Widget _buildControlButton(String position, IconData icon) {
    return GestureDetector(
      onTapDown: (_) => _sendCommand(_getCommandValue(position)),
      onTapUp: (_) => _sendCommand('40'),
      onTapCancel: () => _sendCommand('40'),
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
        child: Icon(
          icon,
          color: Colors.white,
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
                'CONTROL #2',
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
              
              // Control Pad with Degrees in Center
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton('topLeft', Icons.north_west),
                      const SizedBox(width: 20),
                      _buildControlButton('topMiddle', Icons.north),
                      const SizedBox(width: 20),
                      _buildControlButton('topRight', Icons.north_east),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Middle row with degrees
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton('middleLeft', Icons.west),
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${widget.currentDegrees}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      _buildControlButton('middleRight', Icons.east),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // Bottom row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildControlButton('bottomLeft', Icons.south_west),
                      const SizedBox(width: 20),
                      _buildControlButton('bottomMiddle', Icons.south),
                      const SizedBox(width: 20),
                      _buildControlButton('bottomRight', Icons.south_east),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Go Back Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TwistScreen(
                        device: widget.device,
                        initialDegrees: widget.currentDegrees,
                      ),
                    ),
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
