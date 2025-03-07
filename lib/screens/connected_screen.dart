import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import 'height_screen.dart';
import 'twist_screen.dart';

class ConnectedScreen extends StatefulWidget {
  final Device device;

  const ConnectedScreen({super.key, required this.device});

  @override
  State<ConnectedScreen> createState() => _ConnectedScreenState();
}

class _ConnectedScreenState extends State<ConnectedScreen> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  bool isConnected = true;

  Future<void> _sendCommand(String command) async {
    try {
      await _bluetoothClassicPlugin.write(command);
    } catch (e) {
      debugPrint('Error sending command: $e');
    }
  }

  Widget _buildControlButton(String command, IconData icon, {double size = 60}) {
    return GestureDetector(
      onTapDown: (_) => _sendCommand(command),
      onTapUp: (_) => _sendCommand('40'),
      onTapCancel: () => _sendCommand('40'),
      child: Container(
        width: size,
        height: size,
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
          size: size * 0.5,
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'CRANE CONTROL',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Switch(
                    value: isConnected,
                    onChanged: (value) async {
                      if (!value) {
                        await _bluetoothClassicPlugin.disconnect();
                        if (mounted) {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                        }
                      }
                    },
                    activeColor: Colors.green,
                    activeTrackColor: Colors.grey,
                  ),
                ],
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
              
              // Control Pad
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      _buildControlButton('14', Icons.north_west),
                      const SizedBox(height: 20),
                      _buildControlButton('12', Icons.west),
                      const SizedBox(height: 20),
                      _buildControlButton('16', Icons.south_west),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      _buildControlButton('10', Icons.north),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TwistScreen(device: widget.device),
                            ),
                          );
                        },
                        child: Container(
                          width: 70,
                          height: 70,
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
                            size: 35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildControlButton('11', Icons.south),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Column(
                    children: [
                      _buildControlButton('15', Icons.north_east),
                      const SizedBox(height: 20),
                      _buildControlButton('13', Icons.east),
                      const SizedBox(height: 20),
                      _buildControlButton('17', Icons.south_east),
                    ],
                  ),
                ],
              ),
              
              const Spacer(),
              
              // Nuevos botones adicionales
              Row(
                children: [
                  Expanded(
                    child: _buildControlButton('19', Icons.rotate_left),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildControlButton('18', Icons.rotate_right),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Height Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => HeightScreen(device: widget.device),
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
                  'Height',
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