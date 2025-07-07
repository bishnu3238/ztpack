import 'package:flutter/material.dart';

import '../../constant/constant.dart';

class DotIndicator extends StatelessWidget {
  const DotIndicator({
    super.key,
    this.isActive = false,
    this.inActiveColor,
    this.activeColor = Colors.blueGrey,
  });

  final bool isActive;

  final Color? inActiveColor, activeColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
       duration: thrMilliSecond,
      height: isActive ? 12 : 4,
      width: 4,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inActiveColor ?? Colors.grey,
        borderRadius: const BorderRadius.all(Radius.circular(p16)),
      ),
    );
  }
}