import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/ai_recommendation_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/map_section.dart';
import '../models/shelter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Shelter? selectedShelter;

  @override
  void initState() {
    super.initState();
    // API에서 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(' HomeScreen 초기화 - 쉼터 데이터 로드 시작');
      context.read<ShelterProvider>().fetchShelters();
    });
  }

  void _onShelterSelected(Shelter shelter) {
    print('🏠 쉼터 선택됨: ${shelter.name}');
    setState(() {
      selectedShelter = shelter;
    });
    
    // MapSection에 전달
    print('️ MapSection에 선택된 쉼터 전달');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // 상단 바
          TopBar(),

          // 메인 콘텐츠
          Expanded(
            child: Row(
              children: [
                // 왼쪽 사이드바
                Sidebar(),

                // 메인 콘텐츠 영역
                Expanded(
                  child: Row(
                    children: [
                      // 왼쪽: 날씨 + AI 추천 (세로 배치)
                      Expanded(
                        flex: 1,
                        child: Column(
                          children: [
                            // 날씨 섹션
                            Expanded(
                              flex: 1,
                              child: WeatherSection(),
                            ),
                            
                            // AI 추천 섹션
                            Expanded(
                              flex: 2,
                              child: AiRecommendationSection(),
                            ),
                          ],
                        ),
                      ),

                      // 중앙: 전체 쉼터 리스트
                      Expanded(
                        flex: 1,
                        child: AllSheltersSection(
                          onShelterSelected: _onShelterSelected,
                        ),
                      ),

                      // 오른쪽: 지도 섹션 (축소)
                      Expanded(
                        flex: 2,
                        child: MapSection(
                          selectedShelter: selectedShelter,
                          onShelterDeselected: () {
                            print('❌ 쉼터 선택 해제');
                            setState(() {
                              selectedShelter = null;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 날씨 섹션 위젯
class WeatherSection extends StatefulWidget {
  @override
  State<WeatherSection> createState() => _WeatherSectionState();
}

class _WeatherSectionState extends State<WeatherSection> {
  @override
  void initState() {
    super.initState();
    // 날씨 정보 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherProvider>().fetchWeatherByLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9ECEF), width: 1),
          bottom: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Icon(
                Icons.wb_sunny,
                color: Colors.orange[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '현재 날씨',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 날씨 정보
          Expanded(
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                if (weatherProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('날씨 정보를 불러오는 중...'),
                      ],
                    ),
                  );
                }

                if (weatherProvider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
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

                return Row(
                  children: [
                    // 온도
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thermostat,
                              color: Colors.orange[600],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weatherProvider.temperature.round()}°C',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[600],
                              ),
                            ),
                            Text(
                              '온도',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // 습도
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.water_drop,
                              color: Colors.blue[600],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${weatherProvider.humidity}%',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[600],
                              ),
                            ),
                            Text(
                              '습도',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// AI 추천 섹션 위젯
class AiRecommendationSection extends StatefulWidget {
  @override
  State<AiRecommendationSection> createState() => _AiRecommendationSectionState();
}

class _AiRecommendationSectionState extends State<AiRecommendationSection> {
  @override
  void initState() {
    super.initState();
    _loadAiRecommendations();
  }

  Future<void> _loadAiRecommendations() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fetchAiRecommendationsWithDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fetchAiRecommendationsWithDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _fetchAiRecommendationsWithDefaultLocation();
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        
        context.read<AiRecommendationProvider>().setCurrentPosition(position);
        await context.read<AiRecommendationProvider>().fetchAiRecommendations(
          latitude: position.latitude,
          longitude: position.longitude,
        );
      } catch (e) {
        _fetchAiRecommendationsWithDefaultLocation();
      }
    } catch (e) {
      _fetchAiRecommendationsWithDefaultLocation();
    }
  }

  Future<void> _fetchAiRecommendationsWithDefaultLocation() async {
    const double defaultLat = 37.4692;
    const double defaultLon = 127.0334;
    
    await context.read<AiRecommendationProvider>().fetchAiRecommendations(
      latitude: defaultLat,
      longitude: defaultLon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Icon(
                Icons.psychology,
                color: Colors.purple[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'AI 추천',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // AI 추천 리스트
          Expanded(
            child: Consumer<AiRecommendationProvider>(
              builder: (context, aiProvider, child) {
                if (aiProvider.isLoading) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 8),
                        Text('AI 추천을 분석하는 중...'),
                      ],
                    ),
                  );
                }

                if (aiProvider.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[400], size: 24),
                        const SizedBox(height: 8),
                        Text(
                          'AI 추천을 불러올 수 없습니다',
                          style: TextStyle(color: Colors.red[600], fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _loadAiRecommendations,
                          child: const Text('다시 시도'),
                        ),
                      ],
                    ),
                  );
                }

                if (aiProvider.recommendations.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.psychology_outlined, size: 24, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text('AI 추천이 없습니다', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('현재 위치에서 추천할 쉼터를 찾지 못했습니다', 
                             style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                      ],
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
                            recommendation.message.isNotEmpty 
                                ? recommendation.message 
                                : 'AI가 추천하는 쉼터입니다',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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

// 전체 쉼터 섹션 위젯
class AllSheltersSection extends StatelessWidget {
  final Function(Shelter)? onShelterSelected;

  const AllSheltersSection({
    super.key,
    this.onShelterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Color(0xFFE9ECEF), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: Colors.blue[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                '전체 쉼터',
                style: TextStyle(
                  fontSize: 18,
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
                        Icon(Icons.error_outline, size: 48, color: Colors.red),
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
                        Icon(Icons.location_off, size: 48, color: Colors.grey),
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
                      onTap: () => onShelterSelected?.call(shelter),
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

// ShelterListItem 위젯 (기존 코드 재사용)
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 쉘터명
          Text(
            shelter.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 쉘터 정보
          Column(
            children: [
              _buildInfoRow('주소', shelter.address),
              _buildInfoRow('거리', '${shelter.distance.toStringAsFixed(1)}km'),
              _buildInfoRow('상태', shelter.status),
              _buildInfoRow('혼잡도', shelter.predictedCongestion),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('상세보기', style: TextStyle(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
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
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('좋아요', style: TextStyle(fontSize: 12)),
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
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '• $label',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
