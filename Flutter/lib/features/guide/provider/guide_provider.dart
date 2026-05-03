import 'package:flutter/material.dart';
import '../model/guide_item.dart';
import '../repository/guide_repository.dart';

class GuideProvider extends ChangeNotifier {
  final GuideRepository _repository = GuideRepository();

  List<GuideItem> _guides = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedRegion = '전체';
  String _searchKeyword = '';
  String _sortType = '추천순';

  List<GuideItem> get guides => List.unmodifiable(_guides);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedRegion => _selectedRegion;
  String get searchKeyword => _searchKeyword;
  String get sortType => _sortType;

  List<String> get regionOptions => ['전체', '제주도', '부산', '서울', '경주', '강릉', '여수'];
  List<String> get sortOptions => ['추천순', '평점순', '가격낮은순'];

  List<GuideItem> get filteredGuides {
    List<GuideItem> result = _guides.where((item) {
      final regionMatched =
          _selectedRegion == '전체' || item.region == _selectedRegion;

      final keyword = _searchKeyword.trim().toLowerCase();
      final keywordMatched = keyword.isEmpty ||
          item.guideName.toLowerCase().contains(keyword) ||
          item.title.toLowerCase().contains(keyword) ||
          item.region.toLowerCase().contains(keyword) ||
          item.description.toLowerCase().contains(keyword);

      return regionMatched && keywordMatched;
    }).toList();

    if (_sortType == '평점순') {
      result.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sortType == '가격낮은순') {
      result.sort((a, b) => a.price.compareTo(b.price));
    } else {
      result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
    }

    return result;
  }

  // 사용자 가이드 탐색 — 게시된 상품만 (GET /guide/products)
  Future<void> fetchGuides() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.getGuideProducts();
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        _guides = dataList
            .map((e) => GuideItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      _errorMessage = '가이드 목록을 불러오지 못했습니다.';
      debugPrint('❌ Error fetching guides: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  void updateSearchKeyword(String keyword) {
    _searchKeyword = keyword;
    notifyListeners();
  }

  void updateSortType(String sortType) {
    _sortType = sortType;
    notifyListeners();
  }
}