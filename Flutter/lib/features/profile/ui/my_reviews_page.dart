import 'package:flutter/material.dart';

class MyReviewsPage extends StatelessWidget {
  const MyReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'title': '부산 야경 & 해산물 프리미엄 투어',
        'rating': '5.0',
        'content': '가이드가 정말 친절했고, 야경 포인트 설명도 좋아서 만족스러웠어요.'
      },
      {
        'title': '제주 숨은 맛집 & 자연 투어',
        'rating': '4.5',
        'content': '유명 관광지보다 더 기억에 남는 코스였어요. 현지 느낌이 좋았습니다.'
      },
      {
        'title': '경주 역사 깊이 탐방 투어',
        'rating': '4.8',
        'content': '설명이 쉽고 재밌어서 역사에 관심 없는 사람도 즐길 수 있어요.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('내 리뷰'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final review = reviews[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  review['title']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFFBBF24), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      review['rating']!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  review['content']!,
                  style: const TextStyle(
                    color: Color(0xFF4B5563),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}