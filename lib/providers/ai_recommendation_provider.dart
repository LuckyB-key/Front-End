import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import '../models/ai_recommendation.dart';
import '../models/shelter.dart';
import '../services/shelter_service.dart';

class AiRecommendationProvider extends ChangeNotifier {
  List<AiRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  List<AiRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  Position? get currentPosition => _currentPosition;

  // 거리 기반 AI 추천 데이터 가져오기
  Future<void> fetchAiRecommendations({
    required double latitude,
    required double longitude,
    required List<Shelter> allShelters,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🤖 AI 추천 데이터 가져오기 시작...');
      print('📍 위치: 위도 $latitude, 경도 $longitude');
      print('🏠 전체 쉼터 개수: ${allShelters.length}');
      
      // 1단계: 현재 위치 기준으로 엄격한 필터링 시도
      List<Shelter> eligibleShelters = _getEligibleShelters(allShelters, latitude, longitude);
      
      // 2단계: 현재 위치에서 추천할 쉼터가 없으면 서울 양재 AT센터 기준으로 재시도
      if (eligibleShelters.isEmpty) {
        print('⚠️ 현재 위치에서 추천할 쉼터가 없습니다. 서울 양재 AT센터 기준으로 재시도합니다.');
        const double defaultLat = 37.4692; // 서울양재at센터
        const double defaultLon = 127.0334;
        
        // 서울 양재 AT센터 기준으로 거리 재계산
        List<Shelter> sheltersWithRecalculatedDistance = allShelters.map((shelter) {
          double newDistance = _calculateDistance(defaultLat, defaultLon, shelter.latitude, shelter.longitude);
          return Shelter(
            id: shelter.id,
            name: shelter.name,
            address: shelter.address,
            distance: newDistance,
            status: shelter.status,
            predictedCongestion: shelter.predictedCongestion,
            latitude: shelter.latitude,
            longitude: shelter.longitude,
            openingDays: shelter.openingDays,
            maxCapacity: shelter.maxCapacity,
            facilities: shelter.facilities,
            rating: shelter.rating,
            likes: shelter.likes,
            imageUrl: shelter.imageUrl,
            congestion: shelter.congestion,
          );
        }).toList();
        
        eligibleShelters = _getEligibleShelters(sheltersWithRecalculatedDistance, defaultLat, defaultLon);
        print('✅ 서울 양재 AT센터 기준 필터링된 쉼터 개수: ${eligibleShelters.length}개');
      }
      
      // 3단계: 여전히 없으면 활성 쉼터만이라도 추천
      if (eligibleShelters.isEmpty) {
        print('⚠️ 엄격한 필터링에서 추천할 쉼터가 없습니다. 활성 쉼터만 추천합니다.');
        eligibleShelters = allShelters.where((shelter) {
          return shelter.status.contains('이용가능') || 
                 shelter.status.contains('활성') ||
                 shelter.status.contains('정상');
        }).toList();
        
        // 거리 순으로 정렬
        eligibleShelters.sort((a, b) => a.distance.compareTo(b.distance));
        print('✅ 활성 쉼터만 필터링된 개수: ${eligibleShelters.length}개');
      }
      
      // 상위 3개 쉼터를 AI 추천으로 선택
      _recommendations = eligibleShelters.take(3).map((shelter) {
        return AiRecommendation(
          id: shelter.id,
          name: shelter.name,
          distance: shelter.distance,
          status: shelter.status, // 이미 한글로 변환된 상태 사용
          facilities: shelter.facilities,
          predictedCongestion: shelter.predictedCongestion,
          address: shelter.address, // 주소 추가
          latitude: shelter.latitude, // 위도 추가
          longitude: shelter.longitude, // 경도 추가
        );
      }).toList();
      
      print('✅ AI 추천 ${_recommendations.length}개 생성 완료');
      print('📋 AI 추천 쉼터 목록:');
      for (int i = 0; i < _recommendations.length; i++) {
        final rec = _recommendations[i];
        print('  ${i + 1}. ${rec.name} (${rec.distance.toStringAsFixed(1)}km) - ${rec.address}');
      }
      
    } catch (e) {
      _error = 'AI 추천 데이터 생성 중 오류가 발생했습니다: $e';
      print('❌ AI 추천 데이터 생성 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 엄격한 필터링 기준으로 쉼터 선택
  List<Shelter> _getEligibleShelters(List<Shelter> allShelters, double latitude, double longitude) {
    return allShelters.where((shelter) {
      // 1. 활성화된 쉼터만
      bool isActive = shelter.status.contains('이용가능') || 
                     shelter.status.contains('활성') ||
                     shelter.status.contains('정상');
      
      // 2. 여유로운 쉼터만 (혼잡도가 낮은 것)
      bool isNotCrowded = shelter.predictedCongestion.contains('낮음') ||
                         shelter.predictedCongestion.contains('한산') ||
                         shelter.predictedCongestion.contains('여유') ||
                         shelter.predictedCongestion.contains('보통');
      
      return isActive && isNotCrowded;
    }).toList();
  }

  // 두 지점 간의 거리 계산 (km)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // 지구 반지름 (km)
    
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    
    double a = sin(dLat / 2) * sin(dLat / 2) +
               sin(_degreesToRadians(lat1)) * sin(_degreesToRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan(sqrt(a) / sqrt(1 - a));
    
    return earthRadius * c;
  }

  // 도를 라디안으로 변환
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // 현재 위치 설정
  void setCurrentPosition(Position position) {
    _currentPosition = position;
    notifyListeners();
  }

  // 에러 초기화
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // 데이터 초기화
  void clearRecommendations() {
    _recommendations = [];
    _error = null;
    notifyListeners();
  }
}
