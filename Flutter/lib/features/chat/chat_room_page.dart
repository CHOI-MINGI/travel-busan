import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/auth/provider/auth_provider.dart';
import 'package:capstone/features/core/network/dio_client.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'dart:convert';

class ChatRoomPage extends StatefulWidget {
  final String roomId;
  final String userNickname;
  final String guideNickname;

  const ChatRoomPage({
    super.key,
    required this.roomId,
    required this.userNickname,
    required this.guideNickname,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<dynamic> _messages = [];
  bool _isLoading = false;
  late StompClient _stompClient;
  String? _myUserId;
  String? _myNickname;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _myUserId = auth.userId;
    _myNickname = auth.nickname;
    _fetchMessages();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _stompClient.deactivate();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final response = await DioClient.instance.get(
        '/api/v1/chat/rooms/${widget.roomId}/messages',
      );
      if (response.statusCode == 200) {
        setState(() {
          _messages = response.data is List ? response.data : (response.data['data'] ?? []);
        });
        _scrollToBottom();
      }
    } catch (e) {
      debugPrint('메시지 로드 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _connectWebSocket() {
    // DioClient baseUrl에서 host 추출
    final baseUrl = DioClient.instance.options.baseUrl
        .replaceAll('http://', 'ws://')
        .replaceAll('https://', 'wss://');

    _stompClient = StompClient(
      config: StompConfig(
        url: '$baseUrl/ws/chat/websocket',
        onConnect: _onConnected,
        onDisconnect: (frame) => debugPrint('WebSocket 연결 해제'),
        onWebSocketError: (error) => debugPrint('WebSocket 에러: $error'),
      ),
    );
    _stompClient.activate();
  }

  void _onConnected(StompFrame frame) {
    // 채팅방 구독
    _stompClient.subscribe(
      destination: '/topic/chat/${widget.roomId}',
      callback: (frame) {
        if (frame.body != null) {
          // 새 메시지 수신
          final newMessage = _parseMessage(frame.body!);
          if (newMessage != null && mounted) {
            setState(() => _messages.add(newMessage));
            _scrollToBottom();
          }
        }
      },
    );

    // 나가기 알림 구독
    _stompClient.subscribe(
      destination: '/topic/chat/${widget.roomId}/leave',
      callback: (frame) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('상대방이 채팅방을 나갔습니다.')),
          );
        }
      },
    );
  }

  Map<String, dynamic>? _parseMessage(String body) {
    try {
      return json.decode(body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    _stompClient.send(
      destination: '/app/chat/${widget.roomId}',
      body: '{"senderId":"$_myUserId","content":"$content"}',
    );

    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _leaveRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('채팅방 나가기'),
        content: const Text('채팅방을 나가면 대화 내용이 종료됩니다.\n나가시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('나가기', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await DioClient.instance.delete('/api/v1/chat/rooms/${widget.roomId}');
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('나가기 실패: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        title: Text(
          widget.guideNickname,
          style: const TextStyle(color: Palette.foreground, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Palette.foreground),
        actions: [
          IconButton(
            onPressed: _leaveRoom,
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            tooltip: '채팅방 나가기',
          ),
        ],
      ),
      body: Column(
        children: [
          // 메시지 목록
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0055FF)))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageBubble(_messages[index]),
            ),
          ),

          // 메시지 입력창
          Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Palette.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Palette.inputBackground,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        hintStyle: TextStyle(color: Palette.mutedForeground),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF0055FF),
                  child: IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['senderId']?.toString() == _myUserId;
    final content = message['content'] ?? '';
    final senderNickname = message['senderNickname'] ?? '';
    final createdAt = _formatTime(message['createdAt']);
    final isRead = message['isRead'] ?? false;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFE8EFFF),
              child: Text(
                senderNickname.isNotEmpty ? senderNickname[0] : 'G',
                style: const TextStyle(color: Color(0xFF0055FF), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(senderNickname, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isMe) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isRead)
                          Text('1', style: const TextStyle(color: Color(0xFF0055FF), fontSize: 11)),
                        Text(createdAt, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                      ],
                    ),
                    const SizedBox(width: 4),
                  ],
                  Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? const Color(0xFF0055FF) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
                        bottomRight: isMe ? Radius.zero : const Radius.circular(16),
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                    ),
                    child: Text(
                      content,
                      style: TextStyle(color: isMe ? Colors.white : Palette.foreground, fontSize: 14),
                    ),
                  ),
                  if (!isMe) ...[
                    const SizedBox(width: 4),
                    Text(createdAt, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(dynamic dateStr) {
    if (dateStr == null) return '';
    try {
      final dt = DateTime.parse(dateStr.toString()).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    } catch (_) {
      return '';
    }
  }
}