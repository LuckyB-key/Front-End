import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ai_recommendation.dart';
import '../services/shelter_service.dart';

class AiRecommendation {
  final String id;
  final String name;
  final double distance;
  final String status;
  final List<String> facilities;
  final String predictedCongestion;

  AiRecommendation({
    required this.id,
    required this.name,
    required this.distance,
    required this.status,
    required this.facilities,
    required this.predictedCongestion,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    return AiRecommendation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      status: json['status']?.toString() ?? '',
      facilities: List<String>.from(json['facilities'] ?? []),
      predictedCongestion: json['predictedCongestion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'status': status,
      'facilities': facilities,
      'predictedCongestion': predictedCongestion,
    };
  }
}
