import 'api_service.dart';

class UserService {
  // 내 정보 조회
  static Future<Map<String, dynamic>> getMyInfo() async {
    return await ApiService.get('/api/v1/users/me');
  }
  
  // 내 정보 수정
  static Future<Map<String, dynamic>> updateMyInfo(Map<String, dynamic> userData) async {
    return await ApiService.put('/api/v1/users/me', userData);
  }
  
  // 특정 사용자의 리뷰 조회
  static Future<Map<String, dynamic>> getUserReviews(String userId) async {
    return await ApiService.get('/api/v1/users/$userId/reviews');
  }
  
  // 내 체크인 기록 조회
  static Future<Map<String, dynamic>> getMyCheckins() async {
    return await ApiService.get('/api/v1/users/me/checkins');
  }
}
