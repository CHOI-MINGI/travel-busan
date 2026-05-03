import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/core/network/dio_client.dart';

class PlaceDetailPage extends StatefulWidget {
  final int placeId;
  final String title;
  final String imageUrl;

  const PlaceDetailPage({
    super.key,
    required this.placeId,
    required this.title,
    required this.imageUrl,
  });

  @override
  State<PlaceDetailPage> createState() => _PlaceDetailPageState();
}

class _PlaceDetailPageState extends State<PlaceDetailPage> {
  Map<String, dynamic>? _detail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.get('/api/v1/places/${widget.placeId}');
      if (response.statusCode == 200) {
        setState(() => _detail = response.data as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('장소 상세 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
          : CustomScrollView(
        slivers: [
          // 상단 이미지 앱바
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0055FF),
            leading: CircleAvatar(
              backgroundColor: Colors.black26,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: widget.imageUrl.isNotEmpty
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFE8EFFF),
                      child: const Center(
                        child: Icon(Icons.image_not_supported_outlined,
                            color: Colors.grey, size: 48),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.5),
                        ],
                      ),
                    ),
                  ),
                ],
              )
                  : Container(color: const Color(0xFFE8EFFF)),
            ),
          ),

          SliverToBoxAdapter(
            child: _detail == null
                ? const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: Text('정보를 불러올 수 없습니다.')),
            )
                : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 카테고리
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _detail!['title'] ?? widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Palette.foreground,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 카테고리 태그
                        Wrap(
                          spacing: 6,
                          children: [
                            if ((_detail!['cat1'] ?? '').isNotEmpty)
                              _categoryChip(_detail!['cat1']),
                            if ((_detail!['cat2'] ?? '').isNotEmpty)
                              _categoryChip(_detail!['cat2']),
                            if ((_detail!['cat3'] ?? '').isNotEmpty)
                              _categoryChip(_detail!['cat3']),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 주소
                  _infoCard(
                    icon: Icons.location_on_outlined,
                    title: '주소',
                    content: (_detail!['addr1'] ?? '').isNotEmpty
                        ? _detail!['addr1']
                        : '주소 정보가 없습니다.',
                  ),

                  const SizedBox(height: 12),

                  // 홈페이지
                  if ((_detail!['homepage'] ?? '').isNotEmpty)
                    _infoCard(
                      icon: Icons.language_outlined,
                      title: '홈페이지',
                      content: _detail!['homepage'],
                    ),

                  if ((_detail!['homepage'] ?? '').isNotEmpty)
                    const SizedBox(height: 12),

                  // 상세 설명
                  _infoCard(
                    icon: Icons.info_outline,
                    title: '상세 설명',
                    content: (_detail!['overview'] == null || _detail!['overview'].toString().trim().isEmpty)
                        ? '상세 설명이 없습니다.'
                        : _detail!['overview'].toString().trim(),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EFFF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF0055FF),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF0055FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Palette.foreground,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Palette.mutedForeground,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}