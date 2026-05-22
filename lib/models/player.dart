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

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.name,
    'isComputer': isComputer,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      color: PlayerColor.values.firstWhere((e) => e.name == json['color']),
      isComputer: json['isComputer'] ?? false,
    );
  }
}
