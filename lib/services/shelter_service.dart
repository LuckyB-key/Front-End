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
  
  // AI 추천 쉼터 조회 (실제 쉼터 데이터)
  static Future<Map<String, dynamic>> getAiRecommendations({
    required double latitude,
    required double longitude,
    List<String>? preferences,
    String? category,
  }) async {
    String endpoint = '/api/v1/shelters/recommendations';
    
    // 쿼리 파라미터 구성
    final queryParams = <String, String>{
      'lat': latitude.toString(),
      'lng': longitude.toString(),
    };
    
    if (category != null) {
      queryParams['category'] = category;
    }
    
    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    endpoint += '?$queryString';
    
    print('🌍 AI 추천 쉼터 API 엔드포인트: $endpoint');
    print('📍 위치: 위도 $latitude, 경도 $longitude');
    
    return await ApiService.get(endpoint);
  }

  // 이미지 프록시 서비스 추가
  static String getImageProxyUrl(String originalUrl) {
    // 백엔드에서 제공하는 이미지 프록시 엔드포인트 사용
    return 'http://43.201.63.235:8080/api/v1/image/proxy?url=${Uri.encodeComponent(originalUrl)}';
  }
}
