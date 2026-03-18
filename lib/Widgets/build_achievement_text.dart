import 'package:flutter/material.dart';

InlineSpan buildAchievementText({
  required List<dynamic> players,
  required String singularPrefix,
  required String pluralPrefix,
  required String suffix,
  required TextStyle highlightStyle,
}) {
  final isPlural = players.length > 1;

  final formattedPlayers = players.map((p) {
    final username = p["username"];

    // Detect if "words" exists
    if (p["words"] is List && p["words"].isNotEmpty) {
      final words = (p["words"] as List).join(", ");
      return "$username ($words)";
    }

    // Detect if "count" or "counts" exists
    if (p["count"] != null || p["counts"] != null) {
      final count = p["count"] ?? p["counts"];
      return "$username ($count)";
    }

    // Fallback: only username
    return username;
  }).join("\n");

  return TextSpan(
    children: [
      TextSpan(text: isPlural ? pluralPrefix : singularPrefix),
      TextSpan(text: formattedPlayers, style: highlightStyle),
      TextSpan(text: suffix),
    ],
  );
}