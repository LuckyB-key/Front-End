import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ai_recommendation.dart';
import '../services/shelter_service.dart';

class AiRecommendationProvider extends ChangeNotifier {
  List<AiRecommendation> _recommendations = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;

  List<AiRecommendation> get recommendations => _recommendations;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null; // Add this getter
  Position? get currentPosition => _currentPosition;

  // AI 추천 데이터 가져오기
  Future<void> fetchAiRecommendations({
    required double latitude,
    required double longitude,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🤖 AI 추천 데이터 가져오기 시작...');
      print('📍 위치: 위도 $latitude, 경도 $longitude');
      
      final response = await ShelterService.getAiRecommendations(
        latitude: latitude,
        longitude: longitude,
      );

      print('📡 AI 추천 API 응답: $response');

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>;
        print('📊 AI 추천 데이터 개수: ${data.length}');
        
        _recommendations = data.map((item) {
          print('🏠 AI 추천 아이템: $item');
          return AiRecommendation.fromJson(Map<String, dynamic>.from(item));
        }).toList();
        
        print('✅ AI 추천 데이터 ${_recommendations.length}개 로드 완료');
        print('📋 로드된 추천 목록:');
        for (int i = 0; i < _recommendations.length; i++) {
          print('  ${i + 1}. ${_recommendations[i].name} (${_recommendations[i].distance}km)');
        }
      } else {
        _error = response['message'] ?? 'AI 추천 데이터를 가져올 수 없습니다.';
        print('❌ AI 추천 데이터 로드 실패: $_error');
      }
    } catch (e) {
      _error = 'AI 추천 데이터 로드 중 오류가 발생했습니다: $e';
      print('❌ AI 추천 데이터 로드 오류: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
