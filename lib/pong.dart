import 'package:flutter/material.dart';
import 'dart:math';

import './ball.dart';
import './bat.dart';

enum Direction { up, down, left, right }

class Pong extends StatefulWidget {
  const Pong({super.key});

  @override
  State<Pong> createState() => _PongState();
}

class _PongState extends State<Pong> with SingleTickerProviderStateMixin {
  double? width;
  double? height;
  double posX = 0;
  double posY = 0;
  double? batWidth = 0;
  double? batHeight = 0;
  double batPosition = 0;
  double increment = 5;
  double randX = 1;
  double randY = 1;
  int score = 0;

  Direction hDir = Direction.right;
  Direction vDir = Direction.down;

  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    posX = 0;
    posY = 0;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10000),
    );
    animation = Tween<double>(begin: 0, end: 100).animate(controller);
    animation.addListener(() {
      setState(() {
        (hDir == Direction.right)
            ? posX += ((increment * randX).round())
            : posX -= ((increment * randX).round());
        (vDir == Direction.down)
            ? posY += ((increment * randY).round())
            : posY -= ((increment * randY).round());
      });
      checkBorders();
    });
    controller.forward();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((context, constraints) {
        height = constraints.maxHeight;
        width = constraints.maxWidth;
        batWidth = width! / 5;
        batHeight = height! / 20;
        print("${batWidth?.toInt()} : ${batHeight?.toInt()}");
        return Stack(
          children: [
            Positioned(
              top: 0,
              right: 24,
              child: Text("Score: " + score.toString()),
            ),
            Positioned(
              top: posY,
              left: posX,
              child: const Ball(),
            ),
            Positioned(
              bottom: 0,
              left: batPosition,
              child: GestureDetector(
                  onHorizontalDragUpdate: (update) => moveBat(update),
                  child: Bat(width: batWidth, height: batHeight)),
            ),
          ],
        );
      }),
    );
  }

  void checkBorders() {
    double diameter = 50;
    if (posX <= 0 && hDir == Direction.left) {
      hDir = Direction.right;
      randX = randomNumber();
    }
    if (posX >= width! - diameter && hDir == Direction.right) {
      hDir = Direction.left;
      randX = randomNumber();
    }
    if (posY >= height! - diameter - batHeight! && vDir == Direction.down) {
      // check if the bat is here, otherwise we lose
      if (posX >= (batPosition - diameter) &&
          posX <= (batPosition + batWidth! + diameter)) {
        vDir = Direction.up;
        randY = randomNumber();
        setState(() {
          score++;
        });
      } else {
        controller.stop();
        showMessage(context);
      }
    }
    if (posY <= 0 && vDir == Direction.up) {
      vDir = Direction.down;
      randY = randomNumber();
    }
  }

  moveBat(DragUpdateDetails update) {
    setState(() {
      batPosition += update.delta.dx;
    });
  }

  double randomNumber() {
    // this is the number between 0.5 and 1.5
    var ran = Random();
    int myNum = ran.nextInt(101);
    return (50 + myNum) / 100;
  }

  void safeSetState(Function function) {
    if (mounted && controller.isAnimating) {
      setState(() {
        function;
      });
    }
  }

  void showMessage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Game Over"),
          content: const Text("Would you like to play again?"),
          actions: [
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                setState(() {
                  posX = 0;
                  posY = 0;
                  score = 0;
                });
                Navigator.of(context).pop();
                controller.repeat();
              },
            ),
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
                dispose();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
