import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/shelter_provider.dart';
import '../models/shelter.dart';
import '../widgets/map_section.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen> {
  Shelter? selectedShelter;

  void _onShelterSelected(Shelter shelter) {
    setState(() {
      selectedShelter = shelter;
    });
  }

  void _onShelterDeselected() {
    setState(() {
      selectedShelter = null;
    });
  }

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
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: _LikedShelterList(
                selectedShelterId: selectedShelter?.id,
                onShelterSelected: _onShelterSelected,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: MapSection(
                selectedShelter: selectedShelter,
                onShelterDeselected: _onShelterDeselected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikedShelterList extends StatelessWidget {
  final String? selectedShelterId;
  final Function(Shelter) onShelterSelected;

  const _LikedShelterList({
    this.selectedShelterId,
    required this.onShelterSelected,
  });

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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        Expanded(
          child: Consumer<ShelterProvider>(
            builder: (context, provider, child) {
              final likedShelters = provider.shelters
                  .where((s) => s.likes > 0)
                  .toList()
                ..sort((a, b) => b.likes.compareTo(a.likes));

              if (likedShelters.isEmpty) {
                return const Center(child: Text('아직 좋아한 쉼터가 없습니다'));
              }

              return ListView.builder(
                itemCount: likedShelters.length,
                itemBuilder: (context, index) {
                  final shelter = likedShelters[index];
                  // 선택된 항목의 배경색 변경
                  final isSelected = shelter.id == selectedShelterId;
                  
                  return GestureDetector(
                    onTap: () {
                      onShelterSelected(shelter);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeIn,
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE3F2FD) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue[400]! : Colors.grey[200]!,
                          width: isSelected ? 2.0 : 1.0,
                        ),
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
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}