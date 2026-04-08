// lib/views/document_guide_screen.dart
//
// 준비물 가이드 메인 화면
// 디자인 기준: 제공된 UI 이미지 + 앱 기존 테마 (primaryBlue, Noto Sans)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_text_styles.dart';
import '../models/data/document_guide_data.dart';
import '../models/entities/document_guide.dart';
import 'document_guide_detail_screen.dart';

class DocumentGuideScreen extends StatefulWidget {
  const DocumentGuideScreen({super.key});

  @override
  State<DocumentGuideScreen> createState() => _DocumentGuideScreenState();
}

class _DocumentGuideScreenState extends State<DocumentGuideScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DocumentGuide> get _filteredGuides {
    if (_searchQuery.isEmpty) return DocumentGuideData.guides;
    final q = _searchQuery.toLowerCase();
    return DocumentGuideData.guides
        .where(
          (g) =>
              g.title.toLowerCase().contains(q) ||
              g.subtitle.toLowerCase().contains(q) ||
              g.requiredDocuments.any((d) => d.name.toLowerCase().contains(q)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6F9),
        body: Column(
          children: [
            _buildTopSection(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 준비물 카드 리스트 ──────────────────────────────────
                    ..._buildGuideCards(),

                    // ── FAQ 섹션 ────────────────────────────────────────────
                    _buildFaqSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 상단 앱바 + 검색 통합 섹션 ─────────────────────────────────────────────
  Widget _buildTopSection() {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPadding),
          // 앱바 행
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                const Opacity(
                  opacity: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: null,
                  ),
                ),

                Expanded(
                  child: Text(
                    '준비물 가이드',
                    style: AppTextStyles.appBarTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                // 타이틀을 가운데로 맞추기 위한 대칭용 투명 더미 버튼
                const Opacity(
                  opacity: 0,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: null,
                  ),
                ),
              ],
            ),
          ),

          // 검색바
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTextStyles.textBlack,
                ),
                decoration: InputDecoration(
                  hintText: '민원 서비스를 검색하세요',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppTextStyles.textLightGray,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppTextStyles.textLightGray,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: AppTextStyles.textLightGray,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 준비물 카드 리스트 ────────────────────────────────────────────────────
  List<Widget> _buildGuideCards() {
    final guides = _filteredGuides;
    if (guides.isEmpty) {
      return [
        SizedBox(
          height: 200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_rounded,
                  size: 48,
                  color: AppTextStyles.textLightGray,
                ),
                const SizedBox(height: 12),
                Text('검색 결과가 없습니다', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ];
    }
    return guides
        .map(
          (guide) => _GuideCard(
            guide: guide,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DocumentGuideDetailScreen(guide: guide),
              ),
            ),
          ),
        )
        .toList();
  }

  // ── FAQ 섹션 ──────────────────────────────────────────────────────────────
  Widget _buildFaqSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text('자주 묻는 질문', style: AppTextStyles.heading2),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: DocumentGuideData.faqs.asMap().entries.map((e) {
                return _FaqTile(
                  faq: e.value,
                  isLast: e.key == DocumentGuideData.faqs.length - 1,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 준비물 가이드 카드 ────────────────────────────────────────────────────────

class _GuideCard extends StatelessWidget {
  final DocumentGuide guide;
  final VoidCallback onTap;

  const _GuideCard({required this.guide, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final required = guide.requiredDocuments
        .where((d) => d.isRequired)
        .toList();
    final optional = guide.requiredDocuments
        .where((d) => !d.isRequired)
        .toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── 카드 헤더 ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                child: Row(
                  children: [
                    // 아이콘 컨테이너
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: guide.accentColor.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        guide.icon,
                        color: guide.accentColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            guide.title,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppTextStyles.textBlack,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            guide.subtitle,
                            style: AppTextStyles.caption.copyWith(
                              color: AppTextStyles.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFFCBD5E0),
                      size: 20,
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF2F5F9)),

              // ── 필수 서류 목록 ────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      size: 13,
                      color: AppTextStyles.textLightGray,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '필수 서류',
                      style: AppTextStyles.micro.copyWith(
                        color: AppTextStyles.textGray,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...required
                        .take(3)
                        .map(
                          (doc) =>
                              _DocRow(doc: doc, accentColor: guide.accentColor),
                        ),
                    if (optional.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Color(0xFFEDF2F7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 10,
                                color: AppTextStyles.textLightGray,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '해당 시 ${optional.length}종 추가 필요',
                              style: AppTextStyles.micro.copyWith(
                                color: AppTextStyles.textLightGray,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ── 팁 배너 ──────────────────────────────────────────────────
              if (guide.tip != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: guide.accentColor.withValues(alpha: 0.06),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(14),
                    ),
                  ),
                  child: Text(
                    guide.tip!,
                    style: AppTextStyles.micro.copyWith(
                      color: guide.accentColor,
                      fontWeight: FontWeight.w600,
                      height: 1.6,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 서류 한 줄 항목 (체크 O + 이름) ──────────────────────────────────────────

class _DocRow extends StatelessWidget {
  final RequiredDocument doc;
  final Color accentColor;

  const _DocRow({required this.doc, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 10, color: Colors.white),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              doc.name,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTextStyles.textBlack,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── FAQ 타일 ──────────────────────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final FaqItem faq;
  final bool isLast;

  const _FaqTile({required this.faq, required this.isLast});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    widget.faq.question,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppTextStyles.textBlack,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppTextStyles.textLightGray,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          child: _expanded
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 15),
                  child: Text(
                    widget.faq.answer,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.7,
                      color: AppTextStyles.textGray,
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        if (!widget.isLast)
          const Divider(
            height: 1,
            color: Color(0xFFF2F5F9),
            indent: 18,
            endIndent: 18,
          ),
      ],
    );
  }
}
