import 'package:flutter/foundation.dart';
import '../services/weather_service.dart';
import 'package:geolocator/geolocator.dart';

class WeatherProvider with ChangeNotifier {
  double _temperature = 0.0;
  int _humidity = 0;
  String _description = '';
  String _city = '대구';
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  double get temperature => _temperature;
  int get humidity => _humidity;
  String get description => _description;
  String get city => _city;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // 현재 위치로 날씨 정보 가져오기
  Future<void> fetchWeatherByLocation() async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 위치 서비스 비활성화 - 서울 양재로 기본 설정');
        await _fetchWeatherForDefaultLocation();
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('📍 위치 권한 거부 - 서울 양재로 기본 설정');
          await _fetchWeatherForDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('📍 위치 권한 영구 거부 - 서울 양재로 기본 설정');
        await _fetchWeatherForDefaultLocation();
        return;
      }

      // 현재 위치 가져오기 (타임아웃 설정)
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10), // 10초 타임아웃
        ).timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw Exception('위치 정보를 가져오는 시간이 초과되었습니다.');
          },
        );

        print('📍 현재 위치: ${position.latitude}, ${position.longitude}');

        // 날씨 정보 가져오기
        final weatherResponse = await WeatherService.getCurrentWeather(
          position.latitude,
          position.longitude,
        );

        if (weatherResponse['success']) {
          final data = weatherResponse['data'];
          _temperature = data['temperature'];
          _humidity = data['humidity'];
          _description = data['description'];
          _city = data['city'];
          print('🌤️ 날씨 정보 로드 완료: $_city, ${_temperature}°C, $_humidity%');
        } else {
          print('❌ 날씨 API 오류 - 서울 양재로 기본 설정');
          await _fetchWeatherForDefaultLocation();
        }
      } catch (e) {
        print('❌ 위치 정보 가져오기 실패: $e - 서울 양재로 기본 설정');
        await _fetchWeatherForDefaultLocation();
      }
    } catch (e) {
      print('❌ 날씨 정보 로드 오류: $e - 서울 양재로 기본 설정');
      await _fetchWeatherForDefaultLocation();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 서울 양재 기본 위치로 날씨 정보 가져오기
  Future<void> _fetchWeatherForDefaultLocation() async {
    try {
      // 서울 양재 좌표 (위도: 37.4692, 경도: 127.0334)
      const double defaultLat = 37.4692;
      const double defaultLon = 127.0334;
      
      print('📍 서울 양재 기본 위치로 날씨 정보 요청');
      
      final weatherResponse = await WeatherService.getCurrentWeather(
        defaultLat,
        defaultLon,
      );

      if (weatherResponse['success']) {
        final data = weatherResponse['data'];
        _temperature = data['temperature'];
        _humidity = data['humidity'];
        _description = data['description'];
        _city = '서울 양재';
        print('🌤️ 서울 양재 날씨 정보 로드 완료: $_city, ${_temperature}°C, $_humidity%');
      } else {
        // API도 실패하면 기본값 설정
        _temperature = 23.0;
        _humidity = 65;
        _description = '맑음';
        _city = '서울 양재';
        print('📍 기본값으로 설정: $_city, ${_temperature}°C, $_humidity%');
      }
    } catch (e) {
      print('❌ 서울 양재 날씨 정보 로드 실패: $e - 기본값 설정');
      // 최종 기본값
      _temperature = 23.0;
      _humidity = 65;
      _description = '맑음';
      _city = '서울 양재';
    }
  }

  // 도시명으로 날씨 정보 가져오기
  Future<void> fetchWeatherByCity(String city) async {
    try {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      notifyListeners();

      final weatherResponse = await WeatherService.getWeatherByCity(city);

      if (weatherResponse['success']) {
        final data = weatherResponse['data'];
        _temperature = data['temperature'];
        _humidity = data['humidity'];
        _description = data['description'];
        _city = data['city'];
        print('🌤️ 도시 날씨 정보 로드 완료: $_city, ${_temperature}°C, $_humidity%');
      } else {
        _hasError = true;
        _errorMessage = weatherResponse['error'];
      }
    } catch (e) {
      print('❌ 도시 날씨 정보 로드 오류: $e');
      _hasError = true;
      _errorMessage = '날씨 정보를 가져올 수 없습니다.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 날씨 정보 초기화
  void clearWeather() {
    _temperature = 0.0;
    _humidity = 0;
    _description = '';
    _city = '대구';
    _hasError = false;
    _errorMessage = '';
    notifyListeners();
  }
}
