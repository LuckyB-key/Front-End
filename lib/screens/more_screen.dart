import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('더보기'),
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
              '더보기',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 메뉴 리스트
            Expanded(
              child: ListView(
                children: [
                  _buildMenuSection(
                    title: '계정',
                    items: [
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: '프로필 설정',
                        subtitle: '개인정보 및 계정 설정',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications_outlined,
                        title: '알림 설정',
                        subtitle: '푸시 알림 및 이메일 설정',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.security,
                        title: '개인정보 보호',
                        subtitle: '개인정보 처리방침',
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMenuSection(
                    title: '앱',
                    items: [
                      _buildMenuItem(
                        icon: Icons.info_outline,
                        title: '앱 정보',
                        subtitle: '버전 1.0.0',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline,
                        title: '도움말',
                        subtitle: '자주 묻는 질문',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.feedback_outlined,
                        title: '피드백',
                        subtitle: '의견 및 버그 신고',
                        onTap: () {},
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildMenuSection(
                    title: '기타',
                    items: [
                      _buildMenuItem(
                        icon: Icons.share,
                        title: '앱 공유',
                        subtitle: '친구에게 앱 추천하기',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.star_outline,
                        title: '앱 평가',
                        subtitle: '앱스토어에서 평가하기',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.logout,
                        title: '로그아웃',
                        subtitle: '계정에서 로그아웃',
                        onTap: () {},
                        isDestructive: true,
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
  }

  Widget _buildMenuSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 0.5,
          ),
        ),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isDestructive ? Colors.red : Colors.grey[600],
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
