import 'package:flutter/material.dart';
import '../screens/notifications_screen.dart';
import '../screens/likes_screen.dart';
import '../screens/more_screen.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
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
          // 알림/공지사항
          _buildNavItem(
            context: context,
            icon: Icons.home,
            title: '알림/공지사항',
            subtitle: '이용시간 제한 알림 and 각종 공지',
            isSelected: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // AI 추천
          _buildNavItem(
            context: context,
            icon: Icons.psychology,
            title: 'AI',
            subtitle: 'AI 추천',
            isSelected: false,
            onTap: () {
              // AI 추천 화면으로 이동 (현재는 홈 화면이 AI 추천)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI 추천 기능은 현재 홈 화면에서 확인할 수 있습니다.'),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 좋아요
          _buildNavItem(
            context: context,
            icon: Icons.favorite_border,
            title: '좋아요',
            subtitle: '',
            isSelected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LikesScreen(),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          
          // 더보기
          _buildNavItem(
            context: context,
            icon: Icons.more_horiz,
            title: '더보기',
            subtitle: '',
            isSelected: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MoreScreen(),
                ),
              );
            },
          ),
          
          const Spacer(),
          
          // 하단 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '앱 정보',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '버전 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 Not-Hotspot',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected 
            ? Border.all(color: Colors.blue[200]!)
            : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.blue : Colors.black87,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.blue[600] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
