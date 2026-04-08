// lib/models/data/document_guide_data.dart
//
// ✅ 데이터 출처: 정부24(www.gov.kr) 및 각 민원 서비스 공식 안내 페이지
// ✅ 공신력 있는 데이터 수집 방법: 하단 officialUrl 참조

import 'package:flutter/material.dart';
import '../entities/document_guide.dart';

/// 공신력 있는 준비물 데이터 (정부24, 외교부, 행정안전부 공식 기준)
///
/// === 공신력 있는 정보 출처 ===
/// 1. 정부24(gov.kr) API: https://www.data.go.kr 에서 "정부24 공공서비스" 키워드로 검색
///    → REST API로 민원별 신청 자격·구비서류 정보를 JSON 형태로 제공
/// 2. 정부24 민원백과 크롤: https://www.gov.kr/mw/AA020InfoCappView.do?CappBizCD={업무코드}
///    → 민원업무코드별 구비서류 명세 HTML 파싱 가능
/// 3. 행정안전부 공공데이터포털 (data.go.kr): "민원 구비서류 목록" 검색 → 정형 CSV/XML 데이터 제공

class DocumentGuideData {
  static const List<DocumentGuide> guides = [
    DocumentGuide(
      id: 'passport_issuance',
      title: '여권 발급',
      subtitle: '일반 여권 (복수·단수)',
      category: ComplaintCategory.passport,
      icon: Icons.card_travel_rounded,
      accentColor: Color(0xFF1E5BB1),
      officialUrl: 'https://www.passport.go.kr/home/kor/contents.do?menuPos=36',
      lawReference: '여권법 제9조, 여권법 시행령 제14조',
      requiredDocuments: [
        RequiredDocument(
          name: '여권발급 신청서 1부',
          note: '민원실 현장 작성 또는 정부24 사전 작성',
        ),
        RequiredDocument(
          name: '여권용 사진 1매',
          note: '6개월 이내 촬영, 3.5×4.5cm, 흰 배경',
        ),
        RequiredDocument(
          name: '신분증 (운전면허증/주민등록증)',
        ),
        RequiredDocument(
          name: '기존 여권',
          isRequired: false,
          note: '재발급 시 또는 유효한 여권 소지 시',
        ),
        RequiredDocument(
          name: '병역관계 서류',
          isRequired: false,
          note: '25세~37세 병역미필 남성 해당자',
        ),
      ],
      steps: [
        '신청서 작성 (본인만 가능)',
        '구비서류 검토 및 제출',
        '수수료 납부',
        '여권 수령 (3~5 영업일)',
      ],
      tip: '⏱ 5년 이상된 여권 갱신 시 기존 여권을 꼭 지참하세요. 온라인 사전 신청 후 방문하면 대기 시간이 단축됩니다.',
    ),

    DocumentGuide(
      id: 'resident_registration',
      title: '주민등록등본',
      subtitle: '전입신고 및 주민등록 사실조사',
      category: ComplaintCategory.idCard,
      icon: Icons.article_rounded,
      accentColor: Color(0xFF2D8A4E),
      officialUrl: 'https://www.gov.kr/portal/service/serviceInfo/PTR000051217',
      lawReference: '주민등록법 제29조',
      requiredDocuments: [
        RequiredDocument(
          name: '신분증 (주민등록증/운전면허증)',
        ),
        RequiredDocument(
          name: '주민등록등본 교부 신청서',
          note: '민원실 현장 작성',
        ),
        RequiredDocument(
          name: '위임장',
          isRequired: false,
          note: '대리인 신청 시 필수, 위임인 도장 또는 서명 포함',
        ),
        RequiredDocument(
          name: '대리인 신분증',
          isRequired: false,
          note: '대리 신청 시 필수',
        ),
      ],
      steps: [
        '신청서 작성 (본인 또는 대리인)',
        '신분증 제출 및 본인 확인',
        '발급 수수료 납부 (400원)',
        '즉시 수령',
      ],
      tip: '💡 정부24(gov.kr) 또는 무인민원발급기로 발급 시 24시간 이용 가능하며 무료입니다.',
    ),

    DocumentGuide(
      id: 'resident_card',
      title: '주민등록증 발급',
      subtitle: '신규·재발급 (만 17세 이상)',
      category: ComplaintCategory.idCard,
      icon: Icons.credit_card_rounded,
      accentColor: Color(0xFF6B3FA0),
      officialUrl: 'https://www.gov.kr/portal/service/serviceInfo/PTR000050973',
      lawReference: '주민등록법 제24조',
      requiredDocuments: [
        RequiredDocument(
          name: '주민등록증 발급 신청서',
          note: '민원실 현장 작성 또는 정부24 사전 작성',
        ),
        RequiredDocument(
          name: '주민등록증용 사진 1매',
          note: '6개월 이내 촬영, 3×4cm',
        ),
        RequiredDocument(
          name: '기존 주민등록증',
          isRequired: false,
          note: '재발급 시 반납 필요',
        ),
      ],
      steps: [
        '신청서 작성 및 사진 첨부',
        '지문 날인 (본인)',
        '구비서류 제출',
        '수령 (신청 후 약 2주)',
      ],
      tip: '🔍 분실 신고는 정부24에서 비대면으로 가능하지만, 재발급은 반드시 주소지 읍·면·동 방문 필요.',
    ),

    DocumentGuide(
      id: 'family_relations',
      title: '가족관계증명서',
      subtitle: '가족관계등록부 각종 증명서',
      category: ComplaintCategory.family,
      icon: Icons.family_restroom_rounded,
      accentColor: Color(0xFFE67E22),
      officialUrl: 'https://www.gov.kr/portal/service/serviceInfo/PTR000050945',
      lawReference: '가족관계의 등록 등에 관한 법률 제14조',
      requiredDocuments: [
        RequiredDocument(
          name: '신분증 (주민등록증/운전면허증/여권)',
        ),
        RequiredDocument(
          name: '가족관계증명서 발급 신청서',
          note: '민원실 현장 작성',
        ),
        RequiredDocument(
          name: '위임장 + 위임인 신분증 사본',
          isRequired: false,
          note: '대리인 신청 시',
        ),
      ],
      steps: [
        '발급 유형 선택 (일반/상세/특정)',
        '신청서 작성 및 신분증 제시',
        '수수료 납부 (1부 1,000원)',
        '즉시 수령',
      ],
      tip: '📱 대법원 전자가족관계등록시스템(efamily.scourt.go.kr)에서 무료 무인 발급 가능.',
    ),

    DocumentGuide(
      id: 'vehicle_registration',
      title: '자동차 등록',
      subtitle: '신규·이전·말소 등록',
      category: ComplaintCategory.vehicle,
      icon: Icons.directions_car_rounded,
      accentColor: Color(0xFFE74C3C),
      officialUrl: 'https://www.gov.kr/portal/service/serviceInfo/PTR000051018',
      lawReference: '자동차관리법 제8조',
      requiredDocuments: [
        RequiredDocument(
          name: '자동차 등록 신청서',
        ),
        RequiredDocument(
          name: '자동차 양도증명서 (이전 시)',
          isRequired: false,
          note: '중고차 이전 등록 시 필수',
        ),
        RequiredDocument(
          name: '자동차 매매계약서',
          isRequired: false,
          note: '신규 구매 시',
        ),
        RequiredDocument(
          name: '책임보험 가입증명서',
        ),
        RequiredDocument(
          name: '신분증',
        ),
        RequiredDocument(
          name: '이전 소유자 인감증명서',
          isRequired: false,
          note: '이전 등록 시',
        ),
      ],
      steps: [
        '신청서 및 서류 준비',
        '자동차 등록사업소 방문',
        '취득세·등록세 납부',
        '등록증 수령 (당일 또는 익일)',
      ],
      tip: '🚗 인터넷 자동차 이전 등록(etax.seoul.go.kr)을 이용하면 부분 온라인 처리 가능.',
    ),

    DocumentGuide(
      id: 'welfare_application',
      title: '복지 급여 신청',
      subtitle: '기초생활수급 · 긴급복지 · 차상위',
      category: ComplaintCategory.welfare,
      icon: Icons.volunteer_activism_rounded,
      accentColor: Color(0xFF27AE60),
      officialUrl: 'https://www.bokjiro.go.kr/ssis-tbu/twatsa010/twatsa010/selBenefit.do',
      lawReference: '국민기초생활 보장법 제7조',
      requiredDocuments: [
        RequiredDocument(
          name: '사회보장급여 신청서',
        ),
        RequiredDocument(
          name: '신분증',
        ),
        RequiredDocument(
          name: '금융정보 제공 동의서',
        ),
        RequiredDocument(
          name: '소득 증빙 서류',
          isRequired: false,
          note: '근로소득원천징수영수증, 사업소득확인서 등',
        ),
        RequiredDocument(
          name: '의료 소견서',
          isRequired: false,
          note: '의료급여 신청 시',
        ),
      ],
      steps: [
        '복지로(bokjiro.go.kr) 모의계산으로 수급 가능 여부 확인',
        '읍·면·동 행정복지센터 방문',
        '상담 및 신청',
        '조사 후 결정 (30일 이내)',
      ],
      tip: '📞 복지로 콜센터 129로 미리 궁금한 점을 상담받으면 방문 횟수를 줄일 수 있어요.',
    ),
  ];

  /// 카테고리별 필터링
  static List<DocumentGuide> getByCategory(ComplaintCategory category) {
    return guides.where((g) => g.category == category).toList();
  }

  /// ID로 단일 가이드 조회
  static DocumentGuide? getById(String id) {
    try {
      return guides.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// FAQ 데이터
  static const List<FaqItem> faqs = [
    FaqItem(
      question: '대리인이 신청할 수 있나요?',
      answer: '대부분의 민원은 대리 신청이 가능합니다. 단, 위임장(위임인 서명 또는 도장 포함)과 대리인 본인의 신분증, 그리고 위임인의 신분증 사본을 지참해야 합니다. 여권 발급, 주민등록증 발급은 본인이 직접 방문해야 합니다.',
    ),
    FaqItem(
      question: '준비물 사진 규격이 맞지 않으면 어떻게 되나요?',
      answer: '여권·주민등록증 사진은 엄격한 규격이 적용됩니다. 배경색, 크기, 촬영 기간(6개월 이내) 기준이 맞지 않으면 현장에서 반려될 수 있습니다. 민원실 내부에 즉석사진 코너가 마련된 경우도 있으니 확인 후 방문하세요.',
    ),
    FaqItem(
      question: '수수료는 어떻게 납부하나요?',
      answer: '주민등록등본(400원), 가족관계증명서(1,000원) 등은 현금, 카드 모두 납부 가능합니다. 정부24·무인발급기 이용 시 일부 서류는 무료로 발급됩니다. 취득세 등 세금성 수수료는 카드 납부에 제한이 있을 수 있습니다.',
    ),
    FaqItem(
      question: '접수 후 얼마나 기다려야 하나요?',
      answer: '주민등록등본·가족관계증명서는 즉시 발급됩니다. 여권은 일반 발급 기준 3~5 영업일, 긴급 여권은 1 영업일 이내 가능합니다. 주민등록증은 약 2주 소요됩니다. 복지 급여 신청은 조사 기간을 포함해 30일 이내에 결정 통보됩니다.',
    ),
  ];
}
