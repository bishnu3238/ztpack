import 'package:flutter/material.dart';



class ProgressLine extends StatelessWidget {
  const ProgressLine({
    super.key,
    this.color = Colors.blue,
    required this.percentage,
  });

  final Color? color;
  final num? percentage;

  @override
  Widget build(BuildContext context) {
    var percent = percentage!.isNaN || percentage == 0 ? 100 : percentage;
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 5,
          decoration: BoxDecoration(
            color: color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        LayoutBuilder(
          builder:
              (context, constraints) => Container(
            width: constraints.maxWidth * (percent! / 100),
            height: 5,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}
