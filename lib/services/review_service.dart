import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review.dart';
import 'api_service.dart';

class ReviewService {
  // 쉘터의 리뷰 목록 조회
  static Future<List<Review>> getShelterReviews(String shelterId, {
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'size': size.toString(),
      };
      
      String endpoint = '/api/v1/shelters/$shelterId/reviews';
      final queryString = queryParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      endpoint += '?$queryString';
      
      print('Review API call: $endpoint');
      
      // 직접 HTTP 요청 처리
      final response = await http.get(
        Uri.parse('http://43.201.63.235:8080$endpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      print('Review API response status: ${response.statusCode}');
      print('Review API response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((json) => Review.fromJson(json)).toList();
      } else {
        print('Review API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Review fetch error: $e');
      return [];
    }
  }
  
  // 리뷰 작성
  static Future<Map<String, dynamic>> createReview(String shelterId, Map<String, dynamic> reviewData) async {
    // ApiService 사용 (Map 반환)
    return await ApiService.post('/api/v1/shelters/$shelterId/reviews', reviewData);
  }
  
  // 리뷰 수정
  static Future<Map<String, dynamic>> updateReview(String reviewId, Map<String, dynamic> reviewData) async {
    return await ApiService.put('/api/v1/reviews/$reviewId', reviewData);
  }
  
  // 리뷰 삭제
  static Future<bool> deleteReview(String reviewId) async {
    return await ApiService.delete('/api/v1/reviews/$reviewId');
  }
}
