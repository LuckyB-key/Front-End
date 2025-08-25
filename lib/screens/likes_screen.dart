import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../models/shelter.dart';
import 'home_screen.dart';

class LikesScreen extends StatelessWidget {
  const LikesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('좋아요'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 제목
            const Text(
              '좋아요',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '내가 좋아한 쉼터들을 확인하세요',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 좋아요 리스트
            Expanded(
              child: Consumer<ShelterProvider>(
                builder: (context, provider, child) {
                  // 사용자가 좋아요를 누른 쉼터들만 필터링
                  final likedShelters = provider.shelters
                      .where((shelter) => provider.isLiked(shelter.id))
                      .toList();
                  
                  if (likedShelters.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            '아직 좋아한 쉼터가 없습니다',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '쉼터에 좋아요를 눌러보세요!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: likedShelters.length,
                    itemBuilder: (context, index) {
                      return _buildLikedShelterCard(context, likedShelters[index], provider);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikedShelterCard(BuildContext context, Shelter shelter, ShelterProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Row(
        children: [
          // 이미지
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.image,
              color: Colors.grey,
              size: 40,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shelter.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  shelter.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Colors.amber[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${shelter.rating}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Icon(
                      Icons.favorite,
                      size: 16,
                      color: Colors.red[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${shelter.likes}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getCongestionColor(shelter.congestion),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        shelter.congestion,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 액션 버튼
          Column(
            children: [
              IconButton(
                onPressed: () {
                  // 좋아요 취소
                  provider.toggleLike(shelter.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${shelter.name} 좋아요를 취소했습니다.'),
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.red[600],
                    ),
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // 상세보기 - 지도에서 표시
                  Navigator.pop(context); // 좋아요 화면 닫기
                  // TODO: 지도에서 쉼터 표시 기능 추가
                },
                child: const Text('상세보기'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCongestionColor(String congestion) {
    switch (congestion) {
      case '여유':
        return Colors.green;
      case '보통':
        return Colors.orange;
      case '혼잡':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
