// lib/views/document_guide_detail_screen.dart
//
// 준비물 가이드 상세 화면
// 구조: 헤더 → 준비물 전체 목록 → 절차 스텝 → 공식 URL 링크 버튼

import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
import '../models/entities/document_guide.dart';
import 'widgets/cso_app_bar.dart';

class DocumentGuideDetailScreen extends StatelessWidget {
  final DocumentGuide guide;

  const DocumentGuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F9),
      appBar: CsoAppBar(title: guide.title),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(),
            const SizedBox(height: 16),
            _buildDocumentsList(),
            const SizedBox(height: 16),
            _buildStepsSection(),
            if (guide.tip != null) ...[
              const SizedBox(height: 16),
              _buildTipSection(),
            ],
            if (guide.officialUrl != null) ...[
              const SizedBox(height: 16),
              _buildOfficialLinkSection(context),
            ],
            if (guide.lawReference != null) ...[
              const SizedBox(height: 12),
              _buildLawReferenceSection(),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            guide.accentColor,
            guide.accentColor.withValues(alpha: 0.75),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(guide.icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guide.title,
                  style: AppTextStyles.heading1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  guide.subtitle,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '준비물 ${guide.requiredDocuments.length}종',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    final required = guide.requiredDocuments.where((d) => d.isRequired).toList();
    final conditional = guide.requiredDocuments.where((d) => !d.isRequired).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 필수 서류
          _SectionHeader(icon: Icons.task_alt_rounded, title: '필수 준비물', color: guide.accentColor),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: required.asMap().entries.map((entry) {
                return _DocumentItem(
                  doc: entry.value,
                  isLast: entry.key == required.length - 1,
                  accentColor: guide.accentColor,
                );
              }).toList(),
            ),
          ),

          // 조건부 서류
          if (conditional.isNotEmpty) ...[
            const SizedBox(height: 20),
            const _SectionHeader(
              icon: Icons.info_outline_rounded,
              title: '해당자만 제출',
              color: Color(0xFFA0AEC0),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: conditional.asMap().entries.map((entry) {
                  return _DocumentItem(
                    doc: entry.value,
                    isLast: entry.key == conditional.length - 1,
                    accentColor: const Color(0xFFA0AEC0),
                  );
                }).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.linear_scale_rounded,
            title: '처리 절차',
            color: guide.accentColor,
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: guide.steps.asMap().entries.map((entry) {
                final isLast = entry.key == guide.steps.length - 1;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: guide.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 32,
                            color: guide.accentColor.withValues(alpha: 0.2),
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 4),
                        child: Text(
                          entry.value,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTextStyles.textBlack,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: guide.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: guide.accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, size: 16, color: guide.accentColor),
                const SizedBox(width: 6),
                Text(
                  '알아두면 좋아요',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: guide.accentColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              guide.tip!,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: guide.accentColor.withValues(alpha: 0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfficialLinkSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            icon: Icons.open_in_new_rounded,
            title: '공식 안내 페이지',
            color: guide.accentColor,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              // url_launcher 패키지 사용 필요
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '공식 URL: ${guide.officialUrl}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  action: SnackBarAction(
                    label: '복사',
                    onPressed: () {},
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: guide.accentColor.withValues(alpha: 0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: guide.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.language_rounded, color: guide.accentColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '정부 공식 안내 바로가기',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppTextStyles.textBlack,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide.officialUrl!,
                          style: AppTextStyles.micro.copyWith(
                            color: guide.accentColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: guide.accentColor.withValues(alpha: 0.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLawReferenceSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.gavel_rounded, size: 14, color: AppTextStyles.textLightGray),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '관련 법령: ${guide.lawReference}',
                style: AppTextStyles.micro,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 재사용 위젯 ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _DocumentItem extends StatelessWidget {
  final RequiredDocument doc;
  final bool isLast;
  final Color accentColor;

  const _DocumentItem({
    required this.doc,
    required this.isLast,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: doc.isRequired ? accentColor : const Color(0xFFA0AEC0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 11, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppTextStyles.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (doc.note != null) ...[
                      const SizedBox(height: 3),
                      Text(doc.note!, style: AppTextStyles.micro),
                    ],
                  ],
                ),
              ),
              if (!doc.isRequired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '해당시',
                    style: AppTextStyles.micro.copyWith(color: AppTextStyles.textGray),
                  ),
                ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFFF7F8FA), indent: 50),
      ],
    );
  }
}
