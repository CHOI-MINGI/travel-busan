import 'package:flutter/material.dart';
import '../models/itinerary_detail_model.dart';
import '../../core/network/dio_client.dart';

class ItineraryDetailProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  ItineraryDetailResponse? _detail;
  ItineraryDetailResponse? get detail => _detail;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void updateLocalDetails(List<ItineraryDetailItem> updatedItems) {
    if (_detail == null) return;
    _detail = ItineraryDetailResponse(
      itineraryId: _detail!.itineraryId,
      title: _detail!.title,
      region: _detail!.region,
      startDate: _detail!.startDate,
      endDate: _detail!.endDate,
      details: updatedItems,
    );
    notifyListeners();
  }

  Future<void> fetchItineraryDetail(int itineraryId) async {
    _isLoading = true;
    _errorMessage = null;
    _detail = null;
    notifyListeners();

    try {
      final response = await DioClient.instance.get(
        '/api/v1/planner/itineraries/$itineraryId',
      );

      if (response.statusCode == 200) {
        _detail = ItineraryDetailResponse.fromJson(response.data);
      } else {
        _errorMessage = "해당 일정의 상세 정보를 찾을 수 없습니다.";
      }
    } catch (e) {
      debugPrint('❌ 상세 조회 실패: $e');
      _errorMessage = "해당 일정의 상세 정보를 찾을 수 없습니다.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

    notifyListeners();
  }



