import 'package:flutter/material.dart';
import 'package:flutter_frontend/services/navigation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class ApiService {
  static const String baseUrl = 'http://172.16.34.34:5000/api/v1/dwk'; // for testing with more real endpoints
  //static const String baseUrl = 'http://172.22.48.1:5000/api/v1/dwk'; // for the docker 
  //static const String baseUrl = 'http://10.0.2.2:5000/api/v1/dwk'; // for local testing 

  // --------------------------
  // Basic GET
  // --------------------------
  static Future<dynamic> get(String endpoint, String? auth_token) async {
    try {
      Map<String, String>? headers;

      if (auth_token != null) {
        headers = {
          'Authorization': 'Bearer $auth_token',
        };
      }

      final response = await http.get(Uri.parse('$baseUrl/$endpoint'), headers: headers);

      debugPrint("GET request to $endpoint - Status: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          debugPrint("JSON parsing error: $e");
          return null;
        }
      }

      if (response.statusCode == 204) {
        return [];
      }

      debugPrint("GET failed with status: ${response.statusCode}");
      return null;
    } on SocketException catch (e) {
      debugPrint("Network error: $e");
      return null;
    } catch (e) {
      debugPrint("Unexpected error in GET: $e");
      return null;
    }
  }

  // --------------------------
  // Basic POST (form-data)
  // --------------------------
  static Future<dynamic> post(String endpoint, Map<String, dynamic> data, String? auth_token, {int maxRetries = 3}) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        // Building headers
        Map<String, String> headers = {
          'Content-Type': 'application/x-www-form-urlencoded',
        };

        if (auth_token != null) {
          headers['Authorization'] = 'Bearer $auth_token';
        }

        // final post
        final response = await http.post(
          Uri.parse('$baseUrl/$endpoint'),
          body: data,
          headers: headers,
        );

        debugPrint("POST request to $endpoint - Status: ${response.statusCode}");

        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            return jsonDecode(response.body);
          } catch (e) {
            debugPrint("JSON parsing error in POST: $e");
            return null;
          }
        }

        debugPrint("POST failed with status: ${response.statusCode}");
        return null;
      } on SocketException catch (e) {
        if (attempts < maxRetries - 1) {
          attempts++;
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        }
        debugPrint("Network error in POST: $e");
        return null;
      } on TimeoutException catch (e) {
        if (attempts < maxRetries - 1) {
          attempts++;
          await Future.delayed(Duration(seconds: attempts * 2));
          continue;
        }
        debugPrint("Timeout error: Request timed out after 15 seconds.  $e");
        return null;
      } catch (e) {
        debugPrint("POST error on attempt ${attempts + 1}: $e");
        return null;
      }
    }
  }

  // --------------------------
  // 1. Homepage
  // --------------------------
  static Future<List<dynamic>> homepageGet() async {
    final res = await get("home", null);
    
    if (res == null || res is List && res.isEmpty) {
      return [];
    }
    
    if (res is! List) {
      debugPrint('Unexpected response type in homepageGet');
      return [];
    }

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
    final res = await get("host/host-lobby", null);
    debugPrint("createLobby result: $res");

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
    await post("host/host-lobby", data, LobbySession.auth_token);
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
      },
      null
    );

    return {
      "userID": res["userID"],
      "hostID": res["hostID"],
      "auth_token": res["auth_token"],
    };

    //return res != null;
  }

  // --------------------------
  // 4. Waiting Room
  // --------------------------
  static Future<Map<String, dynamic>> getLobby(int lobbyID) async {
    final res = await get("lobby/$lobbyID/lobbySettings", null);

    return {
      "chosenSubjectName": res["chosenSubject"],
      "chosenMaxPlayers": res["chosenMaxPlayers"],
      "chosenMaxGameLength": res["chosenMaxGameLength"],
      "hasGameStarted": res["hasGameStarted"],
    };
  }

  static Future<List<Map<String, dynamic>>> getLobbyPlayers(int lobbyID) async {
    final res = await get("lobby/$lobbyID/playerList", null);

    if (res == null || res is! List) return [];
    debugPrint("$res");

    return List<Map<String, dynamic>>.from(
      res.map((p) => {
        "userID": p["userID"],
        "username": p["username"],
        "isPlayerReady": p["isPlayerReady"],
        "auth_token": p["auth_token"],
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
      },
      LobbySession.auth_token
    );

    return res != null;
  }


  // Get the current game session data (returns game state)
  static Future<Map<String, dynamic>> getGameSessionData(int lobbyID) async {
    final res = await get("game/$lobbyID/session", null);

    if (res == null) {
      return {};
    }

    return {
      "gameID": res["gameID"] ?? "",
      "chosenSubject": res["chosenSubject"] ?? "",
      "currentLetter": res["currentLetter"] ?? "",
      "usedWords": res["usedWords"] ?? [],
      "previousWord": res["previousWord"] ?? null,
      "isGameOver": res["isTimeUp"] ?? "",
      "turnOrder": res["turnOrder"] ?? [],
    };
  }

  // Submit a word to the game session
  static Future<Map<String, dynamic>?> postGameSession(int lobbyID, String word, int? userID) async {
    try {
      final res = await post("game/$lobbyID/session", {
          'wordInput': word.toString(),
          'userID': userID.toString(),
        },
        LobbySession.auth_token
      );

      // post() returns Map<String, dynamic> or null, not http.Response
      if (res != null) {
        return res;
      }
    } catch (e) {
      debugPrint('Error submitting word: $e');
    }
    return null;
  }

  static Future<void> getSkipTurn(int lobbyID) async {
    await get("game/$lobbyID/skip", LobbySession.auth_token);
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