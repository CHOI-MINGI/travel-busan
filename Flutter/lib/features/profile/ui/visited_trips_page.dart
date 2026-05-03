import 'package:flutter/material.dart';

class VisitedTripsPage extends StatelessWidget {
  const VisitedTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': '서울 야시장 투어', 'date': '2026.03.10'},
      {'title': '부산 해운대 워킹 코스', 'date': '2026.02.21'},
      {'title': '여수 밤바다 드라이브', 'date': '2026.01.30'},
      {'title': '강릉 카페 & 바다 코스', 'date': '2025.12.18'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('방문한 여행지'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE8F0FF),
                child: Icon(Icons.place_outlined, color: Color(0xFF2563EB)),
              ),
              title: Text(
                item['title']!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text('방문일: ${item['date']}'),
            ),
          );
        },
      ),
    );
  }
}