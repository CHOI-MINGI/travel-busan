import 'package:flutter/material.dart';

class ProfileEditPage extends StatefulWidget {
  final String initialName;
  final String initialSubtitle;
  final String initialId;

  const ProfileEditPage({
    super.key,
    required this.initialName,
    required this.initialSubtitle,
    required this.initialId,
  });

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _idController;
  late final TextEditingController _emailController;

  bool pushNotification = true;
  bool marketingNotification = false;
  bool locationBasedRecommend = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _subtitleController = TextEditingController(text: widget.initialSubtitle);
    _idController = TextEditingController(text: widget.initialId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subtitleController.dispose();
    _idController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    Navigator.pop(
      context,
      {
        'name': _nameController.text.trim(),
        'subtitle': _subtitleController.text.trim(),
        'id': _idController.text.trim(),
        'email': _emailController.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필 수정',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w800,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF5B7CFF), Color(0xFF9333EA)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _nameController.text.isNotEmpty
                                ? _nameController.text[0]
                                : 'J',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -6,
                        bottom: -4,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '프로필 사진은 다음 단계에서 서버 업로드와 연결합니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _inputCard(
              title: '이름',
              child: TextField(
                controller: _nameController,
                onChanged: (_) => setState(() {}),
                decoration: _inputDecoration('이름을 입력하세요'),
              ),
            ),
            const SizedBox(height: 14),
            _inputCard(
              title: '한 줄 소개',
              child: TextField(
                controller: _subtitleController,
                decoration: _inputDecoration('예: 여행을 사랑하는 탐험가'),
              ),
            ),
            const SizedBox(height: 14),
            _inputCard(
              title: '아이디',
              child: TextField(
                controller: _idController,
                decoration: _inputDecoration('예: @traveler'),
              ),
            ),
            const SizedBox(height: 14),
            _inputCard(
              title: '이메일',
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration('example@email.com'),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '개인 설정',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    value: pushNotification,
                    onChanged: (value) {
                      setState(() {
                        pushNotification = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text('푸시 알림 받기'),
                  ),
                  SwitchListTile(
                    value: marketingNotification,
                    onChanged: (value) {
                      setState(() {
                        marketingNotification = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text('이벤트/혜택 알림 받기'),
                  ),
                  SwitchListTile(
                    value: locationBasedRecommend,
                    onChanged: (value) {
                      setState(() {
                        locationBasedRecommend = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    title: const Text('위치 기반 추천 사용'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '저장하기',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
    );
  }
}