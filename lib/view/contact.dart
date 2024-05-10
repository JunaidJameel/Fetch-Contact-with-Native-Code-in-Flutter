import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ContactFetchNatively extends StatefulWidget {
  const ContactFetchNatively({super.key});

  @override
  State<ContactFetchNatively> createState() => _ContactFetchNativelyState();
}

class _ContactFetchNativelyState extends State<ContactFetchNatively> {
  List<Map<String, String>> _contacts = [];

  @override
  void initState() {
    super.initState();
    requestContactsPermission();
  }

  Future<void> requestContactsPermission() async {
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      // Permission granted, fetch contacts and store them
      _contacts = await fetchContacts();
      _contacts.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

      setState(() {}); // Update the state to rebuild the UI
    } else {
      // Permission denied, handle the case gracefully
      print('Permission denied');
    }
  }

  static const MethodChannel _channel = MethodChannel('contact_service');

  static Future<List<Map<String, String>>> fetchContacts() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('fetchContacts');
      List<Map<String, String>> contacts = [];

      // Iterate over each item in the fetched result
      for (var item in result) {
        // Cast each item to Map<String, String> and add it to the contacts list
        contacts.add(Map<String, String>.from(item));
      }

      return contacts;
    } catch (e) {
      print('Error fetching contacts: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Permission Example')),
      body: _contacts.isEmpty // Check if contacts are empty
          ? Center(child: CircularProgressIndicator()) // Show loading indicator
          : ListView.builder(
              itemCount: _contacts.length,
              itemBuilder: (context, index) {
                final contact = _contacts[index];
                return ListTile(
                  title: Text(contact['name'] ?? ''),
                  subtitle: Text(contact['phoneNumber'] ?? ''),
                );
              },
            ),
    );
  }
}
