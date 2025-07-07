import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


class LoadingWidget extends StatelessWidget {


  const LoadingWidget({super.key, this.size = 30.0});
  final double size;

  static chasingSpinner({Color? color, double? size = 50.0}) {
    return SpinKitChasingDots(
        color: color , size: size!);
  }

  static threeBounce({Color? color, double? size = 50.0}) {
    return SpinKitThreeBounce(
        color: color,  size: size!);
  }

  static fadingCircle({Color? color, double? size = 50.0}) {
    return SpinKitFadingCircle(
        color: color,  size: size!);
  }

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}