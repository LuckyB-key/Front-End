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
        return FlutterMap(
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
              markers: shelterProvider.shelters.map((shelter) {
                return Marker(
                  point: LatLng(shelter.latitude, shelter.longitude),
                  child: GestureDetector( // builder 대신 child 사용
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
        );
      },
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