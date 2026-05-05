import 'package:flutter/material.dart';
import 'package:capstone/features/core/network/dio_client.dart';
import '../model/guide_item.dart';
import 'guide_apply_page.dart';
import 'write_review_page.dart';
import 'package:capstone/features/chat/chat_room_page.dart';

class GuideDetailPage extends StatefulWidget {
  final GuideItem item;

  const GuideDetailPage({
    super.key,
    required this.item,
  });

  @override
  State<GuideDetailPage> createState() => _GuideDetailPageState();
}

class _GuideDetailPageState extends State<GuideDetailPage> {
  List<dynamic> _reviews = [];
  double _averageRating = 0.0;
  int _reviewCount = 0;
  bool _isLoadingReviews = false;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      final guideId = widget.item.serviceId;

      // 평점 요약
      final summaryRes = await DioClient.instance.get('/api/v1/reviews/guide/$guideId/summary');
      if (summaryRes.statusCode == 200) {
        setState(() {
          _averageRating = (summaryRes.data['averageRating'] ?? 0.0).toDouble();
          _reviewCount = (summaryRes.data['reviewCount'] ?? 0) as int;
        });
      }

      // 리뷰 목록
      final reviewsRes = await DioClient.instance.get('/api/v1/reviews/guide/$guideId');
      if (reviewsRes.statusCode == 200) {
        setState(() {
          _reviews = reviewsRes.data is List ? reviewsRes.data : (reviewsRes.data['data'] ?? []);
        });
      }
    } catch (e) {
      debugPrint('리뷰 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          '가이드 상세',
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.w800),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF111827)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              widget.item.imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  width: double.infinity,
                  height: 240,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported, size: 40),
                );
              },
            ),
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.item.guideName,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                      ),
                      const SizedBox(width: 6),
                      if (widget.item.isVerified)
                        const Icon(Icons.verified, color: Color(0xFF22C55E), size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        _averageRating > 0 ? _averageRating.toStringAsFixed(1) : '-',
                        style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151)),
                      ),
                      const SizedBox(width: 8),
                      Text('리뷰 $_reviewCount개', style: const TextStyle(color: Color(0xFF9CA3AF))),
                      const SizedBox(width: 8),
                      const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF9CA3AF)),
                      Text(widget.item.region, style: const TextStyle(color: Color(0xFF9CA3AF))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.item.description,
                    style: const TextStyle(fontSize: 15, height: 1.5, color: Color(0xFF4B5563)),
                  ),
                  const SizedBox(height: 18),
                  _InfoBox(item: widget.item),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: '안내 가능 언어',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.item.languages.map((lang) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFF2F4F8), borderRadius: BorderRadius.circular(16)),
                  child: Text(lang, style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF374151))),
                )).toList(),
              ),
            ),
            _SectionCard(
              title: '접선 장소',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.item.meetingPlace, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  if (widget.item.meetingGuide.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(widget.item.meetingGuide, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4)),
                  ],
                ],
              ),
            ),
            _SectionCard(
              title: '포함 사항',
              child: Column(
                children: widget.item.includedItems.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline, color: Color(0xFF16A34A), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(e, style: const TextStyle(fontSize: 14, color: Color(0xFF374151)))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            _SectionCard(
              title: '상세 일정',
              child: Column(
                children: widget.item.schedules.map((schedule) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${schedule.startTime} ~ ${schedule.endTime}',
                          style: const TextStyle(color: Color(0xFF2F6BFF), fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(schedule.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                      const SizedBox(height: 6),
                      Text(schedule.description, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280), height: 1.4)),
                    ],
                  ),
                )).toList(),
              ),
            ),

            // ★ 리뷰 섹션
            _SectionCard(
              title: '리뷰 $_reviewCount개',
              child: _isLoadingReviews
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
                  : _reviews.isEmpty
                  ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text('아직 리뷰가 없습니다.', style: TextStyle(color: Colors.grey[400])),
                ),
              )
                  : Column(
                children: _reviews.take(5).map((review) => _buildReviewItem(review)).toList(),
              ),
            ),

            // ★ 리뷰 작성 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WriteReviewPage(
                        guideId: widget.item.serviceId,
                        guideName: widget.item.guideName,
                        serviceId: widget.item.serviceId,
                      ),
                    ),
                  );
                  if (result == true) _fetchReviews();
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('리뷰 작성하기', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  foregroundColor: const Color(0xFF0055FF),
                  side: const BorderSide(color: Color(0xFF0055FF)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),

            const SizedBox(height: 90),
          ],
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // 문의하기 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final response = await DioClient.instance.post(
                        '/api/v1/chat/rooms/direct',
                        data: {'guideId': widget.item.guideId},
                      );
                      if ((response.statusCode == 200 || response.statusCode == 201) && context.mounted) {
                        final room = response.data as Map<String, dynamic>;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomPage(
                              roomId: room['roomId'].toString(),
                              userNickname: room['userNickname'] ?? '',
                              guideNickname: room['guideNickname'] ?? widget.item.guideName,
                            ),
                          ),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('문의 실패: $e')),
                      );
                    }
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('문의하기', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    foregroundColor: const Color(0xFF2F6BFF),
                    side: const BorderSide(color: Color(0xFF2F6BFF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // 신청하기 버튼
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => GuideApplyPage(item: widget.item)));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F6BFF),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Text(
                    '신청하기 · 1인 ${_formatPrice(widget.item.price)}원',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final rating = (review['rating'] ?? 0.0).toDouble();
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFFE8EFFF),
                child: Text(
                  (review['userNickname'] ?? 'U')[0],
                  style: const TextStyle(color: Color(0xFF0055FF), fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(review['userNickname'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const Spacer(),
              Row(
                children: List.generate(5, (i) => Icon(
                  i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: const Color(0xFFFBBF24),
                  size: 16,
                )),
              ),
            ],
          ),
          if ((review['content'] ?? '').isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review['content'], style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563), height: 1.4)),
          ],
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    final str = price.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final reverseIndex = str.length - i;
      buffer.write(str[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }
}

class _InfoBox extends StatelessWidget {
  final GuideItem item;
  const _InfoBox({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _Item(label: '소요 시간', value: item.durationText),
          _Divider(),
          _Item(label: '정원', value: item.peopleText),
          _Divider(),
          _Item(label: '자차', value: item.hasOwnCar ? '포함' : '도보/대중교통'),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final String label;
  final String value;
  const _Item({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Color(0xFF111827), fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 34, color: const Color(0xFFE5E7EB));
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}