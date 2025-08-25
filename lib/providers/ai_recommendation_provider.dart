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
      
      final response = await ShelterService.getAiRecommendations(
        latitude: latitude,
        longitude: longitude,
      );

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>;
        _recommendations = data.map((item) {
          // API 응답 구조에 따라 적절히 매핑
          return AiRecommendation.fromJson(Map<String, dynamic>.from(item));
        }).toList();
        
        print('✅ AI 추천 데이터 ${_recommendations.length}개 로드 완료');
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
