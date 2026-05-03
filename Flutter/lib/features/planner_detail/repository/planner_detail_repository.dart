import 'package:capstone/features/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class PlannerRepository {

  // 내 일정 전체 조회
  Future<Response> getItineraries() async {
    try {
      return await DioClient.instance.get('/api/v1/planner/itineraries');
    } catch (e) {
      rethrow;
    }
  }

  // 일정 삭제
  Future<Response> deleteItinerary(int itineraryId) async {
    try {
      return await DioClient.instance.delete('/api/v1/planner/itineraries/$itineraryId');
    } catch (e) {
      rethrow;
    }
  }

  // 역으로 제안하기 (가이드에게 일정 제안)
  Future<Response> createUserBid(int itineraryId) async {
    try {
      return await DioClient.instance.post(
        '/api/v1/user-bids',
        data: {'itineraryId': itineraryId},
      );
    } catch (e) {
      rethrow;
    }
  }
}