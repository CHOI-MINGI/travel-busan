import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/core/network/dio_client.dart';

class MyBidStatusPage extends StatefulWidget {
  const MyBidStatusPage({super.key});

  @override
  State<MyBidStatusPage> createState() => _MyBidStatusPageState();
}

class _MyBidStatusPageState extends State<MyBidStatusPage> {
  List<dynamic> _myBids = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMyBids();
  }

  Future<void> _fetchMyBids() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.get('/api/v1/user-bids/my');
      if (response.statusCode == 200) {
        setState(() {
          _myBids = response.data is List ? response.data : (response.data['data'] ?? []);
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

  Future<void> _cancelBid(String bidId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('요청 취소'),
        content: const Text('가이드 요청을 취소하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('취소하기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await DioClient.instance.delete('/api/v1/user-bids/$bidId');
      if (response.statusCode == 204) {
        setState(() => _myBids.removeWhere((b) => b['bidId'] == bidId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('요청이 취소되었습니다.')),
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

  Future<void> _viewApplicants(String bidId, String title) async {
    try {
      final response = await DioClient.instance.get('/api/v1/bid-applications/$bidId');
      if (response.statusCode == 200) {
        final applicants = response.data is List ? response.data : (response.data['data'] ?? []);
        if (mounted) {
          _showApplicantsBottomSheet(bidId, title, applicants);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('참여 가이드 조회 실패: $e')),
        );
      }
    }
  }

  void _showApplicantsBottomSheet(String bidId, String title, List<dynamic> applicants) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const Text('참여한 가이드', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFF0055FF), borderRadius: BorderRadius.circular(20)),
                    child: Text('${applicants.length}명', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: applicants.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_outlined, size: 48, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('아직 참여한 가이드가 없습니다.', style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              )
                  : ListView.separated(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: applicants.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final applicant = applicants[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE8EFFF),
                      child: Text(
                        (applicant['guideNickname'] ?? 'G')[0],
                        style: const TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      applicant['guideNickname'] ?? '가이드',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_formatDate(applicant['createdAt'])),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _selectGuide(applicant['applicationId'], title);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0055FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('선택', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectGuide(String applicationId, String title) async {
    try {
      final response = await DioClient.instance.post(
        '/api/v1/bid-applications/$applicationId/select',
      );
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가이드를 선택했습니다! 채팅방이 생성되었습니다.'),
            backgroundColor: Color(0xFF0055FF),
          ),
        );
        _fetchMyBids();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('가이드 선택 실패: $e')),
        );
      }
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
        title: const Text(
          '내 요청 현황',
          style: TextStyle(color: Palette.foreground, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Palette.foreground),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
          : RefreshIndicator(
        onRefresh: _fetchMyBids,
        child: _myBids.isEmpty ? _buildEmptyState() : _buildBidList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Column(
          children: [
            Icon(Icons.send_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('아직 요청한 일정이 없습니다.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('내 여행에서 가이드에게 제안해보세요.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildBidList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _myBids.length,
      itemBuilder: (context, index) => _buildBidCard(_myBids[index]),
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final bidId = bid['bidId']?.toString() ?? '';
    final title = bid['title'] ?? '제목 없음';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Palette.foreground)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: Palette.mutedForeground),
                    const SizedBox(width: 4),
                    Text(bid['region'] ?? '', style: const TextStyle(color: Palette.mutedForeground, fontSize: 13)),
                    const SizedBox(width: 12),
                    const Icon(Icons.calendar_today_outlined, size: 13, color: Palette.mutedForeground),
                    const SizedBox(width: 4),
                    Text(
                      '${bid['startDate'] ?? ''} ~ ${bid['endDate'] ?? ''}',
                      style: const TextStyle(color: Palette.mutedForeground, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '요청일: ${_formatDate(bid['createdAt'])}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 참여한 가이드 보기
                Expanded(
                  flex: 3,
                  child: ElevatedButton.icon(
                    onPressed: () => _viewApplicants(bidId, title),
                    icon: const Icon(Icons.people_outline, size: 16),
                    label: const Text('참여한 가이드 보기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 요청 취소
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: () => _cancelBid(bidId),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('요청 취소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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