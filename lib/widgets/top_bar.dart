import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140, // 높이를 120에서 140으로 더 증가
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          // 로고
          Container(
            width: 120,
            height: 40,
            child: Image.asset(
              'assets/images/mainlogo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                print('❌ 로고 이미지 로드 실패: $error');
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'LOGO',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(width: 24),
          
          // 검색바
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Icon(Icons.search, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        context.read<ShelterProvider>().setSearchQuery(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  Icon(Icons.mic, color: Colors.grey[600]),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ),
          
          const SizedBox(width: 24),
          
          // 새로고침 버튼
          IconButton(
            onPressed: () {
              context.read<ShelterProvider>().fetchShelters();
            },
            icon: Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
    );
  }


}
