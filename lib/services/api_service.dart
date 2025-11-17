import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api/v1/dwk';

  // Basic GET
  static Future<dynamic> get(String endpoint) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/$endpoint'));

      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }

      if (res.statusCode == 204) {
        return [];
      }

      return null;
    } catch (e) {
      debugPrint("GET error: $e");
      return null;
    }
  }

  // Basic POST (form-data)
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        body: data, // backend expects form-data, not json
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

    return (res as List).map((e) => {
          "lobbyID": e["lobbyID"],
          "topic": e["subjectName"],
          "players": e["maxPlayers"],
        }).toList();
  }

  // --------------------------
  // 2. Host Lobby
  // --------------------------

  static Future<Map<String, dynamic>?> createLobby({
    required String subject,
    required int maxGameLength,
    required int maxPlayers,
  }) async {
    final res = await post("host-lobby", {
      "subject": subject,
      "maxGameLength": maxGameLength.toString(),
      "maxPlayers": maxPlayers.toString(),
    });

    if (res == null) return null;

    return {
      "lobbyID": res["lobbyID"],
      "subjects": [
        {"name": res["subjectName"]}
      ],
      "generatedQRCode": res["generatedQRCode"],
      "maxPlayers": res["maxPlayers"],
      "maxGameLength": res["maxGameLength"],
    };
  }

  static Future<List<Map<String, dynamic>>> getHostLobbyPlayers() async {
    final res = await get("host-lobby");

    if (res == null || res is List && res.isEmpty) return [];

    return List<Map<String, dynamic>>.from(
      (res as List).map((p) => {
            "username": p["username"],
            "isPlayerReady": p["isPlayerReady"],
          }),
    );
  }

  static Future<Map<String, dynamic>> getHostLobbyOptions() async {
    return {
      "availableSubjects": ["Tiere", "Städte", "Flüsse"],
      "availableMaxPlayers": [5, 10, 15, 20, 25],
      "availableGameLengths": [5, 10, 15, 20],
    };
  }

  static Future<void> updateHostLobbySetting(Map<String, dynamic> data) async {
    await post("host-lobby", data);
  }

  // --------------------------
  // 3. Join Lobby
  // --------------------------
  static Future<Map<String, dynamic>?> getJoinLobbySettings() async {
    final res = await get("join-lobby");

    if (res == null) return null;

    return {
      "subject": res["chosenSubjectName"],
      "maxPlayers": res["chosenMaxPlayer"],
      "gameLength": res["chosenGameLength"],
    };
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
  static Future<Map<String, dynamic>?> getLobby(String code) async {
    //return await get('lobby/$code');
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
  static Future<Map<String, dynamic>?> startGame(String code, String firstLetter) async {
    //return await post('start-game/$code', {'startGame': true, 'firstLetter': firstLetter});
    return {"started": true, "firstLetter": firstLetter, "code": code};
  }

  // --------------------------
  // 6. Game
  // --------------------------
  static Future<Map<String, dynamic>?> getGame(String code) async {
    //return await get('game/$code');
    return {
      "round": 3,
      "currentLetter": "B",
      "playerTurn": "Alice",
      "words": ["Ball", "Boot", "Baum"],
    };
  }

  static Future<Map<String, dynamic>?> postWord(String code, String wordInput) async {
    //return await post('game/$code', {'wordInput': wordInput});
    return {
      "accepted": true,
      "newLetter": wordInput.characters.last.toUpperCase(),
      "nextPlayer": "Bob",
    };
  }

  static Future<Map<String, dynamic>?> postPlayerStatus(String code, String status) async {
    //return await post('game/$code', {'playerStatus': status});
    return {"statusUpdated": true, "playerStatus": status};
  }

  // --------------------------
  // 7. Game State / Word Submit (optional)
  // --------------------------
  static Future<Map<String, dynamic>?> getGameState(String code) async {
    //return await get('api/game-state/$code');
    return {
      "round": 2,
      "letter": "A",
      "activePlayer": "Charlie",
      "submittedWords": ["Apfel", "Ameise"],
    };
  }

  static Future<Map<String, dynamic>?> submitWord(String code, String word) async {
    //return await post('api/submit-word/$code', {'wordInput': word});
    return {"accepted": true, "word": word};
  }

  // --------------------------
  // 8. Results
  // --------------------------
  static Future<Map<String, dynamic>?> getResults(String code) async {
    //return await get('results/$code');
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
  static Future<Map<String, dynamic>?> getManual() async {
    //return await get('manual');
    return {
      "sections": [
        {"title": "Einleitung", "content": "Willkommen zur Digitalen Wortkette!"},
        {"title": "Regeln", "content": "Bilde ein Wort mit dem letzten Buchstaben des vorherigen."},
        {"title": "Spielende", "content": "Das Spiel endet, wenn niemand mehr ein Wort findet."},
      ]
    };
  }
}