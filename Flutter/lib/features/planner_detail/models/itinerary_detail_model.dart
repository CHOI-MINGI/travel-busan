import 'package:flutter/material.dart';

class ItineraryDetailResponse {
  final int itineraryId;
  final String title;
  final String region;
  final String startDate;
  final String endDate;
  final List<ItineraryDetailItem> details;

  ItineraryDetailResponse({
    required this.itineraryId,
    required this.title,
    required this.region,
    required this.startDate,
    required this.endDate,
    required this.details,
  });

  factory ItineraryDetailResponse.fromJson(Map<String, dynamic> json) {
    return ItineraryDetailResponse(
      itineraryId: json['itineraryId'] ?? 0,
      title: json['title'] ?? '',
      region: json['region'] ?? '',
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      details: (json['details'] as List? ?? [])
          .map((item) => ItineraryDetailItem.fromJson(item))
          .toList(),
    );
  }
}

class ItineraryDetailItem {
  final int detailId;
  final int dayNumber;
  final String startTime;
  final int durationMinutes;
  final String placeName;
  final List<String> categoryType;
  final String operatingHours;
  final String description;
  final int? placeId;
  final int sortOrder;
  final double latitude;
  final double longitude;

  ItineraryDetailItem({
    required this.detailId,
    required this.dayNumber,
    required this.startTime,
    required this.durationMinutes,
    required this.placeName,
    required this.categoryType,
    required this.operatingHours,
    required this.description,
    this.placeId,
    required this.sortOrder,
    required this.latitude,
    required this.longitude,
  });

  factory ItineraryDetailItem.fromJson(Map<String, dynamic> json) {
    return ItineraryDetailItem(
      detailId: json['detailId'] ?? 0,
      dayNumber: json['dayNumber'] ?? 1,
      // LocalTime이 [10, 0] 리스트로 올 경우를 대비한 파싱
      startTime: _parseLocalTime(json['startTime']),
      durationMinutes: json['durationMinutes'] ?? 0,
      placeName: json['placeName'] ?? '장소명 없음',
      categoryType: List<String>.from(json['categoryType'] ?? []),
      operatingHours: json['operatingHours'] ?? '',
      description: json['description'] ?? '',
      placeId: json['placeId'],
      sortOrder: json['sortOrder'] ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static String _parseLocalTime(dynamic time) {
    if (time is String) return time.substring(0, 5); // "10:00:00" -> "10:00"
    if (time is List && time.length >= 2) {
      final h = time[0].toString().padLeft(2, '0');
      final m = time[1].toString().padLeft(2, '0');
      return "$h:$m";
    }
    return "00:00";
  }
}
