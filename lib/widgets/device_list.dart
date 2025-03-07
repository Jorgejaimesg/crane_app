import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';

class DeviceList extends StatelessWidget {
  final List<Device> devices;
  final Device? selectedDevice;
  final Function(Device) onDeviceSelected;

  const DeviceList({
    super.key,
    required this.devices,
    required this.selectedDevice,
    required this.onDeviceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          final isSelected = device == selectedDevice;
          return ListTile(
            title: Text(device.name ?? device.address),
            selected: isSelected,
            onTap: () => onDeviceSelected(device),
          );
        },
      ),
    );
  }
}