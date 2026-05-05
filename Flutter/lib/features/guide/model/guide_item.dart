class GuideScheduleItem {
  final String startTime;
  final String endTime;
  final String title;
  final String description;

  GuideScheduleItem({
    required this.startTime,
    required this.endTime,
    required this.title,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'title': title,
      'description': description,
    };
  }

  factory GuideScheduleItem.fromMap(Map<String, dynamic> map) {
    return GuideScheduleItem(
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }

  factory GuideScheduleItem.fromJson(Map<String, dynamic> json) =>
      GuideScheduleItem.fromMap(json);
}

class GuideItem {
  final int id;
  final String serviceId;
  final String guideId; // 가이드 유저 ID (채팅/리뷰용)
  final String guideName;
  final String title;
  final String description;
  final String region;
  final double rating;
  final int reviewCount;
  final int price;
  final String durationText;
  final String peopleText;
  final List<String> tags;
  final String imageUrl;
  final bool isVerified;
  final bool isPublished; // 게시 여부
  final bool hasOwnCar;
  final List<String> languages;
  final String meetingPlace;
  final String meetingGuide;
  final List<String> includedItems;
  final List<GuideScheduleItem> schedules;

  GuideItem({
    required this.id,
    required this.serviceId,
    required this.guideId,
    required this.guideName,
    required this.title,
    required this.description,
    required this.region,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.durationText,
    required this.peopleText,
    required this.tags,
    required this.imageUrl,
    required this.isVerified,
    required this.isPublished,
    required this.hasOwnCar,
    required this.languages,
    required this.meetingPlace,
    required this.meetingGuide,
    required this.includedItems,
    required this.schedules,
  });

  factory GuideItem.fromJson(Map<String, dynamic> json) {
    final int durationMinutes = (json['durationMinutes'] as num?)?.toInt() ?? 0;
    String durationText = '';
    if (durationMinutes > 0) {
      final int hours = durationMinutes ~/ 60;
      final int mins = durationMinutes % 60;
      if (hours > 0 && mins > 0) {
        durationText = '$hours시간 $mins분';
      } else if (hours > 0) {
        durationText = '$hours시간';
      } else {
        durationText = '$mins분';
      }
    }

    final int maxCapacity = (json['maxCapacity'] as num?)?.toInt() ?? 0;
    final String peopleText = maxCapacity > 0 ? '0/$maxCapacity명' : '';

    final int price = (json['pricePerPerson'] as num?)?.toInt() ?? 0;

    final String rawServiceId = json['serviceId']?.toString() ?? '';

    return GuideItem(
      id: rawServiceId.hashCode,
      serviceId: rawServiceId,
      guideId: json['guideUserId']?.toString() ?? '',
      guideName: json['guideName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      region: json['region'] ?? '',
      rating: 0.0,
      reviewCount: 0,
      price: price,
      durationText: durationText,
      peopleText: peopleText,
      tags: [],
      imageUrl: '',
      isVerified: true,
      isPublished: json['isPublished'] ?? false,                       // 게시 여부
      hasOwnCar: json['hasCar'] ?? false,
      languages: List<String>.from(json['availableLanguages'] ?? []),
      meetingPlace: json['meetingPoint'] ?? '',
      meetingGuide: json['meetingPointDesc'] ?? '',
      includedItems: List<String>.from(json['includedItems'] ?? []),
      schedules: (json['schedules'] as List?)
          ?.map((e) => GuideScheduleItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }

  GuideItem copyWith({
    int? id,
    String? serviceId,
    String? guideId,
    String? guideName,
    String? title,
    String? description,
    String? region,
    double? rating,
    int? reviewCount,
    int? price,
    String? durationText,
    String? peopleText,
    List<String>? tags,
    String? imageUrl,
    bool? isVerified,
    bool? isPublished,
    bool? hasOwnCar,
    List<String>? languages,
    String? meetingPlace,
    String? meetingGuide,
    List<String>? includedItems,
    List<GuideScheduleItem>? schedules,
  }) {
    return GuideItem(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      guideId: guideId ?? this.guideId,
      guideName: guideName ?? this.guideName,
      title: title ?? this.title,
      description: description ?? this.description,
      region: region ?? this.region,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      price: price ?? this.price,
      durationText: durationText ?? this.durationText,
      peopleText: peopleText ?? this.peopleText,
      tags: tags ?? this.tags,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      isPublished: isPublished ?? this.isPublished,
      hasOwnCar: hasOwnCar ?? this.hasOwnCar,
      languages: languages ?? this.languages,
      meetingPlace: meetingPlace ?? this.meetingPlace,
      meetingGuide: meetingGuide ?? this.meetingGuide,
      includedItems: includedItems ?? this.includedItems,
      schedules: schedules ?? this.schedules,
    );
  }
}