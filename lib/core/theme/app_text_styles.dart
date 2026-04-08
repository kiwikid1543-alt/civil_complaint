import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 전체에서 사용할 표준 텍스트 스타일 정의 (디자인 시스템)
class AppTextStyles {
  // 기본 색상 정의 (추후 AppColors로 분리 가능)
  static const Color primaryBlue = Color(0xFF072C7A);
  static const Color textBlack = Color(0xFF1A202C);
  static const Color textGray = Color(0xFF4A5568);
  static const Color textLightGray = Color(0xFFA0AEC0);

  /// AppBar 전용 타이틀 스타일 (18px, Bold)
  static TextStyle appBarTitle = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: -0.5,
  );

  /// 초대형 강조 (민원실 명칭 등, 28px, Black)
  static TextStyle display1 = GoogleFonts.notoSans(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textBlack,
    letterSpacing: -1.0,
  );

  /// 초대형 숫자 강조 (84px, Bold)
  static TextStyle giant = GoogleFonts.notoSans(
    fontSize: 84,
    fontWeight: FontWeight.w800,
    color: primaryBlue,
    letterSpacing: -2.0,
  );

  /// 섹션 대 타이틀 (대기 인원 숫자 등, 22px, Bold)
  static TextStyle heading1 = GoogleFonts.notoSans(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: textBlack,
  );

  /// 섹션 타이틀 / 탭 메뉴 (18px, Bold)
  static TextStyle heading2 = GoogleFonts.notoSans(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: textBlack,
  );

  /// 리스트 항목 제목 (16px, SemiBold)
  static TextStyle bodyLarge = GoogleFonts.notoSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textBlack,
  );

  /// 일반 본문 / 주소 (14px, Medium)
  static TextStyle bodyMedium = GoogleFonts.notoSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textGray,
  );

  /// 부가 정보 / 거리 표시 (13px, Bold/Regular)
  static TextStyle bodySmall = GoogleFonts.notoSans(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textGray,
  );

  /// 캡션 / 팁 / 레전드 (12px, Regular)
  static TextStyle caption = GoogleFonts.notoSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textLightGray,
  );
  
  /// 아주 작은 정보 (11px, Regular)
  static TextStyle micro = GoogleFonts.notoSans(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textLightGray,
  );
}
