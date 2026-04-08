import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../notifier/cso_detail_notifier.dart';
import 'widgets/cso_app_bar.dart';
import 'widgets/cso_header_section.dart';
import 'widgets/cso_waiting_card.dart';
import 'widgets/cso_task_accordion.dart';
import 'widgets/cso_congestion_tab.dart';

import '../core/theme/app_text_styles.dart';

/// 민원실 상세 정보 메인 화면
class CsoDetailScreen extends ConsumerStatefulWidget {
  final String csoSn;
  final String csoNm;

  const CsoDetailScreen({super.key, required this.csoSn, this.csoNm = '민원실'});

  @override
  ConsumerState<CsoDetailScreen> createState() => _CsoDetailScreenState();
}

class _CsoDetailScreenState extends ConsumerState<CsoDetailScreen> {
  int _selectedTab = 0; // 0: 대기 현황, 1: 혼잡도

  @override
  Widget build(BuildContext context) {
    final csoStatusAsync = ref.watch(csoDetailProvider(widget.csoSn));

    // 데이터 로딩 전후에 따른 타이틀 결정
    final String displayTitle = csoStatusAsync.maybeWhen(
      data: (status) => status.csoNm,
      orElse: () => widget.csoNm,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: const CsoAppBar(title: '민원실 현황'),
      body: csoStatusAsync.when(
        data: (status) => RefreshIndicator(
          color: AppTextStyles.primaryBlue,
          onRefresh: () =>
              ref.read(csoDetailProvider(widget.csoSn).notifier).refresh(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                CsoHeaderSection(
                  operatingHours:
                      status.locationInfo?.operatingHoursStr ?? '09:00 — 18:00',
                  csoNm: status.csoNm,
                  isNightOperating:
                      status.locationInfo?.isNightOperating ?? false,
                  isWeekendOperating:
                      status.locationInfo?.isWeekendOperating ?? false,
                  nightOperatingExpln: status.locationInfo?.nightOperatingExpln,
                  weekendOperatingExpln:
                      status.locationInfo?.weekendOperatingExpln,
                ),
                const SizedBox(height: 16),
                _buildTabs(),
                const SizedBox(height: 20), // 탭과 하단 콘텐츠 사이 여백 확보
                if (_selectedTab == 0) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        CsoWaitingCard(status: status),
                        const SizedBox(height: 20),
                        CsoTaskAccordion(tasks: status.taskStatuses),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: CsoCongestionTab(status: status),
                  ),
                  const SizedBox(height: 40),
                ],
              ],
            ),
          ),
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTextStyles.primaryBlue),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 60,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text(
                '오류 발생: $err',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTextStyles.primaryBlue,
                ),
                onPressed: () => ref.refresh(csoDetailProvider(widget.csoSn)),
                child: Text(
                  '다시 시도',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFEDF2F7), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('대기 현황', index: 0)),
          Expanded(child: _buildTabItem('혼잡도', index: 1)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, {required int index}) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: isSelected
              ? const Border(
                  bottom: BorderSide(
                    color: AppTextStyles.primaryBlue,
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.heading2.copyWith(
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected
                ? AppTextStyles.primaryBlue
                : AppTextStyles.textLightGray,
          ),
        ),
      ),
    );
  }
}
