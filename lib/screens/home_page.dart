import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/material.dart';
import '../screens/connected_screen.dart';
import '../widgets/scan_button.dart';
import '../widgets/device_list.dart';
import '../widgets/connection_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _bluetoothClassicPlugin = BluetoothClassic();
  List<Device> _devices = [];
  bool _scanning = false;
  Device? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await _bluetoothClassicPlugin.initPermissions();
  }

  Future<void> _scanDevices() async {
    if (_scanning) {
      await _bluetoothClassicPlugin.stopScan();
      setState(() {
        _scanning = false;
      });
    } else {
      setState(() {
        _devices = [];
        _scanning = true;
      });
      
      await _bluetoothClassicPlugin.startScan();
      _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (device) {
          setState(() {
            if (!_devices.contains(device)) {
              _devices = [..._devices, device];
            }
          });
        },
      );
    }
  }

  Future<void> _connectToDevice() async {
    if (_selectedDevice != null) {
      await _bluetoothClassicPlugin.connect(
        _selectedDevice!.address,
        "00001101-0000-1000-8000-00805f9b34fb",
      );
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConnectedScreen(device: _selectedDevice!),
          ),
        );
      }
    }
  }

  Future<void> _disconnect() async {
    await _bluetoothClassicPlugin.disconnect();
    setState(() {
      _selectedDevice = null;
    });
  }

  void _onDeviceSelected(Device device) {
    setState(() {
      _selectedDevice = device;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CRANE',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ScanButton(
                scanning: _scanning,
                onPressed: _scanDevices,
              ),
              const SizedBox(height: 20),
              const Text(
                'SELECT DEVICE',
                style: TextStyle(color: Colors.grey),
              ),
              DeviceList(
                devices: _devices,
                selectedDevice: _selectedDevice,
                onDeviceSelected: _onDeviceSelected,
              ),
              const SizedBox(height: 20),
              ConnectionButtons(
                selectedDevice: _selectedDevice,
                onConnect: _connectToDevice,
                onDisconnect: _disconnect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}