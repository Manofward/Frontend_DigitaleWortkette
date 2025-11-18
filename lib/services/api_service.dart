import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://172.16.34.142:5000/api/v1/dwk';

  // --------------------------
  // Basic GET
  // --------------------------
  static Future<dynamic> get(String endpoint) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$endpoint'));
      debugPrint("$res");
      debugPrint("Endpoint param: $endpoint (${endpoint.runtimeType})");

      if (res.statusCode == 200 || res.statusCode == 201) {
        debugPrint("GET OK");
        return jsonDecode(res.body);
      }

      if (res.statusCode == 204) {
        debugPrint("GET 204");
        return [];
      }

      return null;
    } catch (e) {
      debugPrint("GET error: $e");
      return null;
    }
  }

  // --------------------------
  // Basic POST (form-data)
  // --------------------------
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: data,
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return jsonDecode(res.body);
      }

      return null;
    } catch (e) {
      debugPrint("POST error: $e");
      return null;
    }
  }

  // --------------------------
  // 1. Homepage
  // --------------------------
  static Future<List<dynamic>> homepageGet() async {
    final res = await get("home");

    if (res == null || res is List && res.isEmpty) {
      return [];
    }

    if (res is! List) return [];

    return res.map((e) => {
          "lobbyID": e["lobbyID"],
          "topic": e["subjectName"],
          "players": e["maxPlayers"],
        }).toList();
  }

  // --------------------------
  // 2. Host Lobby (CREATE LOBBY)
  // --------------------------
  static Future<Map<String, dynamic>> createLobby() async {
  final res = await get("host-lobby");

  if (res == null || res is! Map<String, dynamic>) {
    return {};
  }

  return {
    "lobbyID": res["lobbyID"],
    "generatedQRCode": res["generatedQRCode"],
    "maxPlayers": res["maxPlayers"],           // list<int>
    "maxGameLength": res["maxGameLength"],     // list<int>
    "subjectName": res["subjectName"],         // list<String>
  };
}

  // --------------------------
  // Host Lobby Players
  // --------------------------
  static Future<List<Map<String, dynamic>>> getHostLobbyPlayers() async {
    final res = await get("host-lobby");

    if (res == null || res is! List) return [];

    return List<Map<String, dynamic>>.from(
      res.map((p) => {
        "username": p["username"],
        "isPlayerReady": p["isPlayerReady"],
      }),
    );
  }

  static Future<void> updateHostLobbySetting(Map<String, dynamic> data) async {
    await post("host-lobby", data);
  }

  // --------------------------
  // 3. Join Lobby
  // --------------------------
  static Future<List<dynamic>> getJoinLobbySettings() async {
    final res = await get("join-lobby");

    if (res == null || res is! List) return [];

    return res.map((e) => [
          e["chosenSubjectName"],
          e["chosenMaxPlayer"],
          e["chosenGameLength"],
        ]).toList();
  }

  static Future<bool> postJoinLobby(String username, bool ready) async {
    final res = await post("join-lobby", {
      "nickname": username,
      "readyPlayer": ready.toString(),
    });

    return res != null;
  }

  // --------------------------
  // 4. Waiting Room
  // --------------------------
  static Future<dynamic> getLobby(String code) async {
    return {
      "lobbyID": code,
      "subject": "Städte",
      "players": ["Alice", "Bob", "Charlie"],
      "readyPlayers": 2,
      "maxPlayers": 6,
    };
  }

  // --------------------------
  // 5. Start Game
  // --------------------------
  static Future<dynamic> startGame(String code, String firstLetter) async {
    return {"started": true, "firstLetter": firstLetter, "code": code};
  }

  // --------------------------
  // 6. Game
  // --------------------------
  static Future<dynamic> getGame(String code) async {
    return {
      "round": 3,
      "currentLetter": "B",
      "playerTurn": "Alice",
      "words": ["Ball", "Boot", "Baum"],
    };
  }

  static Future<dynamic> postWord(String code, String wordInput) async {
    return {
      "accepted": true,
      "newLetter": wordInput.characters.last.toUpperCase(),
      "nextPlayer": "Bob",
    };
  }

  static Future<dynamic> postPlayerStatus(String code, String status) async {
    return {"statusUpdated": true, "playerStatus": status};
  }

  // --------------------------
  // 7. Game State
  // --------------------------
  static Future<dynamic> getGameState(String code) async {
    return {
      "round": 2,
      "letter": "A",
      "activePlayer": "Charlie",
      "submittedWords": ["Apfel", "Ameise"],
    };
  }

  static Future<dynamic> submitWord(String code, String word) async {
    return {"accepted": true, "word": word};
  }

  // --------------------------
  // 8. Results
  // --------------------------
  static Future<dynamic> getResults(String code) async {
    return {
      "winner": "Alice",
      "scoreboard": [
        {"username": "Alice", "points": 12},
        {"username": "Bob", "points": 9},
        {"username": "Charlie", "points": 8},
      ]
    };
  }

  // --------------------------
  // 9. Manual
  // --------------------------
  static Future<dynamic> getManual() async {
    return {
      "sections": [
        {"title": "Einleitung", "content": "Willkommen zur Digitalen Wortkette!"},
        {"title": "Regeln", "content": "Bilde ein Wort mit dem letzten Buchstaben des vorherigen."},
        {"title": "Spielende", "content": "Das Spiel endet, wenn niemand mehr ein Wort findet."},
      ]
    };
  }
}
