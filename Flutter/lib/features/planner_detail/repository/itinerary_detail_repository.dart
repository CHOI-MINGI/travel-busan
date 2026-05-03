import 'package:capstone/features/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class ItineraryDetailRepository {
  Future<Response> getItineraryDetail(int itineraryId) async {
    try {
      return await DioClient.instance.get('/api/v1/planner/itineraries/$itineraryId');
    } catch (e) {
      rethrow;
    }
  }
}
