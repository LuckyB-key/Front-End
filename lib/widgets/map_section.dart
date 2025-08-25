import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../providers/review_provider.dart';
import '../models/shelter.dart';
import '../models/review.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapSection extends StatefulWidget {
  final Shelter? selectedShelter;
  final VoidCallback? onShelterDeselected;

  const MapSection({
    super.key,
    this.selectedShelter,
    this.onShelterDeselected,
  });

  @override
  State<MapSection> createState() => _MapSectionState();
}

class _MapSectionState extends State<MapSection> with TickerProviderStateMixin {
  Shelter? _localSelectedShelter;
  bool _isMapLoaded = false;
  late AnimationController _modalAnimationController;
  late Animation<Offset> _modalSlideAnimation;
  late Animation<double> _modalFadeAnimation;
  late MapController _mapController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _localSelectedShelter = widget.selectedShelter;
    
    // 지도 컨트롤러 초기화
    _mapController = MapController();
    
    // 애니메이션 컨트롤러 초기화
    _modalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 슬라이드 애니메이션 (아래에서 위로)
    _modalSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1), // 아래에서 시작
      end: Offset.zero, // 원래 위치로
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOutCubic, // 부드러운 이징
    ));
    
    // 페이드 애니메이션
    _modalFadeAnimation = Tween<double>(
      begin: 0.0, // 투명
      end: 1.0, // 완전 불투명
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOut,
    ));
    
    // 지도 로드 완료 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isMapLoaded = true;
      });
    });
  }

  @override
  void didUpdateWidget(MapSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedShelter != oldWidget.selectedShelter) {
      setState(() {
        _localSelectedShelter = widget.selectedShelter;
      });
      
      // 쉼터가 선택되면 모달 애니메이션 시작
      if (widget.selectedShelter != null) {
        _modalAnimationController.forward();
        
        // 선택된 쉼터로 지도 중심 이동
        _moveToShelter(widget.selectedShelter!);
      } else {
        // 쉼터 선택 해제 시 모달 애니메이션 역재생
        _modalAnimationController.reverse();
      }
    }
  }

  // 선택된 쉼터로 지도 중심 이동
  void _moveToShelter(Shelter shelter) {
    final latLng = LatLng(shelter.latitude, shelter.longitude);
    _mapController.move(latLng, 15.0); // 줌 레벨 15로 이동
  }

  // 현재 위치로 이동
  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 위치 서비스가 활성화되어 있는지 확인
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('위치 서비스 비활성화 - 서울 양재로 이동');
        _moveToDefaultLocation();
        return;
      }

      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('위치 권한 거부 - 서울 양재로 이동');
          _moveToDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('위치 권한 영구 거부 - 서울 양재로 이동');
        _moveToDefaultLocation();
        return;
      }

      // 현재 위치 가져오기 (여러 방법 시도)
      Position? position;
      
      try {
        // 방법 1: 고정밀 위치 (타임아웃 10초)
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        print('✅ 고정밀 위치 획득 성공');
      } catch (e) {
        print('⚠️ 고정밀 위치 실패, 중간 정밀도 시도: $e');
        
        try {
          // 방법 2: 중간 정밀도 위치 (타임아웃 15초)
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 15),
          );
          print('✅ 중간 정밀도 위치 획득 성공');
        } catch (e) {
          print('⚠️ 중간 정밀도 위치 실패, 낮은 정밀도 시도: $e');
          
          try {
            // 방법 3: 낮은 정밀도 위치 (타임아웃 20초)
            position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 20),
            );
            print('✅ 낮은 정밀도 위치 획득 성공');
          } catch (e) {
            print('❌ 모든 위치 정밀도 실패: $e');
            throw e;
          }
        }
      }

      if (position != null) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        // 지도를 현재 위치로 이동
        final latLng = LatLng(position.latitude, position.longitude);
        _mapController.move(latLng, 15.0);

        // 성공 메시지 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('현재 위치로 이동했습니다 (${position.accuracy.toStringAsFixed(0)}m 정확도)'),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('위치 정보를 가져올 수 없습니다.');
      }

    } catch (e) {
      print('❌ 위치 정보 가져오기 실패: $e - 서울 양재로 이동');
      _moveToDefaultLocation();
    }
  }

  // 서울 양재 기본 위치로 이동
  void _moveToDefaultLocation() {
    setState(() {
      _isLoadingLocation = false;
    });

    // 서울 양재 좌표 (위도: 37.4692, 경도: 127.0334)
    const double defaultLat = 37.4692;
    const double defaultLon = 127.0334;
    
    // 기본 위치 설정 (Position 객체 생성)
    _currentPosition = Position(
      latitude: defaultLat,
      longitude: defaultLon,
      timestamp: DateTime.now(),
      accuracy: 1000, // 1km 정확도로 설정
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );

    // 지도를 서울 양재로 이동
    final latLng = LatLng(defaultLat, defaultLon);
    _mapController.move(latLng, 15.0);

    // 안내 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('위치 서비스를 사용할 수 없어 서울 양재로 이동했습니다'),
        backgroundColor: Colors.orange[600],
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: '설정',
          textColor: Colors.white,
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  // 위치 권한 다이얼로그 표시
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('위치 권한 필요'),
        content: const Text('현재 위치를 가져오려면 위치 권한이 필요합니다. 설정에서 위치 권한을 허용해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Geolocator.openAppSettings();
            },
            child: const Text('설정 열기'),
          ),
        ],
      ),
    );
  }

  // 줌 인
  void _zoomIn() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom + 1);
  }

  // 줌 아웃
  void _zoomOut() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom - 1);
  }

  void _closeModal() {
    // 모달 닫기 애니메이션
    _modalAnimationController.reverse().then((_) {
      setState(() {
        _localSelectedShelter = null; // 로컬 상태도 초기화
      });
      if (widget.onShelterDeselected != null) {
        widget.onShelterDeselected!();
      }
    });
  }

  void _showShelterModal(Shelter shelter) {
    setState(() {
      _localSelectedShelter = shelter;
    });
    _modalAnimationController.forward();
    
    // 선택된 쉼터로 지도 중심 이동
    _moveToShelter(shelter);
  }

  // 리뷰 모달 표시 함수 - 실제 API 데이터 사용
  void _showReviewModal() {
    // 리뷰 데이터 로드
    context.read<ReviewProvider>().fetchReviews(_localSelectedShelter!.id);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 모달 헤더
                Row(
                  children: [
                    Icon(
                      Icons.rate_review,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${_localSelectedShelter!.name} 리뷰',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey[600],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 리뷰 목록 - 실제 API 데이터 사용
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      if (reviewProvider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      if (reviewProvider.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 8),
                              const Text('리뷰를 불러올 수 없습니다'),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () {
                                  reviewProvider.fetchReviews(_localSelectedShelter!.id);
                                },
                                child: const Text('다시 시도'),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      if (reviewProvider.reviews.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.rate_review_outlined, size: 48, color: Colors.grey),
                              const SizedBox(height: 8),
                              const Text('아직 리뷰가 없습니다'),
                              const SizedBox(height: 4),
                              Text('첫 번째 리뷰를 작성해보세요!', 
                                   style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: reviewProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviewProvider.reviews[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Text(
                                  review.userNickname.isNotEmpty 
                                      ? review.userNickname[0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                review.userNickname.isNotEmpty 
                                    ? review.userNickname 
                                    : '익명 사용자',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(review.text),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      // 별점 표시
                                      ...List.generate(5, (starIndex) {
                                        return Icon(
                                          starIndex < review.rating 
                                              ? Icons.star 
                                              : Icons.star_border,
                                          color: Colors.amber,
                                          size: 16,
                                        );
                                      }),
                                      const SizedBox(width: 8),
                                      Text(
                                        review.createdAt,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // 사진이 있으면 표시
                                  if (review.photoUrls.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 60,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: review.photoUrls.length,
                                        itemBuilder: (context, photoIndex) {
                                          return Container(
                                            margin: const EdgeInsets.only(right: 8),
                                            width: 60,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(8),
                                              image: DecorationImage(
                                                image: NetworkImage(review.photoUrls[photoIndex]),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // 리뷰 작성 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showReviewWriteDialog();
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      '리뷰 작성하기',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 리뷰 작성 다이얼로그
  void _showReviewWriteDialog() {
    final TextEditingController textController = TextEditingController();
    int selectedRating = 5;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('리뷰 작성'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('이 쉼터에 대한 리뷰를 작성해주세요.'),
              const SizedBox(height: 16),
              
              // 별점 선택
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('별점: '),
                  ...List.generate(5, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = index + 1;
                        });
                      },
                      child: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 24,
                      ),
                    );
                  }),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 리뷰 텍스트
              TextField(
                controller: textController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '리뷰 내용',
                  hintText: '이 쉼터에 대한 솔직한 리뷰를 작성해주세요.',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  Navigator.of(context).pop();
                  _submitReview(text, selectedRating);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('리뷰 내용을 입력해주세요.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              child: const Text('작성'),
            ),
          ],
        ),
      ),
    );
  }

  // 리뷰 제출
  Future<void> _submitReview(String text, int rating) async {
    try {
      final reviewData = {
        'text': text,
        'rating': rating,
        'photoUrls': [], // 사진 기능은 나중에 추가
      };
      
      // TODO: 실제 API 호출
      // await ReviewService.createReview(_localSelectedShelter!.id, reviewData);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_localSelectedShelter!.name}에 리뷰를 작성했습니다!'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );
      
      // 리뷰 목록 새로고침
      context.read<ReviewProvider>().fetchReviews(_localSelectedShelter!.id);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('리뷰 작성에 실패했습니다: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // 체크인 방법 선택 다이얼로그
  void _showCheckinOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('체크인 방법 선택'),
        content: Text('${_localSelectedShelter!.name}에 체크인하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCameraCheckin();
            },
            child: const Text('카메라로 체크인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showCodeCheckin();
            },
            child: const Text('코드로 체크인'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  // 카메라 체크인 (기능 미구현)
  void _showCameraCheckin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_localSelectedShelter!.name} 카메라 체크인 기능은 준비 중입니다.'),
        backgroundColor: Colors.blue[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 코드 체크인 (기능 미구현)
  void _showCodeCheckin() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_localSelectedShelter!.name} 코드 체크인 기능은 준비 중입니다.'),
        backgroundColor: Colors.green[600],
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _modalAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShelterProvider>(
      builder: (context, shelterProvider, child) {
        // 로딩 중이거나 에러가 있거나 데이터가 없으면 빈 지도 표시
        if (shelterProvider.isLoading || 
            shelterProvider.hasError || 
            shelterProvider.shelters.isEmpty) {
    return Container(
            color: Colors.grey[100],
            child: Center(
              child: Text(
                shelterProvider.isLoading ? '지도를 불러오는 중...' :
                shelterProvider.hasError ? '지도를 불러올 수 없습니다' :
                '표시할 쉘터가 없습니다',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }
        
        // 실제 쉘터 데이터로 지도 표시
        return Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: const LatLng(37.5665, 126.9780), // 서울 중심
                      zoom: 11.0, // 초기 줌 레벨
                      minZoom: 5.0, // 최소 줌
                      maxZoom: 18.0, // 최대 줌
                      onMapReady: () {
                  print('Map is ready!');
                      },
                    ),
                    children: [
                      // OpenStreetMap 타일 레이어
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.not_hotspot',
                        maxZoom: 19,
                      ),
                      
                      // 쉼터 마커 레이어
                      MarkerLayer(
                  markers: shelterProvider.shelters.map((shelter) {
                    return Marker(
                      point: LatLng(shelter.latitude, shelter.longitude),
                      child: GestureDetector(
                        onTap: () => _showShelterModal(shelter),
                        child: Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    );
                  }).toList(),
                      ),
                      
                      // 현재 위치 마커 (있는 경우)
                      if (_currentPosition != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                              width: 30,
                              height: 30,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(
                                    BorderSide(color: Colors.white, width: 3),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.my_location,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                    ),
                  
                  // 쉼터 상세 정보 모달 (지도 위에 겹쳐서 표시)
                  if (_localSelectedShelter != null)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: SlideTransition(
                        position: _modalSlideAnimation,
                        child: FadeTransition(
                          opacity: _modalFadeAnimation,
                          child: Container(
                            margin: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 모달 헤더
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.blue[700],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          _localSelectedShelter!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _closeModal,
                                        icon: const Icon(Icons.close),
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 모달 내용
                                Padding(
                                  padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 왼쪽: 상세 정보
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('📍 주소', _localSelectedShelter!.address),
                                      _buildInfoRow('🏃 거리', '${_localSelectedShelter!.distance.toStringAsFixed(1)}km'),
                                      _buildInfoRow('🚦 상태', _localSelectedShelter!.status),
                                      _buildInfoRow('👥 혼잡도', _localSelectedShelter!.predictedCongestion),
                                    ],
                                  ),
                                ),
                                
                                // 오른쪽: 액션 버튼들
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      // 좋아요 토글 버튼
                                      Consumer<ShelterProvider>(
                                        builder: (context, shelterProvider, child) {
                                          final isLiked = shelterProvider.isLiked(_localSelectedShelter!.id);
                                          
                                          return SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                shelterProvider.toggleLike(_localSelectedShelter!.id);
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      isLiked 
                                                        ? '${_localSelectedShelter!.name} 좋아요를 해제했습니다.'
                                                        : '${_localSelectedShelter!.name}에 좋아요를 눌렀습니다!'
                                                    ),
                                                    duration: const Duration(seconds: 1),
                                                    backgroundColor: isLiked ? Colors.grey[600] : Colors.red[400],
                                                  ),
                                                );
                                              },
                                              icon: Icon(
                                                isLiked ? Icons.favorite : Icons.favorite_border,
                                                color: isLiked ? Colors.white : Colors.red[400],
                                                size: 18,
                                              ),
                                              label: Text(
                                                isLiked ? '좋아요 해제' : '좋아요',
                                                style: TextStyle(
                                                  color: isLiked ? Colors.white : Colors.red[400],
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: isLiked ? Colors.red[400] : Colors.white,
                                                foregroundColor: isLiked ? Colors.white : Colors.red[400],
                                                side: isLiked ? null : BorderSide(color: Colors.red[300]!, width: 1),
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                elevation: isLiked ? 2 : 0,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 리뷰 보러가기 버튼
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: () {
                                            _showReviewModal();
                                          },
                                          icon: Icon(
                                            Icons.rate_review,
                                            color: Colors.blue[600],
                                            size: 16,
                                          ),
                                          label: Text(
                                            '리뷰',
                                        style: TextStyle(
                                              color: Colors.blue[600],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.blue[600],
                                            side: BorderSide(color: Colors.blue[300]!),
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 8),
                                      
                                      // 체크인 버튼
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            _showCheckinOptions();
                                          },
                                          icon: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          label: const Text(
                                            '체크인',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green[600],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            elevation: 2,
                                          ),
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
                    ),
                  ),
                ),
              ),
            
            
            // 지도 컨트롤 버튼들
            Positioned(
              top: 16,
              right: 16,
              child: Column(
                children: [
                  // 현재 위치 버튼
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _isLoadingLocation ? null : _moveToCurrentLocation,
                      icon: _isLoadingLocation 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location),
                      color: Colors.blue[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 줌 인 버튼
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
          ),
        ],
      ),
                    child: IconButton(
                      onPressed: _zoomIn,
                      icon: const Icon(Icons.add),
                      color: Colors.blue[600],
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // 줌 아웃 버튼
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: _zoomOut,
                      icon: const Icon(Icons.remove),
                      color: Colors.blue[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
      );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}