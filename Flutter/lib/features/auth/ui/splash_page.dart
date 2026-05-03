import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../main/main_page.dart';
import '../login_page.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // 앱이 켜지자마자 토큰 확인 시작
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      String? token = await storage.read(key: 'access_token');

      if (!mounted) return;

      if (token != null && token.isNotEmpty) {
        // AuthProvider에 저장된 유저 정보 불러오기
        await context.read<AuthProvider>().loadAuthInfo();
        _navigateTo(const MainPage());
      } else {
        _navigateTo(const LoginPage());
      }
    } catch (e) {
      print('🚨 스토리지 에러 발생: $e');
      if (!mounted) return;
      _navigateTo(const LoginPage());
    }
  }

// 중복 코드를 줄이기 위한 헬퍼 메서드
  void _navigateTo(Widget page) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0055FF), // 로그인 페이지와 통일감 있는 색상
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'AI 여행 플래너',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(color: Colors.white), // 로딩 애니메이션
          ],
        ),
      ),
    );
  }
}