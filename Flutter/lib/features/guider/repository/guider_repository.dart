import 'package:capstone/features/core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/guider_model.dart';

class GuiderRepository {
  // [수정] userId 타입을 String(UUID)으로 변경
  Future<Response> registerGuider(String userId, GuiderRegisterRequest requestData) async {
    try {
      return await DioClient.instance.post(
        '/api/v1/guider/$userId/register',
        data: requestData.toJson(),
      );
    } catch (e) {
      rethrow;
    }
  }
}
