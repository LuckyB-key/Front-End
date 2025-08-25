import 'package:flutter/foundation.dart';
import '../models/review.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  List<Review> _reviews = [];
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';
  String? _currentShelterId;

  List<Review> get reviews => _reviews;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // 리뷰 목록 조회
  Future<void> fetchReviews(String shelterId, {int page = 0, int size = 10}) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _currentShelterId = shelterId;
      notifyListeners();
      
      print('Review fetch start: $shelterId'); // 한글 이모지 제거
      
      final reviews = await ReviewService.getShelterReviews(shelterId, page: page, size: size);
      
      if (page == 0) {
        // 첫 페이지면 기존 리뷰 초기화
        _reviews = reviews;
      } else {
        // 다음 페이지면 기존 리뷰에 추가
        _reviews.addAll(reviews);
      }
      
      print('Reviews loaded: ${reviews.length}'); // 한글 이모지 제거
      
    } catch (e) {
      print('Review fetch error: $e'); // 한글 이모지 제거
      _hasError = true;
      _errorMessage = e.toString();
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 리뷰 초기화
  void clearReviews() {
    _reviews = [];
    _currentShelterId = null;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
