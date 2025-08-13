import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../models/shelter.dart';

class ShelterList extends StatelessWidget {
  final Function(Shelter)? onShelterSelected;
  
  const ShelterList({
    super.key,
    this.onShelterSelected,
  });

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
          // 제목
          const Text(
            'AI 추천 쉼터',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 쉘터 리스트
          Expanded(
            child: Consumer<ShelterProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (provider.filteredShelters.isEmpty) {
                  return const Center(
                    child: Text(
                      '검색 결과가 없습니다.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: provider.filteredShelters.length,
                  itemBuilder: (context, index) {
                    return _buildShelterCard(context, provider.filteredShelters[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShelterCard(BuildContext context, Shelter shelter) {
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
          
          // 쉘터 정보 리스트
          Column(
            children: [
              _buildInfoRow('주소', shelter.address),
              _buildInfoRow('개방 요일', shelter.openingDays),
              _buildInfoRow('최대 수용 인원', '${shelter.maxCapacity}명'),
              _buildInfoRow('혼잡도', shelter.congestion),
              _buildInfoRow('시설', shelter.facilities.join(', ')),
              _buildInfoRow('리뷰', '${shelter.rating}점'),
              _buildInfoRow('좋아요', '${shelter.likes}개'),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // 상세 정보 보기 - 지도에 모달 표시
                    if (onShelterSelected != null) {
                      onShelterSelected!(shelter);
                    }
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
