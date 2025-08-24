import 'package:flutter/foundation.dart';
import '../models/shelter.dart';
import '../services/shelter_service.dart';

class ShelterProvider with ChangeNotifier {
  List<Shelter> _shelters = [];
  List<Shelter> _filteredShelters = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _activeFilters = [];

  List<Shelter> get shelters => _shelters;
  List<Shelter> get filteredShelters => _filteredShelters;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  List<String> get activeFilters => _activeFilters;

  // 더미 데이터로 초기화
  void initializeShelters() {
    _shelters = [
      Shelter(
        id: '1',
        name: '시원한 도서관',
        address: '서울시 강남구 테헤란로 123',
        openingDays: '월-금 09:00-18:00',
        maxCapacity: 50,
        congestion: '보통',
        facilities: ['에어컨', 'WiFi', '정수기', '화장실'],
        rating: 4.5,
        likes: 128,
        imageUrl: 'https://via.placeholder.com/150',
        latitude: 37.5665,
        longitude: 126.9780,
      ),
      Shelter(
        id: '2',
        name: '아늑한 카페',
        address: '서울시 마포구 홍대로 456',
        openingDays: '매일 07:00-22:00',
        maxCapacity: 30,
        congestion: '여유',
        facilities: ['에어컨', 'WiFi', '음료', '화장실'],
        rating: 4.2,
        likes: 95,
        imageUrl: 'https://via.placeholder.com/150',
        latitude: 37.5519,
        longitude: 126.9250,
      ),
      Shelter(
        id: '3',
        name: '쾌적한 쇼핑몰',
        address: '서울시 영등포구 여의대로 789',
        openingDays: '매일 10:00-21:00',
        maxCapacity: 100,
        congestion: '혼잡',
        facilities: ['에어컨', 'WiFi', '식당', '화장실', '주차장'],
        rating: 4.0,
        likes: 203,
        imageUrl: 'https://via.placeholder.com/150',
        latitude: 37.5219,
        longitude: 126.9240,
      ),
      Shelter(
        id: '4',
        name: '조용한 공원 쉼터',
        address: '서울시 송파구 올림픽로 321',
        openingDays: '매일 06:00-22:00',
        maxCapacity: 20,
        congestion: '여유',
        facilities: ['그늘', '벤치', '화장실', '음수대'],
        rating: 4.7,
        likes: 156,
        imageUrl: 'https://via.placeholder.com/150',
        latitude: 37.5139,
        longitude: 127.1006,
      ),
      Shelter(
        id: '5',
        name: '전망 좋은 은행',
        address: '서울시 중구 을지로 654',
        openingDays: '월-금 09:00-16:00',
        maxCapacity: 15,
        congestion: '보통',
        facilities: ['에어컨', 'WiFi', '화장실', 'ATM'],
        rating: 4.3,
        likes: 87,
        imageUrl: 'https://via.placeholder.com/150',
        latitude: 37.5665,
        longitude: 126.9780,
      ),
    ];
    _filteredShelters = _shelters;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void addFilter(String filter) {
    if (!_activeFilters.contains(filter)) {
      _activeFilters.add(filter);
      _applyFilters();
    }
  }

  void removeFilter(String filter) {
    _activeFilters.remove(filter);
    _applyFilters();
  }

  void clearFilters() {
    _activeFilters.clear();
    _searchQuery = '';
    _applyFilters();
  }

  void _applyFilters() {
    _filteredShelters = _shelters.where((shelter) {
      // 검색어 필터
      if (_searchQuery.isNotEmpty) {
        if (!shelter.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !shelter.address.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // 추가 필터들 (예: 혼잡도, 시설 등)
      for (String filter in _activeFilters) {
        if (filter == '여유' && shelter.congestion != '여유') return false;
        if (filter == '보통' && shelter.congestion != '보통') return false;
        if (filter == '혼잡' && shelter.congestion != '혼잡') return false;
        if (filter == 'WiFi' && !shelter.facilities.contains('WiFi')) return false;
        if (filter == '에어컨' && !shelter.facilities.contains('에어컨')) return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  void toggleLike(String shelterId) {
    final index = _shelters.indexWhere((shelter) => shelter.id == shelterId);
    if (index != -1) {
      final shelter = _shelters[index];
      _shelters[index] = Shelter(
        id: shelter.id,
        name: shelter.name,
        address: shelter.address,
        openingDays: shelter.openingDays,
        maxCapacity: shelter.maxCapacity,
        congestion: shelter.congestion,
        facilities: shelter.facilities,
        rating: shelter.rating,
        likes: shelter.likes + 1,
        imageUrl: shelter.imageUrl,
        latitude: shelter.latitude,
        longitude: shelter.longitude,
      );
      _applyFilters();
    }
  }

  Future<void> fetchShelters() async {
    try {
      final response = await ShelterService.getShelters();
      // 응답 처리 로직
      notifyListeners();
    } catch (e) {
      // 에러 처리
    }
  }
}
