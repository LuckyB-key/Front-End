import 'api_service.dart';

class QrCodeService {
  // QR 코드 저장
  static Future<Map<String, dynamic>> saveQrCode(String shelterId, Map<String, dynamic> qrData) async {
    return await ApiService.post('/api/v1/qr/save/$shelterId', qrData);
  }
  
  // QR 코드 디코드
  static Future<Map<String, dynamic>> decodeQrCode(Map<String, dynamic> qrData) async {
    return await ApiService.post('/api/v1/qr/decode', qrData);
  }
  
  // QR 코드 생성
  static Future<Map<String, dynamic>> generateQrCode(String shelterId) async {
    return await ApiService.get('/api/v1/qr/generate/$shelterId');
  }
}
