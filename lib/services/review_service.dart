import 'api_service.dart';

class ReviewService {
  // 쉘터의 리뷰 목록 조회
  static Future<Map<String, dynamic>> getShelterReviews(String shelterId) async {
    return await ApiService.get('/api/v1/shelters/$shelterId/reviews');
  }
  
  // 리뷰 작성
  static Future<Map<String, dynamic>> createReview(String shelterId, Map<String, dynamic> reviewData) async {
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
