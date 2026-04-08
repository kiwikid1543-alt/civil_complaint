// lib/models/entities/document_guide.dart

import 'package:flutter/material.dart';

/// 준비물이 필요한 민원 유형 (민원 서비스 분류)
enum ComplaintCategory {
  passport('여권 · 출입국', Icons.card_travel_rounded),
  idCard('신분증 · 등록', Icons.credit_card_rounded),
  family('가족관계 · 호적', Icons.family_restroom_rounded),
  property('부동산 · 건축', Icons.home_work_rounded),
  vehicle('자동차 · 운전', Icons.directions_car_rounded),
  welfare('복지 · 지원금', Icons.volunteer_activism_rounded),
  business('사업 · 인허가', Icons.store_rounded),
  tax('세금 · 고지서', Icons.receipt_long_rounded);

  const ComplaintCategory(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// 하나의 준비물 민원 유형 데이터 모델
@immutable
class DocumentGuide {
  final String id;
  final String title;
  final String subtitle;
  final ComplaintCategory category;
  final IconData icon;
  final Color accentColor;
  final List<RequiredDocument> requiredDocuments;
  final List<String> steps;
  final String? tip;
  final String? officialUrl; // 공공기관 공식 안내 URL
  final String? lawReference; // 관련 법령 참조

  const DocumentGuide({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.accentColor,
    required this.requiredDocuments,
    required this.steps,
    this.tip,
    this.officialUrl,
    this.lawReference,
  });
}

/// 개별 준비물 항목
@immutable
class RequiredDocument {
  final String name;
  final bool isRequired; // true: 필수, false: 해당시 제출
  final String? note; // 추가 설명

  const RequiredDocument({
    required this.name,
    this.isRequired = true,
    this.note,
  });
}

/// FAQ 항목
@immutable
class FaqItem {
  final String question;
  final String answer;

  const FaqItem({required this.question, required this.answer});
}
