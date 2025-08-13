import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../models/shelter.dart';
import 'shelter_detail_modal.dart';
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
      // 위치 권한 확인
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionDialog();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionDialog();
        return;
      }

      // 현재 위치 가져오기
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

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
          content: const Text('현재 위치로 이동했습니다'),
          backgroundColor: Colors.green[600],
          duration: const Duration(seconds: 2),
        ),
      );

    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });
      
      // 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치를 가져올 수 없습니다: $e'),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

  @override
  void dispose() {
    _modalAnimationController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('osm-map-section'),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지도',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Flutter Map (OpenStreetMap 기반)
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: const LatLng(37.5665, 126.9780), // 서울 중심
                      zoom: 11.0, // 초기 줌 레벨
                      minZoom: 5.0, // 최소 줌
                      maxZoom: 18.0, // 최대 줌
                      onMapReady: () {
                        print('️ Map is ready!');
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
                        markers: _buildShelterMarkers(),
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
                  
                  // 지도 컨트롤 버튼들 (우측 상단)
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
                            color: Colors.blue[700],
                            tooltip: '현재 위치로 이동',
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
                            color: Colors.grey[700],
                            tooltip: '확대',
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
                            color: Colors.grey[700],
                            tooltip: '축소',
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // 로딩 인디케이터
                  if (!_isMapLoaded)
                    Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              '지도를 불러오는 중...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '잠시만 기다려주세요',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildInfoRow('📍 주소', _localSelectedShelter!.address),
                                      _buildInfoRow('🕒 운영일', _localSelectedShelter!.openingDays),
                                      _buildInfoRow('👥 수용인원', '${_localSelectedShelter!.maxCapacity}명'),
                                      _buildInfoRow('🚶 혼잡도', _localSelectedShelter!.congestion),
                                      _buildInfoRow('⭐ 평점', '${_localSelectedShelter!.rating}/5.0'),
                                      _buildInfoRow('❤️ 좋아요', '${_localSelectedShelter!.likes}개'),
                                      
                                      const SizedBox(height: 16),
                                      
                                      // 시설 정보
                                      Text(
                                        '🏗️ 시설',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey[800],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: _localSelectedShelter!.facilities.map((facility) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[100],
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              facility,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.blue[800],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          );
                                        }).toList(),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 쉼터 마커 생성
  List<Marker> _buildShelterMarkers() {
    final shelters = context.read<ShelterProvider>().shelters;
    final List<Marker> markers = [];
    
    for (final shelter in shelters) {
      markers.add(
        Marker(
          point: LatLng(shelter.latitude, shelter.longitude), // 실제 좌표에 고정
          width: 40, // 마커 크기 40
          height: 40,
          child: GestureDetector(
            onTap: () => _showShelterModal(shelter),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red, // 빨간색 마커
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      );
    }
    
    return markers;
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