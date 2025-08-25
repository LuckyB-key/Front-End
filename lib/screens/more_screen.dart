import 'package:flutter/material.dart';
import 'more_profile_page.dart';
import 'more_NotificationPage.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({super.key});

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  Widget? _selectedContent;

  @override
  void initState() {
    super.initState();
    _selectedContent = const MoreProfilePage();
  }

  Widget _getContentForTitle(String title) {
    if (title == '프로필 설정') {
      return const MoreProfilePage();
    } else if (title == '알림 설정') {
      return const MoreNotificationPage();
    }
    return const SizedBox();
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isDestructive = false,
  }) {
    // 선택된 항목에 따라 다른 색상을 적용할 수 있습니다.
    // 여기서는 간단히 title을 기준으로 구분합니다.
    final bool isSelected = (_selectedContent is MoreProfilePage && title == '프로필 설정') ||
                            (_selectedContent is MoreNotificationPage && title == '알림 설정');

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.withOpacity(0.1) : null,
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
          color: isDestructive ? Colors.red : (isSelected ? Colors.blue : Colors.grey[600]),
          size: 24,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isDestructive ? Colors.red : (isSelected ? Colors.blue : Colors.black87),
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
        onTap: () {
          final isTablet = MediaQuery.of(context).size.width > 600;
          if (isTablet) {
            setState(() {
              _selectedContent = _getContentForTitle(title);
            });
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => _getContentForTitle(title)),
            );
          }
        },
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
        Padding(
          padding: const EdgeInsets.only(left: 16.0, top: 16.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final menuList = SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '더보기',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 32),
            _buildMenuSection(
              title: '계정',
              items: [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: '프로필 설정',
                  subtitle: '개인정보 및 계정 설정',
                ),
                _buildMenuItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  subtitle: '푸시 알림 및 이메일 설정',
                ),
                _buildMenuItem(
                  icon: Icons.security,
                  title: '개인정보 보호',
                  subtitle: '개인정보 처리방침',
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
                ),
                _buildMenuItem(
                  icon: Icons.help_outline,
                  title: '도움말',
                  subtitle: '자주 묻는 질문',
                ),
                _buildMenuItem(
                  icon: Icons.feedback_outlined,
                  title: '피드백',
                  subtitle: '의견 및 버그 신고',
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
                ),
                _buildMenuItem(
                  icon: Icons.star_outline,
                  title: '앱 평가',
                  subtitle: '앱스토어에서 평가하기',
                ),
                _buildMenuItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  subtitle: '계정에서 로그아웃',
                  isDestructive: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isTablet) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        body: SafeArea(
          child: Row(
            children: [
              // 50:50 비율로 너비 조정
              Expanded(
                flex: 1,
                child: menuList,
              ),
              const VerticalDivider(width: 1, color: Colors.grey),
              Expanded(
                flex: 1,
                child: _selectedContent ?? const SizedBox(),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('더보기'),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: menuList,
      );
    }
  }
}