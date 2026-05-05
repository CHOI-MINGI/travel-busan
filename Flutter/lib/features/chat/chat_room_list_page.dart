import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/core/network/dio_client.dart';
import 'chat_room_page.dart';

class ChatRoomListPage extends StatefulWidget {
  const ChatRoomListPage({super.key});

  @override
  State<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends State<ChatRoomListPage> {
  List<dynamic> _rooms = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  Future<void> _fetchRooms() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.get('/api/v1/chat/rooms');
      if (response.statusCode == 200) {
        setState(() {
          _rooms = response.data is List ? response.data : (response.data['data'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: const Text(
          '채팅',
          style: TextStyle(color: Palette.foreground, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Palette.foreground),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
          : RefreshIndicator(
        onRefresh: _fetchRooms,
        child: _rooms.isEmpty ? _buildEmptyState() : _buildRoomList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        Column(
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('아직 채팅방이 없습니다.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            const SizedBox(height: 8),
            Text('가이드를 선택하면 채팅방이 생성됩니다.', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoomList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildRoomCard(_rooms[index]),
    );
  }

  Widget _buildRoomCard(Map<String, dynamic> room) {
    final roomId = room['roomId']?.toString() ?? '';
    final userNickname = room['userNickname'] ?? '';
    final guideNickname = room['guideNickname'] ?? '';
    final lastMessage = room['lastMessage'] ?? '';
    final unreadCount = room['unreadCount'] ?? 0;
    final isClosed = room['isClosed'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatRoomPage(
              roomId: roomId,
              userNickname: userNickname,
              guideNickname: guideNickname,
            ),
          ),
        ).then((_) => _fetchRooms());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            // 아바타
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFE8EFFF),
                  child: Text(
                    guideNickname.isNotEmpty ? guideNickname[0] : 'G',
                    style: const TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                if (isClosed)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 14, height: 14,
                      decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        guideNickname,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Palette.foreground),
                      ),
                      if (isClosed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(10)),
                          child: Text('종료', style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage.isNotEmpty ? lastMessage : '채팅을 시작해보세요',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 읽지 않은 메시지 뱃지
            if (unreadCount > 0)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0055FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }
}