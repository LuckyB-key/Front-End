import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/ai_recommendation_provider.dart'; // AI 추천 Provider 추가
import '../models/shelter.dart';
import '../models/ai_recommendation.dart'; // AI 추천 모델 추가
import 'package:geolocator/geolocator.dart'; // 위치 서비스 추가

class ShelterList extends StatefulWidget {
  final Function(Shelter)? onShelterSelected;
  
  const ShelterList({
    super.key,
    this.onShelterSelected,
  });

  @override
  State<ShelterList> createState() => _ShelterListState();
}

class _ShelterListState extends State<ShelterList> {
  @override
  void initState() {
    super.initState();
    // 날씨 정보와 AI 추천 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
      _loadAiRecommendations();
    });
  }

  // AI 추천 데이터 로드
  Future<void> _loadAiRecommendations() async {
    try {
      // 현재 위치 가져오기
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ 위치 서비스 비활성화 - 서울양재at센터로 기본 설정');
        _fetchAiRecommendationsWithDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ 위치 권한 거부 - 서울양재at센터로 기본 설정');
          _fetchAiRecommendationsWithDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ 위치 권한 영구 거부 - 서울양재at센터로 기본 설정');
        _fetchAiRecommendationsWithDefaultLocation();
        return;
      }

      // 고정밀 위치 가져오기
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        
        print('✅ 위치 획득 성공 - AI 추천 데이터 로드');
        context.read<AiRecommendationProvider>().setCurrentPosition(position);
        await context.read<AiRecommendationProvider>().fetchAiRecommendations(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        print('❌ 위치 가져오기 실패 - 서울양재at센터로 기본 설정: $e');
        _fetchAiRecommendationsWithDefaultLocation();
      }
    } catch (e) {
      print('❌ AI 추천 데이터 로드 오류: $e');
      _fetchAiRecommendationsWithDefaultLocation();
    }
  }

  // 기본 위치로 AI 추천 데이터 로드
  Future<void> _fetchAiRecommendationsWithDefaultLocation() async {
    const double defaultLat = 37.4692; // 서울양재at센터
    const double defaultLon = 127.0334;
    
    await context.read<AiRecommendationProvider>().fetchAiRecommendations(
      latitude: defaultLat,
      longitude: defaultLon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 온도/습도 섹션 (기존 코드 유지)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // "현재 위치의" 텍스트
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  return Text(
                    '현재 ${weatherProvider.city}는',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // 온도/습도 컨테이너 (기존 코드 유지)
              Consumer<WeatherProvider>(
                builder: (context, weatherProvider, child) {
                  if (weatherProvider.isLoading) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 8),
                            Text('날씨 정보를 불러오는 중...'),
                          ],
                        ),
                      ),
                    );
                  }

                  if (weatherProvider.hasError) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red[200]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                          const SizedBox(height: 8),
                          Text(
                            '날씨 정보를 불러올 수 없습니다',
                            style: TextStyle(color: Colors.red[600]),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              weatherProvider.fetchWeatherByLocation();
                            },
                            child: const Text('다시 시도'),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey[200]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // 온도 컨테이너
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.orange[200]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.thermostat,
                                  color: Colors.orange[600],
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${weatherProvider.temperature.round()}°C',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[600],
                                  ),
                                ),
                                Text(
                                  '온도',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // 습도 컨테이너
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.water_drop,
                                  color: Colors.blue[600],
                                  size: 28,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${weatherProvider.humidity}%',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                Text(
                                  '습도',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // AI 추천 섹션
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.purple[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 추천 쉼터',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI 추천 리스트
          Consumer<AiRecommendationProvider>(
            builder: (context, aiProvider, child) {
              if (aiProvider.isLoading) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('AI 추천을 분석하는 중...'),
                      ],
                    ),
                  ),
                );
              }

              if (aiProvider.hasError) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[400], size: 32),
                        const SizedBox(height: 8),
                        Text(
                          'AI 추천을 불러올 수 없습니다',
                          style: TextStyle(color: Colors.red[600]),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadAiRecommendations,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (aiProvider.recommendations.isEmpty) {
                return Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology_outlined, size: 32, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('AI 추천 쉼터가 없습니다'),
                        const SizedBox(height: 4),
                        Text('현재 위치에서 추천할 쉼터를 찾지 못했습니다', 
                             style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                itemCount: aiProvider.recommendations.length,
                itemBuilder: (context, index) {
                  final recommendation = aiProvider.recommendations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.purple[600],
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'AI 추천 ${index + 1}',
                              style: TextStyle(
                                color: Colors.purple[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation.name,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '거리: ${recommendation.distance.toStringAsFixed(1)}km',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '상태: ${recommendation.status}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (recommendation.facilities.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            '시설: ${recommendation.facilities.take(2).join(', ')}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 2),
                        Text(
                          '혼잡도: ${recommendation.predictedCongestion}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
          
          const SizedBox(height: 24),
          
          // 전체 쉼터 섹션
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue[600],
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '전체 쉼터',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 전체 쉼터 리스트
          Expanded(
            child: Consumer<ShelterProvider>(
              builder: (context, shelterProvider, child) {
                if (shelterProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('쉘터 정보를 불러오는 중...'),
                      ],
                    ),
                  );
                }
                
                if (shelterProvider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red),
                        SizedBox(height: 16),
                        Text('오류가 발생했습니다'),
                        SizedBox(height: 8),
                        Text(shelterProvider.errorMessage, 
                             style: TextStyle(color: Colors.grey),
                             textAlign: TextAlign.center),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            shelterProvider.fetchShelters();
                          },
                          child: Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }
                
                if (shelterProvider.filteredShelters.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('주변에 쉘터가 없습니다'),
                        SizedBox(height: 8),
                        Text('다른 위치에서 시도해보세요', 
                             style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: shelterProvider.filteredShelters.length,
                  itemBuilder: (context, index) {
                    final shelter = shelterProvider.filteredShelters[index];
                    return ShelterListItem(
                      shelter: shelter,
                      onTap: () => widget.onShelterSelected?.call(shelter),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShelterListItem extends StatelessWidget {
  final Shelter shelter;
  final VoidCallback onTap;

  const ShelterListItem({
    Key? key,
    required this.shelter,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            offset: const Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 쉘터명과 이미지
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '쉼터명',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shelter.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '쉼터 정보',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 이미지 플레이스홀더
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 30,
                ),
              ),
              
              const SizedBox(width: 8),
              
              // 화살표 아이콘
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 쉘터 정보 리스트 - 실제 API 데이터만 표시
          Column(
            children: [
              _buildInfoRow('주소', shelter.address),
              _buildInfoRow('거리', '${shelter.distance.toStringAsFixed(1)}km'),
              _buildInfoRow('상태', shelter.status),
              _buildInfoRow('혼잡도', shelter.predictedCongestion),
              // API에서 제공하지 않는 정보는 제거
              // _buildInfoRow('개방 요일', shelter.openingDays),
              // _buildInfoRow('최대 수용 인원', '${shelter.maxCapacity}명'),
              // _buildInfoRow('시설', shelter.facilities.join(', ')),
              // _buildInfoRow('리뷰', '${shelter.rating}점'),
              // _buildInfoRow('좋아요', '${shelter.likes}개'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    print('🏠 상세보기 버튼 클릭: ${shelter.name}');
                    // 상세 정보 보기 - 지도에 모달 표시
                    onTap(); // 이 함수가 MapSection의 _showShelterModal을 호출해야 함
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${shelter.name} 상세 정보를 지도에서 확인합니다.'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('상세보기'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // 좋아요 토글
                    context.read<ShelterProvider>().toggleLike(shelter.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${shelter.name}에 좋아요를 눌렀습니다!'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('좋아요'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '• $label',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
