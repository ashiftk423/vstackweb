import 'package:flutter/material.dart';

class DemoRatingStars extends StatelessWidget {
  const DemoRatingStars({super.key, required this.rating, this.size = 12});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: const Color(0xFF388E3C),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(rating.toStringAsFixed(1), style: TextStyle(color: Colors.white, fontSize: size, fontWeight: FontWeight.w700)),
              Icon(Icons.star, color: Colors.white, size: size),
            ],
          ),
        ),
      ],
    );
  }
}
