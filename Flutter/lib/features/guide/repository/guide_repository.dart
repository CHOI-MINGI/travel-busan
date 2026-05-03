import 'package:capstone/features/core/network/dio_client.dart';
import 'package:dio/dio.dart';

class GuideRepository {

  // ==================== 사용자용 ====================

  // 게시된 상품 전체 (사용자 가이드 탐색 화면)
  Future<Response> getGuideProducts() async {
    try {
      return await DioClient.instance.get('/api/v1/guide/products');
    } catch (e) {
      rethrow;
    }
  }

  // ==================== 가이드용 ====================

  // 내 상품 전체 (미게시 포함, 상품 관리 화면)
  Future<Response> getMyProducts() async {
    try {
      return await DioClient.instance.get('/api/v1/guide/my-products');
    } catch (e) {
      rethrow;
    }
  }

  // 내 게시된 상품 (포트폴리오 화면)
  Future<Response> getMyPublishedProducts() async {
    try {
      return await DioClient.instance.get('/api/v1/guide/my-products/published');
    } catch (e) {
      rethrow;
    }
  }

  // 상품 등록
  Future<Response> createGuideProduct(Map<String, dynamic> body) async {
    try {
      return await DioClient.instance.post('/api/v1/guide/products', data: body);
    } catch (e) {
      rethrow;
    }
  }

  // 상품 수정
  Future<Response> updateGuideProduct(String serviceId, Map<String, dynamic> body) async {
    try {
      return await DioClient.instance.put('/api/v1/guide/products/$serviceId', data: body);
    } catch (e) {
      rethrow;
    }
  }

  // 상품 삭제
  Future<Response> deleteGuideProduct(String serviceId) async {
    try {
      return await DioClient.instance.delete('/api/v1/guide/products/$serviceId');
    } catch (e) {
      rethrow;
    }
  }

  // 게시 / 게시취소 토글
  Future<Response> togglePublish(String serviceId) async {
    try {
      return await DioClient.instance.patch('/api/v1/guide/products/$serviceId/publish');
    } catch (e) {
      rethrow;
    }
  }
}