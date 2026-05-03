//가이드 상품 생성 페이지
import 'package:flutter/material.dart';
import 'package:capstone/config/palette.dart';
import '../model/guide_item.dart';
import '../repository/guide_repository.dart';
import 'guide_register_page.dart';

class GuideProductPage extends StatefulWidget {
  const GuideProductPage({super.key});

  @override
  State<GuideProductPage> createState() => _GuideProductPageState();
}

class _GuideProductPageState extends State<GuideProductPage> {
  final GuideRepository _repository = GuideRepository();
  List<GuideItem> _myProducts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMyProducts();
  }

  Future<void> _fetchMyProducts() async {
    setState(() => _isLoading = true);
    try {
      final response = await _repository.getMyProducts();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        setState(() {
          _myProducts = data
              .map((e) => GuideItem.fromJson(e as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('목록 로드 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _togglePublish(GuideItem item) async {
    try {
      final response = await _repository.togglePublish(item.serviceId);
      if (response.statusCode == 200) {
        final updated = GuideItem.fromJson(response.data as Map<String, dynamic>);
        setState(() {
          final idx = _myProducts.indexWhere((e) => e.serviceId == item.serviceId);
          if (idx != -1) _myProducts[idx] = updated;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(updated.isPublished ? '게시되었습니다.' : '게시가 취소되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('게시 변경 실패: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(GuideItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('상품 삭제'),
        content: Text('\'${item.title}\'을(를) 삭제하시겠습니까?'),
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
      final response = await _repository.deleteGuideProduct(item.serviceId);
      if (response.statusCode == 204) {
        setState(() => _myProducts.removeWhere((e) => e.serviceId == item.serviceId));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('삭제되었습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('삭제 실패: $e')),
        );
      }
    }
  }

  void _goToRegisterPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GuideRegisterPage()),
    );
    _fetchMyProducts();
  }

  void _goToEditPage(GuideItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GuideRegisterPage(editItem: item)),
    );
    _fetchMyProducts();
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
          '상품 관리',
          style: TextStyle(color: Palette.foreground, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: _goToRegisterPage,
            icon: const Icon(Icons.add, size: 18, color: Color(0xFF0055FF)),
            label: const Text('새 상품 등록', style: TextStyle(color: Color(0xFF0055FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myProducts.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _fetchMyProducts,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _myProducts.length,
          itemBuilder: (context, index) => _buildProductCard(_myProducts[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('등록된 상품이 없습니다.', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goToRegisterPage,
            icon: const Icon(Icons.add),
            label: const Text('첫 상품 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0055FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(GuideItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Palette.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 제목 + 게시 상태
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Palette.foreground)),
                      const SizedBox(height: 4),
                      Text(item.region, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isPublished ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item.isPublished ? '게시중' : '미게시',
                    style: TextStyle(
                      color: item.isPublished ? const Color(0xFF2E7D32) : Colors.grey[500],
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 상품 정보
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _infoChip(Icons.attach_money, '${item.price}원'),
                const SizedBox(width: 8),
                _infoChip(Icons.access_time, item.durationText),
                const SizedBox(width: 8),
                _infoChip(Icons.people_outline, item.peopleText),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),

          // 버튼: 게시/게시취소, 수정, 삭제
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // 게시 / 게시취소
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () => _togglePublish(item),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.isPublished ? const Color(0xFFFFF3E0) : const Color(0xFF0055FF),
                      foregroundColor: item.isPublished ? const Color(0xFFE65100) : Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      item.isPublished ? '게시 취소' : '게시하기',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 수정
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _goToEditPage(item),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0055FF),
                      side: const BorderSide(color: Color(0xFF0055FF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('수정', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 8),
                // 삭제
                OutlinedButton(
                  onPressed: () => _deleteProduct(item),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  child: const Text('삭제', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}