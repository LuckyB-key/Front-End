import 'package:flutter/material.dart';
import 'package:not_hotspot/screens/home_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/likes_screen.dart';
import '../screens/more_screen.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE9ECEF), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 홈
          _buildNavItem(
            context: context,
            icon: Icons.home,
            title: '홈',
            subtitle: '현재 기온/습도 and AI 추천',
            isSelected: selectedIndex == 0,
            onTap: () {
              setState(() => selectedIndex = 0);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),

          const SizedBox(height: 16),

          // 알림/공지사항
          _buildNavItem(
            context: context,
            icon: Icons.notifications_active,
            title: '알림/공지사항',
            subtitle: '이용시간 제한 알림 and 각종 공지',
            isSelected: selectedIndex == 1,
            onTap: () {
              setState(() => selectedIndex = 1);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
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
            isSelected: selectedIndex == 2,
            onTap: () {
              setState(() => selectedIndex = 2);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LikesScreen()),
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
            isSelected: selectedIndex == 3,
            onTap: () {
              setState(() => selectedIndex = 3);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MoreScreen()),
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
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2024 Not-Hotspot',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildNavItem({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String subtitle,
  required bool isSelected,
  required VoidCallback onTap,
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      bool isHovered = false;
      bool isClicked = isSelected;

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => isHovered = true),
        onExit: (_) => setState(() => isHovered = false),
        child: GestureDetector(
          onTap: () {
            setState(() => isClicked = true);
            onTap();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isClicked || isHovered
                  ? Colors.blue[50]
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: (isClicked || isHovered)
                  ? Border.all(color: Colors.blue[200]!)
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isClicked || isHovered
                      ? Colors.blue
                      : Colors.grey[600],
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
                          color: isClicked || isHovered
                              ? Colors.blue
                              : Colors.black87,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: isClicked || isHovered
                                ? Colors.blue[600]
                                : Colors.grey[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
