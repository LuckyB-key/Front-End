import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('알림/공지사항'),
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
              '알림/공지사항',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '이용시간 제한 알림 및 각종 공지',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // 알림 리스트
            Expanded(
              child: ListView(
                children: [
                  _buildNotificationCard(
                    title: '시원한 도서관 이용시간 변경 안내',
                    content: '7월 1일부터 이용시간이 09:00-20:00으로 변경됩니다.',
                    time: '2024-06-28',
                    isImportant: true,
                  ),
                  _buildNotificationCard(
                    title: '아늑한 카페 시설 점검 안내',
                    content: '6월 30일 오후 2시부터 4시까지 에어컨 점검이 예정되어 있습니다.',
                    time: '2024-06-27',
                    isImportant: false,
                  ),
                  _buildNotificationCard(
                    title: '쾌적한 쇼핑몰 혼잡도 알림',
                    content: '현재 쇼핑몰 내부가 혼잡합니다. 이용에 참고하시기 바랍니다.',
                    time: '2024-06-26',
                    isImportant: true,
                  ),
                  _buildNotificationCard(
                    title: '조용한 공원 쉼터 개방 안내',
                    content: '새로운 공원 쉼터가 개방되었습니다. 위치: 서울시 송파구 올림픽로 321',
                    time: '2024-06-25',
                    isImportant: false,
                  ),
                  _buildNotificationCard(
                    title: '전망 좋은 은행 휴무일 안내',
                    content: '매주 토요일, 일요일은 휴무입니다. 이용에 참고하시기 바랍니다.',
                    time: '2024-06-24',
                    isImportant: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String content,
    required String time,
    required bool isImportant,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isImportant ? Colors.red[200]! : Colors.grey[200]!,
          width: isImportant ? 2 : 1,
        ),
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
          Row(
            children: [
              if (isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '중요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                '자세히 보기',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
