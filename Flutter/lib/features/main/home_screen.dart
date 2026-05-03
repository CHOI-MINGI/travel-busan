import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/auth/provider/auth_provider.dart';
import 'package:capstone/features/auth/login_page.dart';
import 'package:capstone/features/core/network/dio_client.dart';
import 'package:capstone/features/main/place_detail_page.dart';
import 'package:capstone/features/main/main_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 카테고리 탭
  final List<Map<String, dynamic>> _categories = [
    {'label': '인문', 'cat': '인문(문화/예술/역사)', 'icon': Icons.account_balance_outlined},
    {'label': '음식', 'cat': '음식', 'icon': Icons.restaurant_outlined},
    {'label': '자연', 'cat': '자연', 'icon': Icons.park_outlined},
    {'label': '숙박', 'cat': '숙박', 'icon': Icons.hotel_outlined},
    {'label': '쇼핑', 'cat': '쇼핑', 'icon': Icons.shopping_bag_outlined},
    {'label': '레포츠', 'cat': '레포츠', 'icon': Icons.directions_bike_outlined},
    {'label': '추천코스', 'cat': '추천코스', 'icon': Icons.route_outlined},
  ];

  int _selectedCategoryIndex = 0;
  List<dynamic> _recommendPlaces = [];
  List<dynamic> _popularPlaces = [];
  bool _isLoadingRecommend = false;
  bool _isLoadingPopular = false;

  @override
  void initState() {
    super.initState();
    _fetchRecommend(_categories[0]['cat']);
    _fetchPopular();
  }

  Future<void> _fetchRecommend(String category) async {
    setState(() => _isLoadingRecommend = true);
    try {
      final response = await DioClient.instance.get(
        '/api/v1/places/recommend',
        queryParameters: {'category': category},
      );
      if (response.statusCode == 200) {
        setState(() => _recommendPlaces = response.data);
      }
    } catch (e) {
      debugPrint('추천 장소 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingRecommend = false);
    }
  }

  Future<void> _fetchPopular() async {
    setState(() => _isLoadingPopular = true);
    try {
      final response = await DioClient.instance.get('/api/v1/places/popular');
      if (response.statusCode == 200) {
        setState(() => _popularPlaces = response.data);
      }
    } catch (e) {
      debugPrint('인기 장소 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingPopular = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final nickname = auth.nickname ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요 $nickname님!',
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                  ),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Palette.foreground, fontSize: 24, fontWeight: FontWeight.bold),
                      children: [
                        TextSpan(text: 'Travel '),
                        TextSpan(text: 'Busan', style: TextStyle(color: Color(0xFF0055FF)))
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Palette.mutedForeground, size: 28),
                tooltip: '로그아웃',
              ),
            ],
          ),

          const SizedBox(height: 25),

          // AI 검색바
          InkWell(
            onTap: () {
              context.findAncestorStateOfType<MainPageState>()?.onItemTapped(1);
            },
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 56,
              decoration: BoxDecoration(
                color: Palette.inputBackground,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Palette.mutedForeground),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'AI에게 여행 일정을 물어보세요',
                      style: TextStyle(color: Palette.mutedForeground),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0055FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          // 추천 장소 섹션
          const Text(
            '추천 장소',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.foreground),
          ),
          const SizedBox(height: 12),

          // 카테고리 탭
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategoryIndex = index);
                    _fetchRecommend(_categories[index]['cat']);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0055FF) : Palette.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _categories[index]['icon'],
                          size: 14,
                          color: isSelected ? Colors.white : Palette.mutedForeground,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _categories[index]['label'],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : Palette.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // 추천 장소 가로 스크롤
          SizedBox(
            height: 200,
            child: _isLoadingRecommend
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
                : _recommendPlaces.isEmpty
                ? Center(child: Text('장소 정보가 없습니다.', style: TextStyle(color: Colors.grey[400])))
                : ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _recommendPlaces.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  _buildPlaceCard(_recommendPlaces[index], width: 150),
            ),
          ),

          const SizedBox(height: 30),

          // 인기 장소 섹션
          const Text(
            '지금 인기있는 곳',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.foreground),
          ),
          const SizedBox(height: 14),

          _isLoadingPopular
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
              : _popularPlaces.isEmpty
              ? Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: Palette.inputBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '아직 인기 장소 데이터가 없습니다.',
                style: TextStyle(color: Colors.grey[400]),
              ),
            ),
          )
              : GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: _popularPlaces.length,
            itemBuilder: (context, index) =>
                _buildPlaceCard(_popularPlaces[index], width: double.infinity),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, {required double width}) {
    final imageUrl = place['firstImage'] ?? '';
    final title = place['title'] ?? '';
    final addr = place['addr1'] ?? '';
    final cat = place['cat1'] ?? '';
    final placeId = place['placeId'] as int?;

    return GestureDetector(
      onTap: () {
        if (placeId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PlaceDetailPage(
                placeId: placeId,
                title: title,
                imageUrl: imageUrl,
              ),
            ),
          );
        }
      },
      child: Container(
        width: width == double.infinity ? null : width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            Expanded(
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8EFFF),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
                ),
              )
                  : Container(
                color: const Color(0xFFE8EFFF),
                child: const Center(
                  child: Icon(Icons.location_on_outlined, color: Color(0xFF0055FF), size: 32),
                ),
              ),
            ),

            // 정보
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Palette.foreground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addr,
                    style: const TextStyle(fontSize: 11, color: Palette.mutedForeground),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (cat.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8EFFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cat,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF0055FF), fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ), // Container
    ); // GestureDetector
  }
}