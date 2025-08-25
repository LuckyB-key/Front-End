import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../models/shelter.dart';
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
    
    _mapController = MapController();
    
    _modalAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _modalSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _modalFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _modalAnimationController,
      curve: Curves.easeOut,
    ));
    
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
      
      if (widget.selectedShelter != null) {
        _modalAnimationController.forward();
        _moveToShelter(widget.selectedShelter!);
      } else {
        _modalAnimationController.reverse();
      }
    }
  }

  void _moveToShelter(Shelter shelter) {
    final latLng = LatLng(shelter.latitude, shelter.longitude);
    _mapController.move(latLng, 15.0);
  }

  Future<void> _moveToCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
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

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      final latLng = LatLng(position.latitude, position.longitude);
      _mapController.move(latLng, 15.0);

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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('위치를 가져올 수 없습니다: $e'),
          backgroundColor: Colors.red[600],
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

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

  void _zoomIn() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom + 1);
  }

  void _zoomOut() {
    final currentZoom = _mapController.zoom;
    _mapController.move(_mapController.center, currentZoom - 1);
  }

  void _closeModal() {
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
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: const LatLng(37.5665, 126.9780),
                      zoom: 11.0,
                      minZoom: 5.0,
                      maxZoom: 18.0,
                      onMapReady: () {
                        print('️ Map is ready!');
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        subdomains: const ['a', 'b', 'c'],
                        userAgentPackageName: 'com.example.not_hotspot',
                        maxZoom: 19,
                      ),
                      
                      MarkerLayer(
                        markers: _buildShelterMarkers(),
                      ),
                      
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
                  
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
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
                  
                  // 쉼터 상세 정보 모달
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
                            // 세로 크기를 줄이기 위해 Container의 height 지정
                            height: MediaQuery.of(context).size.height * 0.25, // 화면 높이의 25%로 설정
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
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: Colors.blue[700],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      // 쉼터 이름
                                      Expanded(
                                        child: Text(
                                          _localSelectedShelter!.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // 시설 정보 (타원형 태그)
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: _localSelectedShelter!.facilities.map((facility) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(15),
                                              border: Border.all(color: Colors.blue[100]!),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 2,
                                                  offset: const Offset(0, 1),
                                                ),
                                              ],
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
                                      const SizedBox(width: 8),
                                      IconButton(
                                        onPressed: _closeModal,
                                        icon: const Icon(Icons.close),
                                        color: Colors.grey[600],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // 모달 내용 (Expanded로 남은 공간 활용)
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 첫 번째 줄: 주소, 운영일
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: _buildInfoRow('📍 주소', _localSelectedShelter!.address)),
                                            Expanded(child: _buildInfoRow('🕒 운영일', _localSelectedShelter!.openingDays)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // 두 번째 줄: 수용인원, 혼잡도
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: _buildInfoRow('👥 수용인원', '${_localSelectedShelter!.maxCapacity}명')),
                                            Expanded(child: _buildInfoRow('🚶 혼잡도', _localSelectedShelter!.congestion)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),

                                        // 세 번째 줄: 평점, 좋아요
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(child: _buildInfoRow('⭐ 평점', '${_localSelectedShelter!.rating}/5.0')),
                                            Expanded(child: _buildInfoRow('❤️ 좋아요', '${_localSelectedShelter!.likes}개')),
                                          ],
                                        ),
                                      ],
                                    ),
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

  List<Marker> _buildShelterMarkers() {
    final shelters = context.read<ShelterProvider>().shelters;
    final List<Marker> markers = [];
    
    for (final shelter in shelters) {
      markers.add(
        Marker(
          point: LatLng(shelter.latitude, shelter.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showShelterModal(shelter),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.red,
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