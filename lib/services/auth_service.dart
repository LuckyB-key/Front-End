import 'api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // UUID 인증
  static Future<Map<String, dynamic>> authenticateWithUuid(Map<String, dynamic> uuidData) async {
    final response = await ApiService.post('/api/v1/auth/uuid', uuidData);
    
    // 토큰이 응답에 포함되어 있다면 저장
    if (response['token'] != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', response['token']);
    }
    
    return response;
  }
  
  // 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // 토큰 확인
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
