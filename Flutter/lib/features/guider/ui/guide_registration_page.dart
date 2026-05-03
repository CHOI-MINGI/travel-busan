import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone/config/palette.dart';
import '../provider/guide_registration_provider.dart';
import '../models/guider_model.dart';
import '../../auth/provider/auth_provider.dart';
import 'registration_result_page.dart';

class GuideRegistrationPage extends StatefulWidget {
  const GuideRegistrationPage({super.key});

  @override
  State<GuideRegistrationPage> createState() => _GuideRegistrationPageState();
}

class _GuideRegistrationPageState extends State<GuideRegistrationPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(GuideRegistrationProvider provider) {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      // [수정] AuthProvider에서 실제 userId(UUID) 가져오기
      final authProvider = context.read<AuthProvider>();
      final String? userId = authProvider.userId;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 정보가 없습니다.')));
        return;
      }

      provider.registerGuider(userId).then((success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RegistrationResultPage(
              isSuccess: success,
              message: success ? '' : '서버 오류로 인해 등록에 실패했습니다.',
            ),
          ),
        );
      });
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GuideRegistrationProvider>();

    return Scaffold(
      backgroundColor: Palette.background,
      appBar: AppBar(
        backgroundColor: Palette.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Palette.foreground),
          onPressed: _handleBack,
        ),
        title: const Text(
          '로컬 가이드 등록',
          style: TextStyle(color: Palette.foreground, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              _buildStepIndicator(provider),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildAnimatedStep(0, _buildStep1(provider)),
                    _buildAnimatedStep(1, _buildStep2(provider)),
                    _buildAnimatedStep(2, _buildStep3(provider)),
                  ],
                ),
              ),
              _buildBottomButton(provider),
            ],
          ),
          // 등록 중 로딩 오버레이
          if (provider.status == RegistrationStatus.loading)
            _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              '로컬 가이더로 등록 중입니다..',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedStep(int stepIndex, Widget child) {
    return AnimatedOpacity(
      opacity: _currentStep == stepIndex ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: child,
    );
  }

  Widget _buildStepIndicator(GuideRegistrationProvider provider) {
    final steps = [
      {'label': '활동 지역', 'isValid': provider.isStep1Valid, 'icon': Icons.map_outlined},
      {'label': '언어 & 경력', 'isValid': provider.isStep2Valid, 'icon': Icons.translate},
      {'label': '소개 & 등록', 'isValid': provider.isStep3Valid, 'icon': Icons.assignment_outlined},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Colors.grey[200],
              ),
            );
          }

          final stepIdx = index ~/ 2;
          final step = steps[stepIdx];
          final isActive = _currentStep == stepIdx;
          final isValid = step['isValid'] as bool;

          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isValid ? const Color(0xFF00C853) : (isActive ? Colors.redAccent : Colors.grey[100]),
                  shape: BoxShape.circle,
                  boxShadow: isActive ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, spreadRadius: 2)] : [],
                ),
                child: Icon(
                  step['icon'] as IconData,
                  size: 20,
                  color: isValid || isActive ? Colors.white : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                step['label'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Palette.foreground : Colors.grey,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStep1(GuideRegistrationProvider provider) {
    final regions = ['제주도', '부산', '서울', '경주', '강릉', '여수', '전주', '속초', '통영', '담양'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('활동 지역', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('가이드로 활동할 수 있는 지역을 선택하세요.', style: TextStyle(color: Palette.mutedForeground)),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.network(
              'https://images.unsplash.com/photo-1538485399081-7191377e8241?q=80&w=1000&auto=format&fit=crop',
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: regions.map((r) {
              final isSelected = provider.selectedRegions.contains(r);
              return FilterChip(
                label: Text(r),
                selected: isSelected,
                onSelected: (_) => provider.toggleRegion(r),
                selectedColor: const Color(0xFF00C853),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (provider.selectedRegions.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1FDF5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택된 활동 지역', style: TextStyle(color: Color(0xFF00C853), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: provider.selectedRegions.map((r) => Chip(
                      label: Text(r, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => provider.toggleRegion(r),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00C853))),
                    )).toList(),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStep2(GuideRegistrationProvider provider) {
    final languages = ['한국어', 'English', '日本語', '中文', 'Español', 'Français'];
    final experiences = ['신입 (경력 없음)', '1~2년', '3~5년', '5년 이상', '10년 이상'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('언어 & 경력', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('소통 가능한 언어와 가이드 경력을 알려주세요.', style: TextStyle(color: Palette.mutedForeground)),
          const SizedBox(height: 32),
          const Text('소통 가능 언어', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: languages.map((l) {
              final isSelected = provider.selectedLanguages.contains(l);
              return FilterChip(
                label: Text(l),
                selected: isSelected,
                onSelected: (_) => provider.toggleLanguage(l),
                selectedColor: const Color(0xFF2962FF),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          const Text('가이드 경력', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            children: experiences.map((e) {
              final isSelected = provider.experience == e;
              return ChoiceChip(
                label: Text(e),
                selected: isSelected,
                onSelected: (_) => provider.setExperience(e),
                selectedColor: const Color(0xFF2962FF),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('어학 성적 (선택사항)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              TextButton.icon(
                onPressed: () => provider.addLanguageScore(),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('추가'),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2962FF)),
              ),
            ],
          ),
          ...provider.languageScores.asMap().entries.map((entry) {
            int idx = entry.key;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Palette.inputBackground.withOpacity(0.5), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('어학 성적 ${idx + 1}', style: const TextStyle(fontSize: 12, color: Palette.mutedForeground, fontWeight: FontWeight.bold)),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent), onPressed: () => provider.removeLanguageScore(idx)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '시험명 (TOEIC 등)',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => provider.languageScores[idx].exam = val,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: '점수',
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          ),
                          onChanged: (val) => provider.languageScores[idx].score = val,
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStep3(GuideRegistrationProvider provider) {
    final specialties = ['맛집 투어', '역사 해설', '자연 탐방', '사진 촬영', '야경 투어', '문화 체험', '트레킹', '로컬 마켓', '카페 투어', '해변 액티비티'];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('소개 & 전문분야', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('여행자들에게 자신을 멋지게 소개해보세요.', style: TextStyle(color: Palette.mutedForeground)),
          const SizedBox(height: 32),
          const Text('자기소개', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            maxLines: 6,
            maxLength: 500,
            onChanged: (val) => provider.updateIntroduction(val),
            decoration: InputDecoration(
              hintText: '당신은 어떤 가이드인가요? 경험과 특별한 투어 코스를 알려주세요.',
              filled: true,
              fillColor: Palette.inputBackground.withOpacity(0.5),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 32),
          const Text('전문 분야 (복수 선택)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specialties.map((s) {
              final isSelected = provider.selectedSpecialties.contains(s);
              return FilterChip(
                label: Text(s),
                selected: isSelected,
                onSelected: (_) => provider.toggleSpecialty(s),
                selectedColor: const Color(0xFF2962FF),
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          if (provider.selectedSpecialties.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('선택된 전문 분야', style: TextStyle(color: Color(0xFF2962FF), fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: provider.selectedSpecialties.map((s) => Chip(
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      onDeleted: () => provider.toggleSpecialty(s),
                      backgroundColor: Colors.white,
                      deleteIcon: const Icon(Icons.close, size: 14, color: Colors.grey),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF2962FF))),
                    )).toList(),
                  )
                ],
              ),
            )
        ],
      ),
    );
  }

  Widget _buildBottomButton(GuideRegistrationProvider provider) {
    bool isValid = false;
    if (_currentStep == 0) isValid = provider.isStep1Valid;
    else if (_currentStep == 1) isValid = provider.isStep2Valid;
    else isValid = provider.isStep3Valid;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Palette.border, width: 0.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 58,
        child: ElevatedButton(
          onPressed: isValid ? () => _nextStep(provider) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey[200],
            disabledForegroundColor: Colors.grey[400],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 0,
          ),
          child: Text(
            _currentStep == 2 ? '가이드 등록 완료' : '다음 단계',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
