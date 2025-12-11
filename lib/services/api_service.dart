import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://172.16.34.70:5000/api/v1/dwk'; // for testing with more real endpoints
  // static const String baseUrl = 'http://172.16.34.110:5000/api/v1/dwk'; // for the docker 
  //static const String baseUrl = 'http://10.0.2.2:5000/api/v1/dwk'; // for local testing

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
        return await jsonDecode(res.body);
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
    final res = await get("host/host-lobby");
    debugPrint("$res");

    if (res == null || res is! Map<String, dynamic>) {
      return {};
    }

    return {
      "lobbyID": res["lobbyID"],
      "userID": res["userID"],
      "hostID": res["hostID"],
      "generatedQRCode": res["generatedQRCode"],
      "maxPlayers": res["maxPlayers"],           // list<int>
      "maxGameLength": res["maxGameLength"],     // list<int>
      "subjectName": res["subjectName"],         // list<String>
    };
  }

  static Future<void> updateHostLobbySetting(Map<String, dynamic> data) async {
    await post("host/host-lobby", data);
  }

  // --------------------------
  // 3. Join Lobby
  // --------------------------

  static Future<Map<String, dynamic>> postJoinLobby(int lobbyID, int userID, int hostID, String username, bool ready) async {
    final res = await post("player/$lobbyID/join", {
      "userID": userID.toString(), // to lok here why i need string here
      "hostID": hostID.toString(),
      "nickname": username,
      "isPlayerReady": ready.toString()
    });

    return {
      "userID": res["userID"],
      "hostID": res["hostID"],
    };

    //return res != null;
  }

  // --------------------------
  // 4. Waiting Room
  // --------------------------
  static Future<Map<String, dynamic>> getLobby(int lobbyID) async {
    final res = await get("lobby/$lobbyID/lobbySettings");

    return {
      "chosenSubjectName": res["chosenSubject"],
      "chosenMaxPlayers": res["chosenMaxPlayers"],
      "chosenMaxGameLength": res["chosenMaxGameLength"],
    };
  }

  static Future<List<Map<String, dynamic>>> getLobbyPlayers(int lobbyID) async {
    final res = await get("lobby/$lobbyID/playerList");

    if (res == null || res is! List) return [];
    debugPrint("$res");

    return List<Map<String, dynamic>>.from(
      res.map((p) => {
        "username": p["username"],
        "isPlayerReady": p["isPlayerReady"],
      }),
    );
  }

  // --------------------------
  // 4.1 Leaving Game/close lobby
  // --------------------------
  static Future<bool> leaveGame(int lobbyID, int userID, int hostID) async {
    final res = await post("player/$lobbyID/leave", {
      "userID": userID.toString(),
      "hostID": hostID.toString(),
    });

    return res != null;
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
