import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/auth/provider/auth_provider.dart';
import '../model/guide_item.dart';
import '../repository/guide_repository.dart';
import 'guide_detail_page.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({super.key});

  @override
  State<PortfolioPage> createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final GuideRepository _repository = GuideRepository();
  List<GuideItem> _publishedProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPublishedProducts();
  }

  Future<void> _fetchPublishedProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _repository.getMyPublishedProducts();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        setState(() {
          _publishedProducts = data
              .map((e) => GuideItem.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('포트폴리오 로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nickname = context.read<AuthProvider>().nickname ?? '가이드';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
          : RefreshIndicator(
        onRefresh: _fetchPublishedProducts,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 흰색 영역
              Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 16,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '가이드 포트폴리오',
                      style: TextStyle(color: Palette.mutedForeground, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      nickname,
                      style: const TextStyle(
                        color: Palette.foreground,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildStatsCard(),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 등록된 투어 타이틀
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  '등록된 투어',
                  style: TextStyle(
                    color: Palette.foreground,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 카드 목록 (각각 분리)
              _publishedProducts.isEmpty
                  ? _buildEmptyState()
                  : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _publishedProducts
                      .map((item) => _buildProductCard(item))
                      .toList(),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem(
            icon: Icons.bookmark_border,
            iconColor: const Color(0xFF9CA3AF),
            label: '등록 투어',
            value: '${_publishedProducts.length}',
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          _statItem(
            icon: Icons.star_border,
            iconColor: const Color(0xFFFBBF24),
            label: '평균 평점',
            value: '-',
          ),
          Container(width: 1, height: 40, color: const Color(0xFFE5E7EB)),
          _statItem(
            icon: Icons.people_outline,
            iconColor: const Color(0xFF9CA3AF),
            label: '총 리뷰',
            value: '-',
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Palette.mutedForeground, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Palette.foreground,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(Icons.storefront_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text('게시된 투어가 없습니다.', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
            const SizedBox(height: 6),
            Text('상품 관리에서 투어를 게시해보세요.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(GuideItem item) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GuideDetailPage(item: item)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 평점
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Palette.foreground,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 15),
                        const SizedBox(width: 3),
                        Text(
                          item.rating > 0 ? item.rating.toStringAsFixed(1) : '-',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // 지역
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: Palette.mutedForeground),
                  const SizedBox(width: 2),
                  Text(
                    item.region,
                    style: const TextStyle(color: Palette.mutedForeground, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 소요시간 · 가격 · 리뷰
              Row(
                children: [
                  _infoItem(Icons.access_time_outlined, item.durationText),
                  const SizedBox(width: 16),
                  _infoItem(Icons.person_outline, '1인 ${_formatPrice(item.price)}원'),
                  const SizedBox(width: 16),
                  _infoItem(Icons.chat_bubble_outline, '${item.reviewCount}개 리뷰'),
                ],
              ),
              const SizedBox(height: 10),

              // 코스 수
              Text(
                '${item.schedules.length}개 코스 포함',
                style: const TextStyle(color: Palette.mutedForeground, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Palette.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Palette.mutedForeground, fontSize: 12)),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price == 0) return '0';
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }
}