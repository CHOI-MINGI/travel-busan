import 'package:flutter/material.dart';
import '../repository/planner_detail_repository.dart';

class Itinerary {
  final int? itineraryId;
  final String title;
  final String region;
  final String startDate;
  final String endDate;
  final int courseCount;

  Itinerary({
    this.itineraryId,
    required this.title,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.courseCount,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      itineraryId: json['itineraryId'] as int?,
      title: json['title'] ?? '제목 없음',
      region: json['region'] ?? '지역 정보 없음',
      startDate: json['startDate'] ?? '', 
      endDate: json['endDate'] ?? '',
      courseCount: (json['details'] as List?)?.length ?? 0,
    );
  }
}

class PlannerProvider with ChangeNotifier {
  final PlannerRepository _repository = PlannerRepository();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Itinerary> _itineraries = [];
  List<Itinerary> get itineraries => _itineraries;

  Future<void> fetchItineraries() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getItineraries();
      if (response.statusCode == 200) {
        final List<dynamic> dataList = response.data is List
            ? response.data
            : (response.data['data'] ?? []);
        _itineraries = dataList.map((item) => Itinerary.fromJson(item)).toList();
      }
    } catch (e) {
      debugPrint('❌ Error fetching itineraries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
