import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // OpenWeatherMap API
  static const String apiKey = 'ae68f3a144dbb9b524a381497b7e16e9';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  // 현재 날씨 정보 가져오기
  static Future<Map<String, dynamic>> getCurrentWeather(double lat, double lon) async {
    try {
      final url = '$baseUrl/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr';
      
      print('🌤️ OpenWeatherMap API 호출: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('🌤️ OpenWeatherMap API 응답 상태: ${response.statusCode}');
      print('🌤️ OpenWeatherMap API 응답: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': {
            'temperature': data['main']['temp'].toDouble(),
            'humidity': data['main']['humidity'].toInt(),
            'description': data['weather'][0]['description'],
            'icon': data['weather'][0]['icon'],
            'city': data['name'],
            'country': data['sys']['country'],
          }
        };
      } else {
        print('❌ OpenWeatherMap API 오류: ${response.statusCode}');
        return {
          'success': false,
          'error': '날씨 정보를 가져올 수 없습니다.',
        };
      }
    } catch (e) {
      print('❌ OpenWeatherMap API 예외: $e');
      return {
        'success': false,
        'error': '날씨 정보를 가져오는 중 오류가 발생했습니다.',
      };
    }
  }

  // 도시명으로 날씨 정보 가져오기
  static Future<Map<String, dynamic>> getWeatherByCity(String city) async {
    try {
      final url = '$baseUrl/weather?q=$city&appid=$apiKey&units=metric&lang=kr';
      
      print('🌤️ 도시 날씨 API 호출: $url');
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': {
            'temperature': data['main']['temp'].toDouble(),
            'humidity': data['main']['humidity'].toInt(),
            'description': data['weather'][0]['description'],
            'icon': data['weather'][0]['icon'],
            'city': data['name'],
            'country': data['sys']['country'],
          }
        };
      } else {
        return {
          'success': false,
          'error': '날씨 정보를 가져올 수 없습니다.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': '날씨 정보를 가져오는 중 오류가 발생했습니다.',
      };
    }
  }
}
