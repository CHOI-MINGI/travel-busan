import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 설정 및 공통 UI
import 'package:capstone/config/palette.dart';
import 'package:capstone/features/auth/ui/splash_page.dart';

// Providers
import 'package:capstone/features/ai/ai_planner_provider.dart';
import 'package:capstone/features/auth/provider/auth_provider.dart';
import 'package:capstone/features/guide/provider/guide_provider.dart';
import 'package:capstone/features/planner_detail/provider/planner_detail_provider.dart';
import 'package:capstone/features/planner_detail/provider/itinerary_detail_provider.dart';
import 'package:capstone/features/guider/provider/guide_registration_provider.dart';

//가이드 전환 용


void main() {
  // Flutter 엔진 초기화 보장
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AIPlannerProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => PlannerProvider()),
        ChangeNotifierProvider(create: (_) => ItineraryDetailProvider()),
        ChangeNotifierProvider(create: (_) => GuideRegistrationProvider()),
      ],
      child: const TravelPlannerApp(),
    ),
  );
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TravelBusan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Palette.primary,
          primary: Palette.primary,
          surface: Palette.background,
        ),
        scaffoldBackgroundColor: Palette.background,
        fontFamily: 'Pretendard',
      ),
      home: const SplashPage(),
    );
  }
}
