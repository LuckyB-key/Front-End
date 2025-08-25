import 'api_service.dart';

class ShelterService {
  // 쉘터 목록 조회 (위치 기반)
  static Future<Map<String, dynamic>> getShelters({
    required double lat, // latitude 대신 lat
    required double lng, // longitude 대신 lng
    double? distance,
    String? type,
    String? facilities,
  }) async {
    String endpoint = '/api/v1/shelters';
    
    // 쿼리 파라미터 구성
    final queryParams = <String, String>{
      'lat': lat.toString(),
      'lng': lng.toString(),
    };
    
    // 거리 제한이 있으면 추가 (기본값: 10km)
    if (distance != null) {
      queryParams['distance'] = distance.toString();
    } else {
      // 기본 거리 제한 없음 - 모든 쉼터 가져오기
      print('🌍 거리 제한 없음 - 데이터베이스의 모든 쉼터를 가져옵니다');
    }
    
    if (type != null) queryParams['type'] = type;
    if (facilities != null) queryParams['facilities'] = facilities;
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    endpoint += '?$queryString';
    
    print('🔍 API 엔드포인트: $endpoint');
    print('🌍 위치: 위도 $lat, 경도 $lng');
    print('📏 거리 제한: ${distance ?? "제한 없음"}');
    
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
