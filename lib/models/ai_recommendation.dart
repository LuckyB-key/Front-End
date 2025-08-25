import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ai_recommendation.dart';
import '../services/shelter_service.dart';

class AiRecommendation {
  final String id;
  final Map<String, dynamic> additionalProps;
  final String message;

  AiRecommendation({
    required this.id,
    required this.additionalProps,
    required this.message,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id']?.toString() ?? '',
      additionalProps: Map<String, dynamic>.from(json['additionalProps'] ?? {}),
      message: json['message']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'additionalProps': additionalProps,
      'message': message,
    };
  }
}
