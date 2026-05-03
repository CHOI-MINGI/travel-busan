import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';

class RegistrationResultPage extends StatefulWidget {
  final bool isSuccess;
  final String message;

  const RegistrationResultPage({
    super.key,
    required this.isSuccess,
    this.message = '',
  });

  @override
  State<RegistrationResultPage> createState() => _RegistrationResultPageState();
}

class _RegistrationResultPageState extends State<RegistrationResultPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 애니메이션 아이콘
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: widget.isSuccess ? const Color(0xFFE8FDF5) : const Color(0xFFFDECEC),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.isSuccess ? Icons.check_circle : Icons.error_outline,
                        color: widget.isSuccess ? const Color(0xFF00C853) : const Color(0xFFEF4444),
                        size: 60,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // 결과 타이틀
                Text(
                  widget.isSuccess ? '가이드 등록 완료!' : '등록 실패',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Palette.foreground,
                  ),
                ),
                const SizedBox(height: 16),
                
                // 결과 메시지
                Text(
                  widget.isSuccess
                      ? '축하합니다! 이제 로컬 가이드로 활동할 수 있습니다.\n가이드 제안 탭에서 여행자들에게 서비스를 제안해보세요.'
                      : widget.message.isNotEmpty ? widget.message : '알 수 없는 오류가 발생했습니다.\n잠시 후 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Palette.mutedForeground,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                
                // 버튼
                SizedBox(
                  width: 200,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      // 모든 스택을 제거하고 메인 페이지(홈)로 이동
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '홈으로 돌아가기',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
