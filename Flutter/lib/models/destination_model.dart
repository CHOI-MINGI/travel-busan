class Destination {
  final String id;
  final String name;
  final String location;
  final String imageUrl;
  final double rating;
  final List<String> tags;

  Destination({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.rating,
    required this.tags,
  });
}

// 샘플 데이터의 이미지 URL을 더 안정적인 링크로 교체
final List<Destination> sampleDestinations = [
  Destination(
    id: '1',
    name: '제주도 성산일출봉',
    location: '제주특별자치도',
    imageUrl: 'https://images.unsplash.com/photo-1542296332-2e4473faf563?q=80&w=1000&auto=format&fit=crop',
    rating: 4.8,
    tags: ['자연', '해변', '경치'],
  ),
  Destination(
    id: '2',
    name: '부산 해운대',
    location: '부산광역시',
    imageUrl: 'https://images.unsplash.com/photo-1596403140595-65715f53f938?q=80&w=1000&auto=format&fit=crop',
    rating: 4.7,
    tags: ['바다', '야경', '도시'],
  ),
  Destination(
    id: '3',
    name: '서울 남산타워',
    location: '서울특별시',
    imageUrl: 'https://images.unsplash.com/photo-1538485399081-7191377e8241?q=80&w=1000&auto=format&fit=crop',
    rating: 4.6,
    tags: ['문화', '랜드마크'],
  ),
  Destination(
    id: '4',
    name: '강릉 안목해변',
    location: '강원도',
    imageUrl: 'https://images.unsplash.com/photo-1621609764095-b32bbe35cf3a?q=80&w=1000&auto=format&fit=crop',
    rating: 4.5,
    tags: ['카페거리', '바다'],
  ),
  Destination(
    id: '5',
    name: '전주 한옥마을',
    location: '전라북도',
    imageUrl: 'https://images.unsplash.com/photo-1622325859345-d8869150965e?q=80&w=1000&auto=format&fit=crop',
    rating: 4.4,
    tags: ['전통', '문화시설'],
  ),
];
