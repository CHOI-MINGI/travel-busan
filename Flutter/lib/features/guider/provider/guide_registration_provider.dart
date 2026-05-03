import 'package:flutter/material.dart';
import '../models/guider_model.dart';
import '../repository/guider_repository.dart';

enum RegistrationStatus { initial, loading, success, error }

class GuideRegistrationProvider with ChangeNotifier {
  final GuiderRepository _repository = GuiderRepository();

  RegistrationStatus _status = RegistrationStatus.initial;
  RegistrationStatus get status => _status;

  // Step 1: Regions
  final List<String> _selectedRegions = [];
  List<String> get selectedRegions => _selectedRegions;

  // Step 2: Language & Experience
  final List<String> _selectedLanguages = [];
  List<String> get selectedLanguages => _selectedLanguages;
  String _experience = '';
  String get experience => _experience;
  final List<LanguageScoreDto> _languageScores = [];
  List<LanguageScoreDto> get languageScores => _languageScores;

  // Step 3: Intro & Specialties
  String _introduction = '';
  String get introduction => _introduction;
  final List<String> _selectedSpecialties = [];
  List<String> get selectedSpecialties => _selectedSpecialties;

  // Validations
  bool get isStep1Valid => _selectedRegions.isNotEmpty;
  bool get isStep2Valid => _selectedLanguages.isNotEmpty && _experience.isNotEmpty;
  bool get isStep3Valid => _introduction.isNotEmpty && _selectedSpecialties.isNotEmpty;

  void toggleRegion(String region) {
    if (_selectedRegions.contains(region)) {
      _selectedRegions.remove(region);
    } else {
      _selectedRegions.add(region);
    }
    notifyListeners();
  }

  void toggleLanguage(String lang) {
    if (_selectedLanguages.contains(lang)) {
      _selectedLanguages.remove(lang);
    } else {
      _selectedLanguages.add(lang);
    }
    notifyListeners();
  }

  void setExperience(String exp) {
    _experience = exp;
    notifyListeners();
  }

  void addLanguageScore() {
    _languageScores.add(LanguageScoreDto(exam: '', score: ''));
    notifyListeners();
  }

  void removeLanguageScore(int index) {
    _languageScores.removeAt(index);
    notifyListeners();
  }

  void updateIntroduction(String intro) {
    _introduction = intro;
    notifyListeners();
  }

  void toggleSpecialty(String spec) {
    if (_selectedSpecialties.contains(spec)) {
      _selectedSpecialties.remove(spec);
    } else {
      _selectedSpecialties.add(spec);
    }
    notifyListeners();
  }

  // [수정] userId 타입을 String(UUID)으로 변경
  Future<bool> registerGuider(String userId) async {
    _status = RegistrationStatus.loading;
    notifyListeners();

    try {
      final request = GuiderRegisterRequest(
        activeRegions: _selectedRegions,
        availableLanguages: _selectedLanguages,
        experiencePeriod: _experience,
        languageScores: _languageScores,
        introduction: _introduction,
        specialties: _selectedSpecialties,
      );

      final response = await _repository.registerGuider(userId, request);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        _status = RegistrationStatus.success;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _status = RegistrationStatus.error;
      notifyListeners();
      return false;
    }
  }
}
