import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../widgets/top_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/shelter_list.dart';
import '../widgets/map_section.dart';
import '../models/shelter.dart';

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
                      // AI 추천 쉘터 리스트
                      Expanded(
                        flex: 1,
                        child: ShelterList(
                          onShelterSelected: _onShelterSelected, // 콜백 함수 전달
                        ),
                      ),

                      // 지도 섹션
                      Expanded(
                        flex: 2,
                        child: MapSection(
                          selectedShelter: selectedShelter, // 선택된 쉼터 전달
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
