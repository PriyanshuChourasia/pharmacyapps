import 'package:flutter/material.dart';

/// Maps a [Category.iconKey] (a plain string, so `shared_models` stays free
/// of Flutter imports) to its Material icon.
IconData categoryIcon(String key) => switch (key) {
      'pain' => Icons.sick_outlined,
      'cold' => Icons.thermostat_outlined,
      'diabetes' => Icons.water_drop_outlined,
      'vitamin' => Icons.health_and_safety_outlined,
      'skin' => Icons.face_outlined,
      'digestive' => Icons.restaurant_outlined,
      'heart' => Icons.favorite_outline,
      'baby' => Icons.child_care_outlined,
      _ => Icons.medication_outlined,
    };
