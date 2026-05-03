import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:capstone/features/core/network/dio_client.dart';
import 'package:dio/dio.dart';

enum MessageRole { ai, user }

class ChatMessage {
  final String content;
  final MessageRole role;
  final PlanData? planData;

  ChatMessage({
    required this.content,
    required this.role,
    this.planData,
  });
}

class PlanData {
  final String title;
  final String region;
  final String startDate;
  final String endDate;
  final List<PlanCourse> courses;
  final Map<String, dynamic> originalJson;

  PlanData({
    required this.title,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.courses,
    required this.originalJson,
  });
}

class PlanCourse {
  final int dayNumber;
  final String startTime; // "09:00" 형식
  final String endTime;   // startTime + durationMinutes 계산값 (guide_service_info_detail.end_time용)
  final String place;
  final String duration;  // "120분" 형식 (UI 표시용)
  final String description; // AI가 생성한 장소 설명 (guide_service_info_detail.content용)
  final IconData icon;

  PlanCourse({
    required this.dayNumber,
    required this.startTime,
    required this.endTime,
    required this.place,
    required this.duration,
    required this.description,
    required this.icon,
  });
}

// "09:00" + 90분 → "10:30" 계산
String _calcEndTime(String startTime, int durationMinutes) {
  try {
    final parts = startTime.split(':');
    final totalStart = int.parse(parts[0]) * 60 + int.parse(parts[1]);
    final totalEnd = totalStart + durationMinutes;
    final h = (totalEnd ~/ 60) % 24;
    final m = totalEnd % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  } catch (_) {
    return '00:00';
  }
}

class AIPlannerProvider with ChangeNotifier {
  static const String _welcomeMsg =
      '안녕하세요! AI 여행 플래너입니다. 가고 싶은 여행지, 일정, 취향을 자유롭게 말씀해주세요. 최적의 이동경로와 체류 시간을 자동으로 계산해 드릴게요!';

  final List<ChatMessage> _messages = [
    ChatMessage(content: _welcomeMsg, role: MessageRole.ai),
  ];

  List<ChatMessage> get messages => _messages;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void resetChat() {
    _messages.clear();
    _messages.add(ChatMessage(content: _welcomeMsg, role: MessageRole.ai));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text, List<String> categories) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(content: text, role: MessageRole.user));
    notifyListeners();

    _isLoading = true;
    notifyListeners();

    try {
      final response = await DioClient.instance.post(
        '/api/v1/planner/generate',
        data: {
          'prompt': text,
          'categories': categories,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        Map<String, dynamic> decoded =
        responseData is String ? jsonDecode(responseData) : responseData;

        if (decoded['status'] == 'success' && decoded['data'] != null) {
          final data = decoded['data'];
          List rawCourses = data['generated_courses'] ?? [];

          List<PlanCourse> parsedCourses = rawCourses.map((c) {
            // 아이콘 결정
            IconData icon = Icons.location_on;
            String category = (c['category_type'] as List?)?.first ?? '';
            if (category.contains('식당') || category.contains('맛집')) {
              icon = Icons.restaurant;
            } else if (category.contains('숙박') || category.contains('호텔')) {
              icon = Icons.hotel;
            } else if (category.contains('카페')) {
              icon = Icons.local_cafe;
            }

            final String start = c['start_time'] ?? '00:00';
            final int durationMin = c['duration_minutes'] ?? 0;

            return PlanCourse(
              dayNumber: c['day_number'] ?? 1,
              startTime: start,
              endTime: _calcEndTime(start, durationMin), // end_time 자동 계산
              place: c['place'] ?? '장소명 없음',
              duration: '${durationMin}분',
              description: c['description'] ?? '', // AI 설명 → content 필드에 사용
              icon: icon,
            );
          }).toList();

          final planData = PlanData(
            title: data['title'] ?? '생성된 여행 일정입니다.',
            region: data['region'] ?? '',
            startDate: data['start_date'] ?? '',
            endDate: data['end_date'] ?? '',
            courses: parsedCourses,
            originalJson: data,
          );

          _messages.add(ChatMessage(
            content: planData.title,
            role: MessageRole.ai,
            planData: planData,
          ));
        } else {
          _messages.add(ChatMessage(
            content: '죄송합니다. 일정을 생성 중에 오류가 발생했습니다.',
            role: MessageRole.ai,
          ));
        }
      }
    } on DioException catch (e) {
      _messages.add(ChatMessage(content: '에러: ${e.message}', role: MessageRole.ai));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 모드: 상세 플래너 저장
  Future<bool> savePlanner(PlanData data) async {
    try {
      final response = await DioClient.instance.post(
        '/api/v1/planner/save',
        data: {
          'status': 'success',
          'data': data.originalJson,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('❌ 상세 플래너 저장 실패: ${e.response?.statusCode} | ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ 알 수 없는 저장 에러: $e');
      return false;
    }
  }
}