import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class QRCheckinScreen extends StatefulWidget {
  final String shelterName;
  final String shelterId;

  const QRCheckinScreen({
    super.key,
    required this.shelterName,
    required this.shelterId,
  });

  @override
  State<QRCheckinScreen> createState() => _QRCheckinScreenState();
}

class _QRCheckinScreenState extends State<QRCheckinScreen> {
  bool isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shelterName} 체크인'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // QR 스캔 안내 아이콘
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[300]!, width: 2),
              ),
              child: Icon(
                Icons.qr_code_scanner,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 안내 텍스트
            Text(
              'QR 코드를 스캔해주세요',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              '쉼터에 표시된 QR 코드를\n카메라로 촬영하거나 갤러리에서 선택해주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 카메라로 촬영 버튼
            SizedBox(
              width: 280,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isProcessing ? null : _takePhotoWithCamera,
                icon: const Icon(Icons.camera_alt),
                label: const Text('카메라로 촬영'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 갤러리에서 선택 버튼
            SizedBox(
              width: 280,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : _pickImageFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('갤러리에서 선택'),
                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.green[600],
                side: BorderSide(color: Colors.green[600]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 테스트용 체크인 버튼 (개발 중)
            TextButton(
              onPressed: isProcessing ? null : _testCheckin,
              child: Text(
                '테스트 체크인 (개발용)',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 카메라로 촬영
  Future<void> _takePhotoWithCamera() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (photo != null) {
        print('📷 카메라로 촬영됨: ${photo.path}');
        _processQRCode(photo.path);
      } else {
        setState(() {
          isProcessing = false;
        });
      }
    } catch (e) {
      print('❌ 카메라 촬영 오류: $e');
      _showError('카메라를 사용할 수 없습니다.');
      setState(() {
        isProcessing = false;
      });
    }
  }

  // 갤러리에서 선택
  Future<void> _pickImageFromGallery() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      
      if (image != null) {
        print(' 갤러리에서 선택됨: ${image.path}');
        _processQRCode(image.path);
      } else {
        setState(() {
          isProcessing = false;
        });
      }
    } catch (e) {
      print('❌ 갤러리 선택 오류: $e');
      _showError('갤러리에서 이미지를 선택할 수 없습니다.');
      setState(() {
        isProcessing = false;
      });
    }
  }

  // QR 코드 처리 (임시)
  void _processQRCode(String imagePath) {
    // TODO: 실제 QR 코드 읽기 로직 구현
    print(' QR 코드 처리 중: $imagePath');
    
    // 임시로 성공 처리
    Future.delayed(const Duration(seconds: 2), () {
      _showCheckinSuccess();
    });
  }

  // 테스트 체크인
  void _testCheckin() {
    setState(() {
      isProcessing = true;
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      _showCheckinSuccess();
    });
  }

  // 체크인 성공
  void _showCheckinSuccess() {
    setState(() {
      isProcessing = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('체크인 성공!'),
        content: Text('${widget.shelterName}에 성공적으로 체크인되었습니다.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // QR 화면 닫기
              
              // 성공 메시지 표시
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.shelterName} 체크인 완료!'),
                  backgroundColor: Colors.green[600],
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 오류 표시
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
