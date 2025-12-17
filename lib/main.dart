import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'factories/screen_factory.dart';
import 'services/polling/navigator_poll_observer.dart'; // added to try and make polls are not used when leaving theyre coresponding page

Future<void> askPermissions() async {
  await Permission.camera.request();
  await Permission.microphone.request();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await askPermissions();
  runApp(const DWKApp());
}

class DWKApp extends StatelessWidget {
  const DWKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitale Wortkette Client',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: PermissionGate(
        child: ScreenFactory.createScreen(ScreenType.home),
      ),
      navigatorObservers: [
        StopPollingObserver(),
      ],
    );
  }
}

class PermissionGate extends StatefulWidget {
  final Widget child;

  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _permissionsGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    var cameraStatus = await Permission.camera.request();
    var micStatus    = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      setState(() => _permissionsGranted = true);
    } else if (cameraStatus.isPermanentlyDenied ||
               micStatus.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsGranted) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return widget.child;
  }
}
