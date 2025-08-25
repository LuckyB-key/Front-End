import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://43.201.63.235:8080';
  
  // 공통 헤더 생성
  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    print('ApiService - 저장된 토큰: $token');
    
    // 모든 저장된 키 확인
    final keys = prefs.getKeys();
    print('ApiService - 저장된 모든 키: $keys');
    
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    
    print('ApiService - 생성된 헤더: $headers');
    return headers;
  }
  
  // GET 요청
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('GET 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // POST 요청
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';
      
      print('ApiService POST - URL: $url');
      print('ApiService POST - Headers: $headers');
      print('ApiService POST - Data: $data');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(data),
      );
      
      print('ApiService POST - Status Code: ${response.statusCode}');
      print('ApiService POST - Response Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('POST 요청 실패: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('ApiService POST - Error: $e');
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // PUT 요청
  static Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(data),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('PUT 요청 실패: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // DELETE 요청
  static Future<bool> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
}
