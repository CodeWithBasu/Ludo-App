import 'package:flutter/material.dart';

enum PlayerColor {
  red,
  green,
  yellow,
  blue,
}

class Player {
  final String id;
  final String name;
  final PlayerColor color;
  final bool isComputer;

  Player({
    required this.id,
    required this.name,
    required this.color,
    this.isComputer = false,
  });
}
