import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/ai/ai_planner_provider.dart';
import 'package:capstone/features/auth/provider/auth_provider.dart';
import 'package:capstone/features/guide/ui/guide_register_page.dart';

class AIPlannerPage extends StatefulWidget {
  const AIPlannerPage({super.key});

  @override
  State<AIPlannerPage> createState() => _AIPlannerPageState();
}

class _AIPlannerPageState extends State<AIPlannerPage> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedInterests = {};

  final List<Map<String, dynamic>> _interests = [
    {'icon': Icons.sailing, 'label': '레저'},
    {'icon': Icons.restaurant, 'label': '맛집'},
    {'icon': Icons.directions_walk, 'label': '산책'},
    {'icon': Icons.waves, 'label': '바다/해변'},
    {'icon': Icons.music_note, 'label': '문화/공연'},
  ];

  final List<String> _exampleQueries = [
    '부산 1박2일 맛집 투어 일정 추천해줘',
  ];

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final plannerProvider = context.watch<AIPlannerProvider>();

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFF6600FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI 여행 플래너',
                  style: TextStyle(color: Palette.foreground, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text('온라인', style: TextStyle(color: Colors.green, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                ...plannerProvider.messages.map((msg) => _buildChatBubble(msg)),
                if (plannerProvider.isLoading) _buildLoadingBubble(),
              ],
            ),
          ),
          if (plannerProvider.messages.length == 1 && !plannerProvider.isLoading)
            _buildHelperUI(),
          _buildInputSection(plannerProvider),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    bool isAi = message.role == MessageRole.ai;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAi) ...[
            _buildAiIcon(),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAi ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                if (message.planData != null)
                  _buildPlanCard(message.planData!)
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isAi ? Palette.inputBackground : const Color(0xFF0055FF),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(15),
                        topRight: const Radius.circular(15),
                        bottomLeft: isAi ? Radius.zero : const Radius.circular(15),
                        bottomRight: isAi ? const Radius.circular(15) : Radius.zero,
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(color: isAi ? Palette.foreground : Colors.white, height: 1.4),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiIcon() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(color: Color(0xFF6600FF), shape: BoxShape.circle),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 14),
    );
  }

  Widget _buildPlanCard(PlanData data) {
    int currentDay = 0;
    // ★ 여기서 읽어야 _buildPlanCard() 안에서 사용 가능
    final isGuideMode = context.read<AuthProvider>().isGuideMode;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Icon(Icons.near_me_outlined, color: Color(0xFF0055FF), size: 20),
                const SizedBox(width: 8),
                const Text('자동 생성 일정', style: TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.courses.asMap().entries.map((entry) {
                int idx = entry.key;
                var course = entry.value;
                bool isLast = idx == data.courses.length - 1;

                bool showDayHeader = course.dayNumber != currentDay;
                if (showDayHeader) currentDay = course.dayNumber;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showDayHeader)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12, top: 8),
                        child: Text(
                          'DAY ${course.dayNumber}',
                          style: const TextStyle(
                            color: Color(0xFF0055FF),
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(color: Color(0xFFE8EFFF), shape: BoxShape.circle),
                                child: Icon(course.icon, size: 16, color: const Color(0xFF0055FF)),
                              ),
                              if (!isLast && data.courses[idx + 1].dayNumber == course.dayNumber)
                                Expanded(child: VerticalDivider(color: Colors.grey[300], thickness: 1.5, width: 28)),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(course.place, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                const SizedBox(height: 4),
                                Text(course.duration, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                          Text(course.startTime, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (isGuideMode) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GuideRegisterPage(initialPlanData: data),
                          ),
                        );
                      } else {
                        context.read<AIPlannerProvider>().savePlanner(data).then((success) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('상세 플래너에 저장되었습니다.')));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('저장에 실패했습니다.')));
                          }
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0055FF),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(isGuideMode ? '상품 생성' : '+ 상세 플래너에 추가'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showResetConfirmDialog(),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text(isGuideMode ? '상품 다시 생성하기' : '다른 일정 생성'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Palette.foreground,
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('초기화하시겠습니까?'),
        content: const Text('해당 계획은 폐기할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('아니오')),
          TextButton(
            onPressed: () {
              context.read<AIPlannerProvider>().resetChat();
              Navigator.pop(context);
            },
            child: const Text('예', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAiIcon(),
          const SizedBox(width: 10),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Palette.inputBackground,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const _FadingText(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelperUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('관심 분야를 선택하세요', style: TextStyle(color: Palette.mutedForeground, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _interests.map((item) => _buildInterestChip(item['icon'], item['label'])).toList(),
          ),
          const SizedBox(height: 24),
          const Text('이렇게 물어보세요', style: TextStyle(color: Palette.mutedForeground, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ..._exampleQueries.map((query) => _buildExampleQueryCard(query)),
        ],
      ),
    );
  }

  Widget _buildInterestChip(IconData icon, String label) {
    final isSelected = _selectedInterests.contains(label);
    return FilterChip(
      label: Text(label),
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Palette.mutedForeground),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          if (selected) _selectedInterests.add(label);
          else _selectedInterests.remove(label);
        });
      },
      backgroundColor: Palette.inputBackground,
      selectedColor: const Color(0xFF6600FF),
      labelStyle: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Palette.foreground),
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
    );
  }

  Widget _buildExampleQueryCard(String query) {
    return InkWell(
      onTap: () => _messageController.text = query,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Palette.inputBackground.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(child: Text(query, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Palette.mutedForeground),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(AIPlannerProvider provider) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        color: Palette.background,
        border: Border(top: BorderSide(color: Palette.border, width: 0.5)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Palette.inputBackground,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: '여행지, 일정, 취향을 말해주세요...',
                  hintStyle: TextStyle(color: Palette.mutedForeground, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) => _handleSend(provider),
              ),
            ),
            IconButton(
              onPressed: () => _handleSend(provider),
              icon: const Icon(Icons.send_rounded, color: Color(0xFF0055FF)),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSend(AIPlannerProvider provider) {
    if (_messageController.text.isNotEmpty) {
      provider.sendMessage(_messageController.text, _selectedInterests.toList());
      _messageController.clear();
      _scrollToBottom();
    }
  }
}

class _FadingText extends StatefulWidget {
  const _FadingText();
  @override
  State<_FadingText> createState() => _FadingTextState();
}

class _FadingTextState extends State<_FadingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: const Text(
        '사용자님을 위한 여행 일정을 생성 중 이예요.',
        style: TextStyle(color: Palette.foreground, fontSize: 14, height: 1.4),
      ),
    );
  }
}