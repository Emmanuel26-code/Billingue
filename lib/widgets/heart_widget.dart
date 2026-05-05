import 'package:flutter/material.dart';

class HeartWidget extends StatelessWidget {
  final int hearts;
  final int maxHearts;

  const HeartWidget({super.key, required this.hearts, this.maxHearts = 5});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxHearts, (i) {
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: Text(
            i < hearts ? '❤️' : '🖤',
            style: const TextStyle(fontSize: 18),
          ),
        );
      }),
    );
  }
}