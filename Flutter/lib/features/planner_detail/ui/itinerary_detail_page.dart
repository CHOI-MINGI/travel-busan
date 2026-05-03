import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import '../provider/itinerary_detail_provider.dart';
import '../models/itinerary_detail_model.dart';
import '../repository/planner_detail_repository.dart';

class ItineraryDetailPage extends StatefulWidget {
  final int itineraryId;

  const ItineraryDetailPage({super.key, required this.itineraryId});

  @override
  State<ItineraryDetailPage> createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  bool _isEditMode = false;
  List<ItineraryDetailItem> _editableItems = [];

  final PlannerRepository _plannerRepository = PlannerRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ItineraryDetailProvider>().fetchItineraryDetail(widget.itineraryId);
    });
  }

  // ==================== 시간 유틸리티 ====================

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length != 2) return 0;
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  String? _checkTimeConflict(int targetIndex, int newStartMin, int newDurationMin) {
    final targetItem = _editableItems[targetIndex];
    final newEndMin = newStartMin + newDurationMin;

    for (int i = 0; i < _editableItems.length; i++) {
      if (i == targetIndex) continue;
      final other = _editableItems[i];
      if (other.dayNumber != targetItem.dayNumber) continue;

      final otherStart = _timeToMinutes(other.startTime);
      final otherEnd = otherStart + other.durationMinutes;

      if (newStartMin < otherEnd && newEndMin > otherStart) {
        return '${other.placeName}(${other.startTime} ~ ${_minutesToTime(otherEnd)})와 시간이 겹칩니다.';
      }
    }
    return null;
  }

  // ==================== 수정 모드 ====================

  void _enterEditMode(ItineraryDetailResponse detail) {
    setState(() {
      _isEditMode = true;
      _editableItems = detail.details.map((item) => ItineraryDetailItem(
        detailId: item.detailId,
        dayNumber: item.dayNumber,
        startTime: item.startTime,
        durationMinutes: item.durationMinutes,
        placeName: item.placeName,
        categoryType: List.from(item.categoryType),
        operatingHours: item.operatingHours,
        description: item.description,
        sortOrder: item.sortOrder,
        latitude: item.latitude,
        longitude: item.longitude,
      )).toList();
    });
  }

  void _cancelEditMode() {
    setState(() {
      _isEditMode = false;
      _editableItems = [];
    });
  }

  void _saveEditMode() {
    context.read<ItineraryDetailProvider>().updateLocalDetails(_editableItems);
    setState(() => _isEditMode = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('일정이 수정되었습니다.'), backgroundColor: Color(0xFF2962FF)),
    );
  }

  // ==================== 삭제 ====================

  Future<void> _deleteItinerary() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('일정 삭제'),
        content: const Text('이 일정을 삭제하시겠습니까?\n삭제된 일정은 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _plannerRepository.deleteItinerary(widget.itineraryId);
      if (response.statusCode == 204 && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일정이 삭제되었습니다.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  // ==================== 가이드에게 제안하기 ====================

  Future<void> _proposeToGuide() async {
    try {
      final response = await _plannerRepository.createUserBid(widget.itineraryId);
      if ((response.statusCode == 200 || response.statusCode == 201) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('가이드에게 일정을 제안했습니다!'),
            backgroundColor: Color(0xFF0055FF),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('제안 실패: $e')),
        );
      }
    }
  }

  // ==================== 수정 다이얼로그 ====================

  Future<void> _showEditDialog(int index) async {
    final item = _editableItems[index];

    final placeNameController = TextEditingController(text: item.placeName);
    final descriptionController = TextEditingController(text: item.description);
    final operatingHoursController = TextEditingController(text: item.operatingHours);

    int selectedStartMin = _timeToMinutes(item.startTime);
    int selectedDuration = item.durationMinutes;
    String? conflictMessage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24, right: 24, top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text('일정 수정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),

                    const Text('장소명', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: placeNameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.inputBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: '장소명 입력',
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('시작 시간', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: ctx,
                          initialTime: TimeOfDay(hour: selectedStartMin ~/ 60, minute: selectedStartMin % 60),
                          builder: (context, child) => MediaQuery(
                            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                            child: child!,
                          ),
                        );
                        if (picked != null) {
                          final newStart = picked.hour * 60 + picked.minute;
                          final conflict = _checkTimeConflict(index, newStart, selectedDuration);
                          setModalState(() {
                            selectedStartMin = newStart;
                            conflictMessage = conflict;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(color: Palette.inputBackground, borderRadius: BorderRadius.circular(12)),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF2962FF), size: 20),
                            const SizedBox(width: 12),
                            Text(_minutesToTime(selectedStartMin), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('체류 시간', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(
                          selectedDuration >= 60
                              ? '${selectedDuration ~/ 60}시간 ${selectedDuration % 60 > 0 ? '${selectedDuration % 60}분' : ''}'
                              : '$selectedDuration분',
                          style: const TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: selectedDuration.toDouble(),
                      min: 15, max: 360, divisions: 23,
                      activeColor: const Color(0xFF2962FF),
                      onChanged: (val) {
                        final newDuration = val.toInt();
                        final conflict = _checkTimeConflict(index, selectedStartMin, newDuration);
                        setModalState(() {
                          selectedDuration = newDuration;
                          conflictMessage = conflict;
                        });
                      },
                    ),

                    if (conflictMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber, color: Colors.red, size: 18),
                            const SizedBox(width: 8),
                            Expanded(child: Text(conflictMessage!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    const Text('설명', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.inputBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: '장소 설명 입력',
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text('운영시간', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: operatingHoursController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Palette.inputBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        hintText: '예: 09:00 - 18:00',
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: conflictMessage != null
                            ? null
                            : () {
                          setState(() {
                            _editableItems[index] = ItineraryDetailItem(
                              detailId: item.detailId,
                              dayNumber: item.dayNumber,
                              startTime: _minutesToTime(selectedStartMin),
                              durationMinutes: selectedDuration,
                              placeName: placeNameController.text,
                              categoryType: item.categoryType,
                              operatingHours: operatingHoursController.text,
                              description: descriptionController.text,
                              sortOrder: item.sortOrder,
                              latitude: item.latitude,
                              longitude: item.longitude,
                            );
                            _editableItems.sort((a, b) {
                              if (a.dayNumber != b.dayNumber) return a.dayNumber.compareTo(b.dayNumber);
                              return _timeToMinutes(a.startTime).compareTo(_timeToMinutes(b.startTime));
                            });
                          });
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2962FF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: const Text('수정 완료', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==================== UI ====================

  @override
  Widget build(BuildContext context) {
    final detailProvider = context.watch<ItineraryDetailProvider>();

    return Scaffold(
      backgroundColor: Palette.background,
      body: detailProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2962FF)))
          : detailProvider.errorMessage != null
          ? _buildErrorState(detailProvider.errorMessage!)
          : detailProvider.detail == null
          ? const Center(child: Text('일정 정보를 불러올 수 없습니다.'))
          : _buildContent(detailProvider.detail!),
      bottomNavigationBar: detailProvider.detail != null
          ? _buildBottomBar(detailProvider.detail!)
          : null,
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Palette.mutedForeground)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.read<ItineraryDetailProvider>().fetchItineraryDetail(widget.itineraryId),
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ItineraryDetailResponse detail) {
    final displayItems = _isEditMode ? _editableItems : detail.details;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                height: 280,
                width: double.infinity,
                color: const Color(0xFF1A237E),
                child: const Center(child: Icon(Icons.location_city, color: Colors.white24, size: 120)),
              ),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withOpacity(0.3), Colors.black.withOpacity(0.7)],
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('AI 생성 일정', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        if (_isEditMode) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10)),
                            child: const Text('수정 중', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(detail.title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text('${detail.startDate} ~ ${detail.endDate}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 16),
                        const Icon(Icons.location_on, color: Colors.white70, size: 14),
                        const SizedBox(width: 6),
                        Text(detail.region, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 50,
                left: 20,
                child: CircleAvatar(
                  backgroundColor: Colors.black26,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Color(0xFF2962FF), size: 20),
                    const SizedBox(width: 8),
                    Text(detail.region, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Text('총 ${displayItems.length}개 코스', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: ['해변', '도시', '해산물', '야경'].map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 12)),
                    backgroundColor: Palette.inputBackground,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              children: [
                const Text('상세 일정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_isEditMode) ...[
                  const Spacer(),
                  const Text('항목을 탭하여 수정하세요', style: TextStyle(color: Colors.orange, fontSize: 12)),
                ],
              ],
            ),
          ),
        ),

        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) {
              final item = displayItems[index];
              final isFirstInDay = index == 0 || displayItems[index - 1].dayNumber != item.dayNumber;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isFirstInDay) _buildDayHeader(item.dayNumber),
                  _buildTimelineTile(item, index == displayItems.length - 1, index),
                ],
              );
            },
            childCount: displayItems.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildDayHeader(int day) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFF2962FF),
            child: Text('$day', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text('Day $day', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const Spacer(),
          const Icon(Icons.keyboard_arrow_up, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(ItineraryDetailItem item, bool isLast, int index) {
    Color bgColor = const Color(0xFFE3F2FD);
    Color iconColor = const Color(0xFF2962FF);
    IconData icon = Icons.location_on;
    String tag = '관광';

    if (item.categoryType.any((t) => t.contains('식당') || t.contains('맛'))) {
      bgColor = const Color(0xFFFFF8F1);
      iconColor = Colors.orange;
      icon = Icons.restaurant;
      tag = '식사';
    } else if (item.categoryType.any((t) => t.contains('이동') || t.contains('역'))) {
      bgColor = const Color(0xFFE8F5E9);
      iconColor = Colors.green;
      icon = Icons.near_me;
      tag = '이동';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Column(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                if (!isLast) Expanded(child: VerticalDivider(color: Colors.grey[300], thickness: 1.5)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: _isEditMode ? () => _showEditDialog(index) : null,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _isEditMode ? Colors.orange.withOpacity(0.5) : Palette.border,
                      width: _isEditMode ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(item.placeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
                                  child: Text(tag, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                                if (_isEditMode) ...[
                                  const Spacer(),
                                  const Icon(Icons.edit, color: Colors.orange, size: 14),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text('${item.durationMinutes}분', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(item.description, style: const TextStyle(color: Colors.black87, fontSize: 13, height: 1.4)),
                          ],
                        ),
                      ),
                      Text(item.startTime, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(ItineraryDetailResponse detail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_isEditMode) ...[
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: _saveEditMode,
                    icon: const Icon(Icons.save, size: 18),
                    label: const Text('저장하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextButton(
                    onPressed: _cancelEditMode,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFFFEBEE),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('취소', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ] else ...[
            // 수정하기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _enterEditMode(detail),
                icon: const Icon(Icons.edit, size: 18),
                label: const Text('일정 수정하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2962FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 가이드에게 제안하기 + 삭제 + 목록
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: ElevatedButton.icon(
                    onPressed: _proposeToGuide,
                    icon: const Icon(Icons.send, size: 16),
                    label: const Text('가이드에게 제안하기', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6600FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _deleteItinerary,
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEE),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: Palette.inputBackground,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text('목록', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}