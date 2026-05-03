import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import '../provider/planner_detail_provider.dart';
import 'itinerary_detail_page.dart';
import '../../main/main_page.dart';


// 플레너 상세 페이지
class PlannerDetailPage extends StatefulWidget {
  const PlannerDetailPage({super.key});

  @override
  State<PlannerDetailPage> createState() => _PlannerDetailPageState();
}

class _PlannerDetailPageState extends State<PlannerDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlannerProvider>().fetchItineraries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final plannerProvider = context.watch<PlannerProvider>();

    return Scaffold(
      backgroundColor: Palette.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI와 함께한 나만의 기록',
                style: TextStyle(color: Palette.mutedForeground, fontSize: 14),
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(color: Palette.foreground, fontSize: 24, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: '내 '),
                    TextSpan(text: '여행 플랜', style: TextStyle(color: Color(0xFF0055FF))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              if (plannerProvider.isLoading)
                const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 100),
                  child: CircularProgressIndicator(color: Color(0xFF0055FF)),
                ))
              else if (plannerProvider.itineraries.isEmpty)
                _buildEmptyState()
              else
                ...plannerProvider.itineraries.map((itinerary) => Column(
                  children: [
                    InkWell(
                      onTap: () {
                        if (itinerary.itineraryId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItineraryDetailPage(itineraryId: itinerary.itineraryId!),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: _buildPlannerCard(
                        title: itinerary.title,
                        date: '${itinerary.startDate} ~ ${itinerary.endDate}',
                        location: itinerary.region,
                        courseCount: itinerary.courseCount,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                )).toList(),
              
              if (plannerProvider.itineraries.isNotEmpty)
                _buildCreateNewPlanButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      decoration: BoxDecoration(
        color: Palette.inputBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(color: Color(0xFFE8EFFF), shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome, color: Color(0xFF0055FF), size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            '아직 저장된 여행 플랜이 없어요',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.foreground),
          ),
          const SizedBox(height: 8),
          const Text(
            'AI와 함께 나만의 특별한\n여행 일정을 만들어보세요!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Palette.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => _goToAIPlanner(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text('여행 플랜 만들기', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerCard({
    required String title,
    required String date,
    required String location,
    required int courseCount,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              color: const Color(0xFFF0F2F5),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(date, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(location, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(Icons.route_outlined, size: 16, color: Palette.mutedForeground),
                const SizedBox(width: 4),
                Text('$courseCount개 코스', style: const TextStyle(fontSize: 13)),
                const Spacer(),
                const Text('상세보기', style: TextStyle(color: Palette.mutedForeground, fontSize: 12)),
                const Icon(Icons.keyboard_arrow_right, color: Palette.mutedForeground, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewPlanButton() {
    return Container(
      width: double.infinity,
      height: 80,
      margin: const EdgeInsets.only(top: 10),
      child: OutlinedButton(
        onPressed: () => _goToAIPlanner(),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF0055FF), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, color: Color(0xFF0055FF)),
            SizedBox(width: 8),
            Text('새 플랜 추가하기', style: TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  void _goToAIPlanner() {
    final mainPage = context.findAncestorStateOfType<MainPageState>();
    mainPage?.onItemTapped(1);
  }
}
