import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';

class ConnectionButtons extends StatelessWidget {
  final Device? selectedDevice;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  const ConnectionButtons({
    super.key,
    required this.selectedDevice,
    required this.onConnect,
    required this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: selectedDevice != null ? onConnect : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text('CONECT'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: selectedDevice != null ? onDisconnect : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            disabledBackgroundColor: Colors.grey,
          ),
          child: const Text('DISCONNECT'),
        ),
      ],
    );
  }
}