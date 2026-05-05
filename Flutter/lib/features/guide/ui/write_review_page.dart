import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/core/network/dio_client.dart';

class WriteReviewPage extends StatefulWidget {
  final String guideId;
  final String guideName;
  final String? serviceId;

  const WriteReviewPage({
    super.key,
    required this.guideId,
    required this.guideName,
    this.serviceId,
  });

  @override
  State<WriteReviewPage> createState() => _WriteReviewPageState();
}

class _WriteReviewPageState extends State<WriteReviewPage> {
  double _rating = 5.0;
  final TextEditingController _contentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      final body = {
        'guideId': widget.guideId,
        'serviceId': widget.serviceId,
        'rating': _rating,
        'content': _contentController.text.trim(),
      };

      final response = await DioClient.instance.post('/api/v1/reviews', data: body);
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('리뷰가 등록되었습니다!'), backgroundColor: Color(0xFF0055FF)),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('리뷰 등록 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text('리뷰 작성', style: TextStyle(color: Palette.foreground, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Palette.foreground),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 가이드 정보
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xFFE8EFFF),
                    child: Text(
                      widget.guideName.isNotEmpty ? widget.guideName[0] : 'G',
                      style: const TextStyle(color: Color(0xFF0055FF), fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.guideName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Palette.foreground)),
                      const SizedBox(height: 4),
                      const Text('로컬 가이드', style: TextStyle(color: Palette.mutedForeground, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 별점
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  const Text('투어는 어떠셨나요?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Palette.foreground)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => setState(() => _rating = index + 1.0),
                        child: Icon(
                          index < _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: const Color(0xFFFBBF24),
                          size: 44,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(_rating),
                    style: const TextStyle(color: Palette.mutedForeground, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 리뷰 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('상세 리뷰', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Palette.foreground)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: '투어 경험을 자세히 작성해주세요.',
                      hintStyle: const TextStyle(color: Palette.mutedForeground),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 등록 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(54),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('리뷰 등록', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRatingText(double rating) {
    if (rating >= 5) return '최고예요!';
    if (rating >= 4) return '좋아요';
    if (rating >= 3) return '괜찮아요';
    if (rating >= 2) return '아쉬워요';
    return '별로예요';
  }
}