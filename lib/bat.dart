import 'package:flutter/material.dart';

class Bat extends StatelessWidget {
  const Bat({super.key, required this.width, required this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.blue[900]),
    );
  }
}
