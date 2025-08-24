import 'api_service.dart';

class CheckinService {
  // 쉘터 체크인
  static Future<Map<String, dynamic>> checkinToShelter(String shelterId, Map<String, dynamic> checkinData) async {
    return await ApiService.post('/api/v1/shelters/$shelterId/checkins', checkinData);
  }
}
