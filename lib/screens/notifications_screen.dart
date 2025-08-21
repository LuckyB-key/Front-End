import 'package:flutter/material.dart';
import 'home_screen.dart'; // '홈' 버튼 기능하기 위해서 import

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // 전체 / 공지사항 / 알림 / 이벤트
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text('공지사항'),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            // 홈 버튼 (바로 홈으로 이동 가능)
            Padding(
              padding: const EdgeInsets.only(
                right: 50,
              ), // '홈' 아이콘 위치 : 오른쪽 여백 줄임
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.black),
                iconSize: 35,
                tooltip: "홈으로",
                onPressed: () {
                  // 눌렀을 때 '홈'으로 이동 (아이콘 색 변화X)
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Container(
              alignment: Alignment.centerLeft,
              child: const TabBar(
                // '전체 / 공지사항 / 알림 / 이벤트' 탭바
                isScrollable: false,
                indicatorColor: Colors.blue,
                indicatorWeight: 3,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                tabs: [
                  Tab(text: '전체'),
                  Tab(text: '공지사항'),
                  Tab(text: '알림'),
                  Tab(text: '이벤트'),
                ],
              ),
            ),
          ),
        ),
        body: const Padding(
          padding: EdgeInsets.all(16),
          child: TabBarView(
            children: [
              NotificationList(category: "전체"),
              NotificationList(category: "공지사항"),
              NotificationList(category: "알림"),
              NotificationList(category: "이벤트"),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationList extends StatelessWidget {
  final String category;
  const NotificationList({super.key, required this.category});

  // 글자 수 제한 함수 ('자세히 보기' 클릭하지 않았을 때 보여지는 글자 수 제한함.)
  String _truncateText(String text, {int maxLength = 50}) {
    if (text.length <= maxLength) return text;
    return "${text.substring(0, maxLength)}...";
  }

  @override
  Widget build(BuildContext context) {
    // 예시 데이터
    final allNotifications = [
      {
        "title": "2025년 XX쉼터 운영 안내 (5월 20일 ~ 9월 30일)",
        "content": "폭염대책기간 동안 지역 내 무더위 쉼터 141개소가 운영됩니다.",
        "time": "2025-05-15",
        "isImportant": true,
        "type": "공지사항",
      },
      {
        "title": "대구 달서구 내 무더위 쉼터 운영시간 연장 안내",
        "content": "폭염특보 발령에 따라 무더위 쉼터 운영시간을 오전 9시부터 오후 7시까지 연장 운영합니다.",
        "time": "2025-08-12",
        "isImportant": false,
        "type": "공지사항",
      },
      {
        "title": "무더위 쉼터 신규 지정 장소 안내",
        "content": "지역 주민들의 접근성 향상을 위해 신당동 신당종합사회복지관이 쉼터로 지정되었습니다.",
        "time": "2025-07-04",
        "isImportant": false,
        "type": "공지사항",
      },
      {
        "title": "무더위 쉼터 환경 개선 공사 안내",
        "content": "OO복지관 무더위 쉼터 냉방시설 교체 공사로 7월 5일~7일까지 임시 휴관합니다.",
        "time": "2025-06-25",
        "isImportant": false,
        "type": "알림",
      },
      {
        "title": "무더위 쉼터 민원 신고 안내",
        "content": "무더위 쉼터의 운영시간 미준수, 안내간판 미정비 등 불편사항은 신고해주시면 신속히 개선하겠습니다.",
        "time": "2025-07-16",
        "isImportant": true,
        "type": "공지사항",
      },
      {
        "title": "폭염 대비 무더위 쉼터 이용 안내",
        "content": "폭염주의보 발효에 따라 충분한 수분 섭취와 무더위 쉼터 이용을 권장드립니다.",
        "time": "2025-07-01",
        "isImportant": true,
        "type": "알림",
      },
      {
        'title': '무더위 쉼터 이용 시 코로나19 예방수칙 안내',
        "content": '무더위 쉼터 이용 시 마스크 착용, 손 소독, 거리두기 등 코로나19 예방수칙을 준수해 주시기 바랍니다.',
        "time": "2025-06-24",
        "isImportant": false,
        "type": "알림",
      },
      {
        'title': '쾌적한 쇼핑몰 혼잡도 알림',
        "content": '현재 쇼핑몰 내부가 혼잡합니다. 이용에 참고하시기 바랍니다.',
        "time": "2024-06-26",
        "isImportant": true,
        "type": "알림",
      },
      {
        "title": '조용한 공원 쉼터 개방 안내',
        "content": '새로운 공원 쉼터가 개방되었습니다. 위치: 서울시 송파구 올림픽로 321',
        "time": '2024-06-25',
        "isImportant": false,
        "type": "공지사항",
      },
      {
        "title": '[신규 오픈] \'우리 동네 시원한 쉼터\' 오픈 기념! 얼리버드 쿠폰 팩 증정 이벤트',
        "content":
            '우리 동네 소상공인 무더위 쉼터 서비스가 정식 오픈했습니다! 에어컨 빵빵한 카페, 시원한 아이스크림 가게, 편안한 서점까지! 이제 앱에서 가까운 소상공인 쉼터를 찾고 시원하게 쉬어가세요. ',
        "time": '2024-05-04',
        "isImportant": false,
        "type": "이벤트",
      },
      {
        "title": '[스탬프 챌린지] \'쉬어가며 혜택 누리기\' 무더위 쉼터 스탬프 투어 이벤트',
        "content":
            '올여름, 무더위를 피해 우리 동네 소상공인 쉼터들을 방문해 보세요. 앱을 통해 쉼터 방문 인증 스탬프를 모으시면, 풍성한 추가 혜택이 쏟아집니다.',
        "time": '2024-07-17',
        "isImportant": false,
        "type": "이벤트",
      },
      {
        "title": ' [기간 한정] \'소상공인 응원 데이\' 스페셜 할인 쿠폰 이벤트',
        "content":
            '소상공인과 함께 시원한 여름을 나는 \'소상공인 응원 데이\'입니다. 매주 월요일 하루 동안, 참여 소상공인 쉼터에서 평소보다 더 높은 할인율이 적용된 \'특별 할인 쿠폰\'을 제공합니다.',
        "time": '2024-08-09',
        "isImportant": false,
        "type": "이벤트",
      },
    ];

    final filtered = category == "전체"
        ? allNotifications
        : allNotifications.where((n) => n["type"] == category).toList();

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final n = filtered[index];
        return _buildNotificationCard(
          context: context,
          title: n["title"] as String,
          content: n["content"] as String,
          time: n["time"] as String,
          isImportant: n["isImportant"] as bool,
        );
      },
    );
  }

  Widget _buildNotificationCard({
    required BuildContext context,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
            _truncateText(content, maxLength: 50),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailPage(
                    title: title,
                    content: content,
                    time: time,
                  ),
                ),
              );
            },
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
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
          ),
        ],
      ),
    );
  }
}

/// 상세 페이지 위젯
class NotificationDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String time;

  const NotificationDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("공지사항"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          // '홈'으로 이동
          Padding(
            padding: const EdgeInsets.only(right: 50),
            child: IconButton(
              icon: const Icon(Icons.home, color: Colors.black),
              iconSize: 35,
              tooltip: "홈으로",
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        // '자세히 보기' 클릭 시, 보여지는 내용
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const Divider(height: 24),
            Text(content, style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}
