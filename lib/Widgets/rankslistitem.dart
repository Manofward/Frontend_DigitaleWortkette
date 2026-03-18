import 'package:flutter/material.dart';

// RanklistHeader
// Hier wird der Header für die RankList erstellt und zum Build context der Result Seite zurückgegeben
Widget buildHeader(TextStyle? style) {
  return Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 1),
    child: Row(
      children: [
        SizedBox(width: 40, child: Text("Rang", style: style)),
        Expanded(child: Text("Nutzername", textAlign: TextAlign.center, style: style)),
        SizedBox(width: 60, child: Text("Punkte", textAlign: TextAlign.right, style: style)),
      ],
    ),
  );
}

// RankListItem
// Hier wird die List gebaut und return in den Allgemeinen Build context von der Result Seite
class RankListItem extends StatelessWidget {
  final int rank;
  final String username;
  final int points;
  final TextStyle style;

  const RankListItem({
    super.key,
    required this.rank,
    required this.username,
    required this.points,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          // Platzierung links
          SizedBox(
            width: 40,
            child: Text(
              "$rank.",
              textAlign: TextAlign.left,
              style: style,
            ),
          ),

          // Username mittig
          Expanded(
            child: Text(
              username,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),

          // Punkte rechts
          SizedBox(
            width: 60,
            child: Text(
              "$points",
              textAlign: TextAlign.right,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}
