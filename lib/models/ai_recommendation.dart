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
  final String address; // 주소 추가
  final double latitude; // 위도 추가
  final double longitude; // 경도 추가

  // 상태 포맷팅 헬퍼 함수
  static String _formatStatus(String status) {
    final upperStatus = status.toUpperCase();
    if (upperStatus.contains('ACTIVE')) {
      return '이용가능';
    } else if (upperStatus.contains('INACTIVE')) {
      return '이용불가';
    } else if (upperStatus.contains('MAINTENANCE')) {
      return '점검중';
    } else if (upperStatus.contains('CLOSED')) {
      return '폐쇄';
    } else {
      return status;
    }
  }

  AiRecommendation({
    required this.id,
    required this.name,
    required this.distance,
    required this.status,
    required this.facilities,
    required this.predictedCongestion,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory AiRecommendation.fromJson(Map<String, dynamic> json) {
    // 상태 한글 변환
    String originalStatus = json['status']?.toString() ?? '';
    String formattedStatus = _formatStatus(originalStatus);
    
    return AiRecommendation(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      status: formattedStatus, // 한글로 변환된 상태 사용
      facilities: List<String>.from(json['facilities'] ?? []),
      predictedCongestion: json['predictedCongestion']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
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
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
