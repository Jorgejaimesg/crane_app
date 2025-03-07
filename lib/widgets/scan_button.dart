import 'package:flutter/material.dart';

class ScanButton extends StatelessWidget {
  final bool scanning;
  final VoidCallback onPressed;

  const ScanButton({
    super.key,
    required this.scanning,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[900],
      ),
      child: Text(scanning ? 'Stop scan' : 'Scan devices'),
    );
  }
}