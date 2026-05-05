import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/login_page.dart';
import '../../auth/provider/auth_provider.dart';
import '../../guider/ui/guide_registration_page.dart';
import 'app_settings_page.dart';
import 'liked_trips_page.dart';
import 'my_reviews_page.dart';
import 'notification_settings_page.dart';
import 'privacy_settings_page.dart';
import 'profile_edit_page.dart';
import 'support_page.dart';
import 'visited_trips_page.dart';
import 'my_bid_status_page.dart';
import '../../chat/chat_room_list_page.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // 프로필 수정 후 로컬 상태를 잠시 유지하고 싶을 때 사용할 수 있는 함수
  // 하지만 정석은 AuthProvider를 통해 서버 데이터를 갱신하는 것입니다.
  void _handleProfileUpdate(Map<String, String> result) {
    // 여기에 AuthProvider의 업데이트 로직을 연결하면 됩니다.
    print("프로필 수정 데이터: $result");
  }

  @override
  Widget build(BuildContext context) {
    // 1. AuthProvider 구독: 데이터가 변경되면 마이페이지 전체가 자동으로 다시 그려집니다.
    final auth = context.watch<AuthProvider>();

    // 2. 하드코딩 대신 Provider 데이터 사용 (기본값 설정)
    final String name = auth.nickname ?? '사용자';
    final String userId = auth.userId ?? 'ID 정보 없음';
    final String subtitle = auth.isGuide ? "전문 로컬 가이드" : "부산 여행자";

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '마이페이지',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 28),

              // 3. 프로필 카드에 가공된 데이터 전달
              _buildProfileCard(context, name, subtitle, userId),

              const SizedBox(height: 22),
              _buildLocalGuideBanner(context),
              const SizedBox(height: 26),

              const Text(
                '여행',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.send_outlined,
                    title: '내 요청 현황',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyBidStatusPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.chat_bubble_outline,
                    title: '채팅',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatRoomListPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.favorite_border,
                    title: '찜한 여행지',
                    trailingBadge: '3',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LikedTripsPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.location_on_outlined,
                    title: '방문한 여행지',
                    trailingBadge: '12',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VisitedTripsPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.star_border,
                    title: '내 리뷰',
                    trailingBadge: '5',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyReviewsPage())),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              const Text(
                '설정',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 12),
              _buildSectionCard(
                children: [
                  _buildMenuRow(
                    icon: Icons.notifications_none,
                    title: '알림 설정',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationSettingsPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.shield_outlined,
                    title: '개인정보 보호',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacySettingsPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.settings_outlined,
                    title: '앱 설정',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AppSettingsPage())),
                  ),
                  _buildDivider(),
                  _buildMenuRow(
                    icon: Icons.help_outline,
                    title: '고객센터',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportPage())),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // 로그아웃 버튼
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- 위젯 빌더 함수들 ---

  Widget _buildProfileCard(BuildContext context, String name, String subtitle, String id) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FB),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 프로필 이미지 (아바타)
          _buildAvatar(name),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 15, color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(id, style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, String>>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileEditPage(
                          initialName: name,
                          initialSubtitle: subtitle,
                          initialId: id,
                        ),
                      ),
                    );
                    if (result != null) _handleProfileUpdate(result);
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('프로필 수정', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String name) {
    return Container(
      width: 78,
      height: 78,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [Color(0xFF5B7CFF), Color(0xFF9333EA)]),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0] : 'U',
          style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () async {
          await context.read<AuthProvider>().logout();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
          );
        },
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFFDECEC),
          foregroundColor: const Color(0xFFEF4444),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 20),
            SizedBox(width: 8),
            Text('로그아웃', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  // --- 기타 UI 구성 요소 (변경 없음) ---
  Widget _buildLocalGuideBanner(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // 가이드면 가이드 관리 UI 보여주기
    if (auth.isGuide) {
      return Column(
        children: [
          // 가이드 정보 수정 버튼
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideRegistrationPage())),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                color: const Color(0xFF09B45E),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('로컬 가이드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('가이드 정보 수정', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 가이드 모드 전환 버튼
          if (!auth.isGuideMode)
            GestureDetector(
              onTap: () => context.read<AuthProvider>().toggleGuideMode(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB24BF3), Color(0xFFFF6B9D)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.swap_horiz, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('가이드 모드로 전환', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('역경매에 참여하고 여행자들에게 투어를 제안하세요', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
          if (auth.isGuideMode)
            GestureDetector(
              onTap: () => context.read<AuthProvider>().toggleGuideMode(),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: const Color(0xFF4B5563),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_outline, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('사용자 모드로 전환', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                          SizedBox(height: 4),
                          Text('여행자 모드로 돌아가기', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white),
                  ],
                ),
              ),
            ),
        ],
      );
    }


    // 가이드 아니면 기존 등록 배너
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideRegistrationPage())),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), color: const Color(0xFF09B45E)),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [Icon(Icons.verified_user_outlined, color: Colors.white, size: 20), SizedBox(width: 8), Text('로컬 가이드', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))]),
            SizedBox(height: 18),
            Text('로컬 가이드로 등록하세요', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required List<Widget> children}) {
    return Container(decoration: BoxDecoration(color: const Color(0xFFF9FAFC), borderRadius: BorderRadius.circular(24)), child: Column(children: children));
  }

  Widget _buildMenuRow({required IconData icon, required String title, String? trailingBadge, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B7280)),
            const SizedBox(width: 14),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700))),
            if (trailingBadge != null) Text(trailingBadge),
            const Icon(Icons.chevron_right, color: Color(0xFFB8C0CC)),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() => const Padding(padding: EdgeInsets.symmetric(horizontal: 18), child: Divider(height: 1, color: Color(0xFFEEF1F5)));
}