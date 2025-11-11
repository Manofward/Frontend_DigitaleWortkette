import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Handles Flask API communication
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000'; // Change for your Flask server

  /// Example GET request
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$endpoint'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('GET request error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('POST request error: $e');
    }
    return null;
  }

  // has to be changed later to use the real IP
  // Homepage-specific GET
  static Future<Map<String, dynamic>?> homepageGet() async {
    //return await get('/homepage');
    return {
    "open_games": [
      {"lobby": "Lobby 1", "topic": "Tiere", "players": 3},
      {"lobby": "Lobby 2", "topic": "Städte", "players": 5},
      {"lobby": "Lobby 3", "topic": "Filme", "players": 2},
      {"lobby": "Lobby 4", "topic": "Technik", "players": 4},
    ]
  };
  }

  /// This function has to be changed later on so that when creating the game you use a get/post from api_service.dart
  // Example GET for lobby creation
  static Future<Map<String, dynamic>?> createGameGet() async {
    //return await get('/host-Lobby/{id}');
    return {
      "createdLobbyID": 42,
      "subjects": [
        {"name": "Tiere", "icon": "🐶"},
        {"name": "Städte", "icon": "🌆"},
        {"name": "Filme", "icon": "🎬"},
      ],
      "maxPlayers": 6,
      "maxGameLength": 10,
      "generatedQRCode": "https://example.com/qr/lobby42",
    };
  }

  // Example GET for players connected
  static Future<Map<String, dynamic>?> getPlayers(int lobbyID) async {
    //return await get('/host-Lobby/{id}/players');
    return {
      "players": [
        {"username": "Alice", "readyPlayer": true},
        {"username": "Bob", "readyPlayer": false},
      ]
    };
  }
}