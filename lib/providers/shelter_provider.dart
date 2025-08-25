import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shelter.dart';
import '../services/shelter_service.dart';

class ShelterProvider with ChangeNotifier {
  List<Shelter> _shelters = [];
  List<Shelter> _filteredShelters = [];
  bool _isLoading = false;
  String _searchQuery = '';
  List<String> _activeFilters = [];
  bool _hasError = false;
  String _errorMessage = '';

  List<Shelter> get shelters => _shelters;
  List<Shelter> get filteredShelters => _filteredShelters;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  List<String> get activeFilters => _activeFilters;

  Future<void> fetchShelters({double? latitude, double? longitude}) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();
      
      // 좋아요 상태 로드
      await loadLikedShelters();
      
      final lat = latitude ?? 37.5665;
      final lng = longitude ?? 126.9780;
      
      print('🌍 쉼터 데이터 요청 시작');
      print('🌐 요청 위치: 위도 $lat, 경도 $lng');
      print('🌐 API 서버: http://43.201.63.235:8080');
      
      final response = await ShelterService.getShelters(
        lat: lat,
        lng: lng,
        // 거리 제한 없음 - 모든 쉼터 가져오기
        distance: 1000.0, // 10km 제한을 원한다면 이 줄을 활성화
      );
      
      print('📡 API 응답 상태: ${response['success']}');
      print('📊 응답 데이터 타입: ${response['data'].runtimeType}');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> sheltersData = response['data'];
        
        print('📈 데이터베이스에서 가져온 총 쉼터 수: ${sheltersData.length}');
        
        if (sheltersData.isNotEmpty) {
          _shelters = sheltersData.map((json) {
            final shelter = Shelter.fromJson(json);
            print('🏠 쉼터: ${shelter.name}');
            print('   🌐 위치: 위도 ${shelter.latitude}, 경도 ${shelter.longitude}');
            print('   🏃 거리: ${shelter.distance}km');
            print('   🚦 상태: ${shelter.status}');
            print('   👥 혼잡도: ${shelter.predictedCongestion}');
            print('   🖼️ 이미지 URL: ${shelter.imageUrl.isNotEmpty ? shelter.imageUrl : "없음"}');
            print('   ---');
            return shelter;
          }).toList();
          _filteredShelters = _shelters;
          
          print('✅ 성공적으로 ${_shelters.length}개의 쉼터를 불러왔습니다.');
          print('🗺️ 지도에 마커를 표시할 준비가 되었습니다.');
        } else {
          print('⚠️ 데이터베이스에 쉼터가 없습니다.');
          _shelters = [];
          _filteredShelters = [];
        }
      } else {
        print('❌ API 응답 실패: ${response['message']}');
        throw Exception(response['message'] ?? '쉘터 목록을 불러오는데 실패했습니다.');
      }
    } catch (e) {
      print('💥 쉘터 목록 조회 오류: $e');
      _hasError = true;
      _errorMessage = e.toString();
      _shelters = [];
      _filteredShelters = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      if (_searchQuery.isNotEmpty) {
        if (!shelter.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !shelter.address.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

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

  // 좋아요 상태를 저장하는 Set
  Set<String> _likedShelters = {};
  Set<String> get likedShelters => _likedShelters;

  // 좋아요 상태 확인
  bool isLiked(String shelterId) {
    return _likedShelters.contains(shelterId);
  }

  // 좋아요 토글
  Future<void> toggleLike(String shelterId) async {
    if (_likedShelters.contains(shelterId)) {
      _likedShelters.remove(shelterId);
      print('❤️ 좋아요 해제: $shelterId');
    } else {
      _likedShelters.add(shelterId);
      print('❤️ 좋아요 추가: $shelterId');
    }
    
    // SharedPreferences에 저장
    await _saveLikedShelters();
    notifyListeners();
  }

  // 좋아요 상태 로드
  Future<void> loadLikedShelters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final likedSheltersList = prefs.getStringList('liked_shelters') ?? [];
      _likedShelters = likedSheltersList.toSet();
      print('📱 저장된 좋아요 쉼터 로드: ${_likedShelters.length}개');
      notifyListeners();
    } catch (e) {
      print('❌ 좋아요 상태 로드 실패: $e');
    }
  }

  // 좋아요 상태 저장
  Future<void> _saveLikedShelters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('liked_shelters', _likedShelters.toList());
      print('💾 좋아요 상태 저장 완료: ${_likedShelters.length}개');
    } catch (e) {
      print('❌ 좋아요 상태 저장 실패: $e');
    }
  }
}
