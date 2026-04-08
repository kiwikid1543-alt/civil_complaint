import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/cso_detail_screen.dart';
import 'views/cso_list_screen.dart';
import 'views/cso_map_screen.dart';
import 'views/document_guide_screen.dart';
import 'core/theme/app_text_styles.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/congestion_logger_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  // Firebase 연동 완료에 따른 주석 해제 구문
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    /// 첫 화면: 내 주변 관공서 목록
    GoRoute(
      path: '/',
      builder: (context, state) => const CsoListScreen(),
    ),

    /// 지도 화면
    GoRoute(
      path: '/map',
      builder: (context, state) => const CsoMapScreen(),
    ),

    /// 관공서 상세 화면: csoSn을 URL 파라미터로 받음
    GoRoute(
      path: '/detail/:csoSn',
      builder: (context, state) {
        final csoSn = state.pathParameters['csoSn'] ?? '';
        final csoNm = state.uri.queryParameters['csoNm'] ?? '민원실';
        return CsoDetailScreen(csoSn: csoSn, csoNm: csoNm);
      },
    ),

    /// 준비물 가이드 화면
    GoRoute(
      path: '/guide',
      builder: (context, state) => const DocumentGuideScreen(),
    ),
  ],
);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    // 데이터 수집기 시작
    ref.read(congestionLoggerProvider).startLogging();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Civil Complaint Room',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFBFDFF),
        textTheme: GoogleFonts.notoSansTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTextStyles.primaryBlue,
          primary: AppTextStyles.primaryBlue,
        ),
      ),
    );
  }
}
