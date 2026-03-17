import 'package:flutter/material.dart';


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
      padding: const EdgeInsets.symmetric(vertical: 6),
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
