import 'package:flutter/material.dart';

class MoreNotificationPage extends StatefulWidget {
  const MoreNotificationPage({super.key});

  @override
  State<MoreNotificationPage> createState() => _MoreNotificationPageState();
}

class _MoreNotificationPageState extends State<MoreNotificationPage> {
  bool _announcementEnabled = true;
  bool _generalEnabled = true;
  bool _eventEnabled = true;
  bool _fiveMinuteReminderEnabled = true;

  Widget _buildSwitchListTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: SwitchListTile(
        title: Text(title),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green[600], // 활성화된 스위치 색상을 초록색으로 변경
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('알림 설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSwitchListTile(
              title: '공지사항 알림',
              value: _announcementEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _announcementEnabled = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSwitchListTile(
              title: '일반 알림',
              value: _generalEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _generalEnabled = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSwitchListTile(
              title: '이벤트 알림',
              value: _eventEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _eventEnabled = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            _buildSwitchListTile(
              title: '쉼터 이용시간 5분전 알림',
              value: _fiveMinuteReminderEnabled,
              onChanged: (bool newValue) {
                setState(() {
                  _fiveMinuteReminderEnabled = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}