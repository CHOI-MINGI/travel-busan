import 'package:flutter/material.dart';
import '../../config/palette.dart';
import '../ai/ai_planner_page.dart';
import '../auth/login_page.dart';
import '../guide/ui/guide_explore_page.dart';
import '../profile/ui/my_page.dart';
import '../planner_detail/ui/planner_detail_page.dart';
import '../guide/ui/bid_status_page.dart';
import '../guide/ui/portfolio_page.dart';
import '../guide/ui/guide_product_page.dart';
import 'package:provider/provider.dart';
import '../auth/provider/auth_provider.dart';
import '../planner_detail/provider/planner_detail_provider.dart';
import 'package:capstone/features/main/home_screen.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 2 && !context.read<AuthProvider>().isGuideMode) {
      context.read<PlannerProvider>().fetchItineraries();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isGuideMode = auth.isGuideMode;

    if (_selectedIndex >= (isGuideMode ? 6 : 5)) {
      _selectedIndex = 0;
    }

    final List<Widget> userPages = [
      const HomeScreen(),
      const AIPlannerPage(),
      const PlannerDetailPage(),
      const GuideExplorePage(),
      const MyPage(),
    ];

    final List<Widget> guidePages = [
      const HomeScreen(),
      const AIPlannerPage(),
      const PortfolioPage(),
      const BidStatusPage(),
      const GuideProductPage(),
      const MyPage(),
    ];

    final pages = isGuideMode ? guidePages : userPages;

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Palette.background,
        selectedItemColor: const Color(0xFF0055FF),
        unselectedItemColor: Palette.mutedForeground,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 2 && !auth.isGuideMode) {
            context.read<PlannerProvider>().fetchItineraries();
          }
        },
        items: isGuideMode
            ? const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'AI 플래너'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_outlined), activeIcon: Icon(Icons.folder), label: '포트폴리오'),
          BottomNavigationBarItem(icon: Icon(Icons.gavel_outlined), activeIcon: Icon(Icons.gavel), label: '입찰 현황'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined), activeIcon: Icon(Icons.add_box), label: '상품관리'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
        ]
            : const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'AI 플래너'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: '내 여행'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: '가이드 탐색'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: '마이'),
        ],
      ),
    );
  }
}