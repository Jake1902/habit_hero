import 'dart:convert';

import 'package:flutter/material.dart';

/// Model representing an achievement badge.
class Badge {
  const Badge({
    required this.id,
    required this.title,
    required this.icon,
    required this.awardedAt,
  });

  /// Unique badge identifier.
  final String id;

  /// Display title for the badge.
  final String title;

  /// Icon shown for the badge.
  final IconData icon;

  /// Date when the badge was awarded.
  final DateTime awardedAt;

  /// Creates a [Badge] from a JSON map.
  factory Badge.fromMap(Map<String, dynamic> map) => Badge(
        id: map['id'] as String,
        title: map['title'] as String,
        icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
        awardedAt: DateTime.parse(map['awardedAt'] as String),
      );

  /// Converts this [Badge] to a JSON map.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'icon': icon.codePoint,
        'awardedAt': awardedAt.toIso8601String(),
      };

  /// Converts this [Badge] to JSON string.
  String toJson() => jsonEncode(toMap());

  /// Creates a [Badge] from JSON string.
  factory Badge.fromJson(String json) =>
      Badge.fromMap(jsonDecode(json) as Map<String, dynamic>);
}
