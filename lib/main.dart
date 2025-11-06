import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      home: const DWKHomePage(),
    );
  }
}

class DWKHomePage extends StatefulWidget {
  const DWKHomePage({super.key});

  @override
  State<DWKHomePage> createState() => _DWKHomePageState();
}

class _DWKHomePageState extends State<DWKHomePage> {
  String _response = 'Press a button to call your Flask API';
  String _hello = 'hello';

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
  }

  // method for changing hello to world and back
  Future<void> _helloChange(String input) async {
    try {
      if (input == 'hello') {
        setState(() {
          _hello = 'world';
        });
      } else if (input == 'world') {
        setState(() {
          _hello = 'hello';
        });
      } else {
        setState(() {
          _hello = 'not able to change';
        });
      }
    } catch (e) {
      setState(() {
        _hello = 'Fail of changing text';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digitale Wortkette (Flask Test)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
            const SizedBox(height: 8),

            // Button to change hello to world 
            ElevatedButton(
              onPressed: () => _helloChange(_hello), 
              child: const Text('Change hello to world and back'),
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
            Text(
              _hello, 
              style: const TextStyle(fontFamily: 'monospace'),)
          ],
        ),
      ),
    );
  }
}
