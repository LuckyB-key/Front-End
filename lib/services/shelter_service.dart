import 'api_service.dart';

class ShelterService {
  // 쉘터 목록 조회
  static Future<Map<String, dynamic>> getShelters({
    Map<String, dynamic>? queryParams,
  }) async {
    String endpoint = '/api/v1/shelters';
    if (queryParams != null && queryParams.isNotEmpty) {
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
          .join('&');
      endpoint += '?$queryString';
    }
    return await ApiService.get(endpoint);
  }
  
  // 특정 쉘터 조회
  static Future<Map<String, dynamic>> getShelter(String shelterId) async {
    return await ApiService.get('/api/v1/shelters/$shelterId');
  }
  
  // 쉘터 생성
  static Future<Map<String, dynamic>> createShelter(Map<String, dynamic> shelterData) async {
    return await ApiService.post('/api/v1/shelters', shelterData);
  }
  
  // 쉘터 수정
  static Future<Map<String, dynamic>> updateShelter(String shelterId, Map<String, dynamic> shelterData) async {
    return await ApiService.put('/api/v1/shelters/$shelterId', shelterData);
  }
  
  // 쉘터 삭제
  static Future<bool> deleteShelter(String shelterId) async {
    return await ApiService.delete('/api/v1/shelters/$shelterId');
  }
  
  // 쉘터 좋아요
  static Future<Map<String, dynamic>> toggleShelterLike(String shelterId) async {
    return await ApiService.put('/api/v1/shelters/$shelterId/like', {});
  }
  
  // 쉘터 좋아요 목록
  static Future<Map<String, dynamic>> getShelterLikes(String shelterId) async {
    return await ApiService.get('/api/v1/shelters/$shelterId/likes');
  }
  
  // 쉘터 혼잡도 조회
  static Future<Map<String, dynamic>> getShelterCongestion(String shelterId) async {
    return await ApiService.get('/api/v1/shelters/$shelterId/congestion');
  }
  
  // 추천 쉘터 조회
  static Future<Map<String, dynamic>> getRecommendedShelters() async {
    return await ApiService.get('/api/v1/shelters/recommendations');
  }
  
  // AI 추천 알림
  static Future<Map<String, dynamic>> getAiRecommendations() async {
    return await ApiService.get('/api/v1/shelters/notifications/ai-recommendations');
  }
}
