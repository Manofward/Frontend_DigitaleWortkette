import 'package:flutter/material.dart';
import 'screens/home.dart'; // Import your new home page

void main() {
  runApp(const DWKApp());
}

class DWKApp extends StatelessWidget {
  const DWKApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digitale Wortkette Client',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const DWKHomePage(), // points to another file
    );
  }
}

//import 'package:http/http.dart' as http;

// this is important for later when connecting to the flask api with method outputs
/*String _response = 'Press a button to call your Flask API';

  // 🧠 Adjust the base URL depending on your setup
  // For Android emulator → 10.0.2.2
  // For physical device → your computer's IP, e.g. 192.168.1.5
  final String baseUrl = 'http://10.0.2.2:5000';

  Future<void> _callEndpoint(String endpoint) async {
    setState(() {
      _response = 'Loading $endpoint ...';
    });

    try {
      final res = await http.get(Uri.parse('$baseUrl$endpoint'));
      if (res.statusCode == 200) {
        setState(() {
          _response = res.body;
        });
      } else {
        setState(() {
          _response = 'Error ${res.statusCode}: ${res.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _response = 'Failed to connect: $e';
      });
    }
  }*/

// this is important for later when connecting to the flask api for the screen
  /*children: [
            ElevatedButton(
              onPressed: () => _callEndpoint('/api/v1/dwk/home'),
              child: const Text('GET /api/v1/dwk/home'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _callEndpoint('/spec'),
              child: const Text('GET /spec (Swagger Spec)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _callEndpoint('/temp'),
              child: const Text('GET /temp (UserModel Resource)'),
            ),
            const SizedBox(height: 16),
            const Text('Response:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black12,
                  ),
                  child: Text(
                    _response,
                    style: const TextStyle(fontFamily: 'monospace'),
                  ),
                ),
              ),
            ),
          ],*/