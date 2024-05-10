import 'package:bloc/view/contact.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fetch Contact Nativly',
      home: PermissionExample(),
    );
  }
}

class PermissionExample extends StatefulWidget {
  @override
  _PermissionExampleState createState() => _PermissionExampleState();
}

class _PermissionExampleState extends State<PermissionExample> {
  bool _permissionsRequested = false;

  @override
  Widget build(BuildContext context) {
    if (!_permissionsRequested) {
      _requestPermissions();
      _permissionsRequested = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Permission Example')),
      body: Center(child: Text('Permission handling example')),
    );
  }

  Future<void> _requestPermissions() async {
    if (Theme.of(context).platform == TargetPlatform.android) {
      // Request Android permissions
      await _requestAndroidPermissions();
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Request iOS permissions
      await _requestiOSPermissions();
    }
  }

  Future<void> _requestAndroidPermissions() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      // Permission granted, you can now fetch contacts
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ContactFetchNatively()));
    } else {
      // Permission denied, handle the case gracefully
      print('Permission denied');
    }
  }

  Future<void> _requestiOSPermissions() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      // Permission granted, you can now fetch contacts
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => ContactFetchNatively()));
    } else {
      // Permission denied, handle the case gracefully
      print('Permission denied');
    }
  }
}
