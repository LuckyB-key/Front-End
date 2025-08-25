import 'package:flutter/material.dart';

class MoreProfilePage extends StatefulWidget {
  const MoreProfilePage({super.key});

  @override
  State<MoreProfilePage> createState() => _MoreProfilePageState();
}

class _MoreProfilePageState extends State<MoreProfilePage> {
  final TextEditingController _nicknameController = TextEditingController();
  final String _profileImageUrl = 'https://via.placeholder.com/150';

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    print('닉네임 저장: ${_nicknameController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('프로필 설정'),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: MediaQuery.of(context).size.width < 600,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(_profileImageUrl),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                                          child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                labelStyle: TextStyle(color: Colors.green[600]),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.green[600]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.green[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: Colors.green[600]!, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600], // 초록색 배경
                foregroundColor: Colors.white, // 흰색 텍스트
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('저장하기', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}