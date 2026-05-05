import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/core/network/dio_client.dart';

class BidStatusPage extends StatefulWidget {
  const BidStatusPage({super.key});

  @override
  State<BidStatusPage> createState() => _BidStatusPageState();
}

class _BidStatusPageState extends State<BidStatusPage> {
  List<dynamic> _bids = [];
  bool _isLoading = false;

  // 내가 참여한 입찰 ID 목록
  final Set<String> _appliedBidIds = {};

  @override
  void initState() {
    super.initState();
    _fetchBids();
  }

  Future<void> _fetchBids() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.get('/api/v1/user-bids/guide');
      if (response.statusCode == 200) {
        setState(() {
          _bids = response.data is List ? response.data : (response.data['data'] ?? []);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('불러오기 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _applyBid(String bidId) async {
    try {
      final response = await DioClient.instance.post(
        '/api/v1/bid-applications',
        data: {'bidId': bidId},
      );
      if (response.statusCode == 201) {
        setState(() => _appliedBidIds.add(bidId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('입찰에 참여했습니다!'),
              backgroundColor: Color(0xFF0055FF),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('입찰 참여 실패: $e')),
        );
      }
    }
  }

  Future<void> _cancelBid(String bidId) async {
    try {
      final response = await DioClient.instance.delete(
        '/api/v1/bid-applications/$bidId',
      );
      if (response.statusCode == 204) {
        setState(() => _appliedBidIds.remove(bidId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('입찰 참여를 취소했습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('취소 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          '사용자 요청 현황',
          style: TextStyle(color: Palette.foreground, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
          : RefreshIndicator(
        onRefresh: _fetchBids,
        child: _bids.isEmpty ? _buildEmptyState() : _buildBidList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Column(
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('아직 사용자 요청이 없습니다.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('사용자가 일정을 제안하면 여기에 표시됩니다.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildBidList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _bids.length,
      itemBuilder: (context, index) => _buildBidCard(_bids[index]),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final courses = (bid['courses'] as List?) ?? [];
    final status = bid['status'] ?? 'PENDING';
    final bidId = bid['bidId']?.toString() ?? '';
    final isApplied = _appliedBidIds.contains(bidId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 제목 + 상태
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid['title'] ?? '제목 없음',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Palette.foreground),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(bid['userNickname'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(bid['region'] ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
          ),

          // 날짜
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  '${bid['startDate'] ?? ''} ~ ${bid['endDate'] ?? ''}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // 코스 목록
          if (courses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('일정 (${courses.length}개 코스)', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  ...courses.take(3).map((course) => _buildCourseItem(course)),
                  if (courses.length > 3)
                    Text('외 ${courses.length - 3}개 코스 더보기', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                ],
              ),
            ),

          const Divider(height: 1),

          // 요청 시간
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.access_time, size: 13, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '요청일: ${_formatDate(bid['createdAt'])}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),

          // ★ 입찰 참여 / 취소 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: isApplied
                  ? OutlinedButton.icon(
                onPressed: () => _cancelBid(bidId),
                icon: const Icon(Icons.cancel_outlined, size: 16),
                label: const Text('참여 취소', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              )
                  : ElevatedButton.icon(
                onPressed: () => _applyBid(bidId),
                icon: const Icon(Icons.handshake_outlined, size: 16),
                label: const Text('입찰 참여하기', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0055FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseItem(Map<String, dynamic> course) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(color: Color(0xFFE8EFFF), shape: BoxShape.circle),
            child: Center(
              child: Text(
                '${course['dayNumber'] ?? ''}',
                style: const TextStyle(color: Color(0xFF0055FF), fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(course['placeName'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          Text(
            course['startTime'] != null ? '${course['startTime']}'.substring(0, 5) : '',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          const SizedBox(width: 6),
          Text(
            course['durationMinutes'] != null ? '${course['durationMinutes']}분' : '',
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'ACCEPTED':
        bgColor = const Color(0xFFE8F5E9);
        textColor = const Color(0xFF2E7D32);
        label = '수락됨';
        break;
      case 'REJECTED':
        bgColor = const Color(0xFFFFEBEE);
        textColor = Colors.red;
        label = '거절됨';
        break;
      default:
        bgColor = const Color(0xFFFFF8E1);
        textColor = const Color(0xFFF57F17);
        label = '대기중';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr.toString());
      return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}