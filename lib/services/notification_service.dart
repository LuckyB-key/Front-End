import 'api_service.dart';

class NotificationService {
  // 알림 목록 조회
  static Future<Map<String, dynamic>> getNotifications() async {
    return await ApiService.get('/api/v1/notifications');
  }
  
  // 알림 설정 조회
  static Future<Map<String, dynamic>> getNotificationSettings() async {
    return await ApiService.get('/api/v1/notifications/settings');
  }
  
  // 알림 설정 수정
  static Future<Map<String, dynamic>> updateNotificationSettings(Map<String, dynamic> settings) async {
    return await ApiService.put('/api/v1/notifications/settings', settings);
  }
  
  // 특정 알림 읽음 처리
  static Future<Map<String, dynamic>> markNotificationAsRead(String notificationId) async {
    return await ApiService.post('/api/v1/notifications/$notificationId/read', {});
  }
  
  // 모든 알림 읽음 처리
  static Future<Map<String, dynamic>> markAllNotificationsAsRead() async {
    return await ApiService.post('/api/v1/notifications/read-all', {});
  }
}
