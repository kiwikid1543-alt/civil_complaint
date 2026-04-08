// lib/views/widgets/cso_congestion_tab.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/entities/cso_status.dart';
import '../../models/entities/hourly_congestion.dart';
import '../../notifier/congestion_analytics_provider.dart';
import '../../core/theme/app_text_styles.dart';

/// 혼잡도 탭 — 시간대별 예측 바 차트 (Firestore 실시간 통계 연동)
class CsoCongestionTab extends ConsumerStatefulWidget {
  final CsoStatus status;
  const CsoCongestionTab({super.key, required this.status});

  @override
  ConsumerState<CsoCongestionTab> createState() => _CsoCongestionTabState();
}

class _CsoCongestionTabState extends ConsumerState<CsoCongestionTab> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final csoSn = widget.status.locationInfo?.csoSn ?? '';
    final congestionAsync = ref.watch(congestionAnalyticsProvider(csoSn));

    return congestionAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48),
          child: CircularProgressIndicator(color: AppTextStyles.primaryBlue),
        ),
      ),
      error: (_, __) => _buildContent(_fallbackData()),
      data: (hourlyData) => _buildContent(hourlyData),
    );
  }

  Widget _buildContent(List<HourlyCongestion> hourlyData) {
    // 18시 이후 데이터 필터링 (사용자 요청: 18시~20시 제외)
    final filteredData = hourlyData.where((d) => d.hour < 18).toList();
    final int currentHour = DateTime.now().hour;
    final bool isFallback = filteredData.any((d) => d.isFallback);

    return Column(
      children: [
        _buildSummaryCard(),
        const SizedBox(height: 12),
        _buildChartCard(currentHour, filteredData, isFallback),
        const SizedBox(height: 12),
        _buildBestTimeCard(filteredData),
      ],
    );
  }

  /// 상단 현재 혼잡도 요약 카드
  Widget _buildSummaryCard() {
    final level = widget.status.congestionLevel;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: AppTextStyles.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTextStyles.primaryBlue.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '현재 혼잡도',
                style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    level.label,
                    style: AppTextStyles.display1.copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '대기 ${widget.status.totalWaitingCount}명',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.circle, size: 8, color: Color(0xFF4ADE80)),
                const SizedBox(width: 6),
                Text(
                  '실시간',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 시간대별 혼잡도 바 차트 카드
  Widget _buildChartCard(
    int currentHour,
    List<HourlyCongestion> hourlyData,
    bool isFallback,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('시간대별 혼잡도', style: AppTextStyles.bodyLarge),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isFallback
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFF0F4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isFallback ? '데이터 수집 중' : '실제 통계',
                  style: AppTextStyles.micro.copyWith(
                    color: isFallback
                        ? const Color(0xFFD97706)
                        : AppTextStyles.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (isFallback)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '통계 데이터를 수집하고 있습니다. 며칠 후 실제 혼잡도로 업데이트됩니다.',
                style: AppTextStyles.micro.copyWith(color: AppTextStyles.textGray),
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: 1.0,
                minY: 0,
                barTouchData: BarTouchData(
                  touchCallback: (event, response) {
                    setState(() {
                      if (response?.spot != null && event is! FlPointerExitEvent) {
                        final index = response!.spot!.touchedBarGroupIndex;
                        if (index < hourlyData.length) {
                          _touchedIndex = index;
                        } else {
                          _touchedIndex = null;
                        }
                      } else {
                        _touchedIndex = null;
                      }
                    });
                  },
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => AppTextStyles.primaryBlue,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex >= hourlyData.length) return null;
                      final data = hourlyData[groupIndex];
                      final percent = (data.congestionRate * 100).round();
                      return BarTooltipItem(
                        '${data.hour}시\n$percent%',
                        AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        String text = '';
                        bool isBold = false;

                        if (index >= 0 && index < hourlyData.length) {
                          final hour = hourlyData[index].hour;
                          text = '$hour';
                          isBold = hour == currentHour;
                        } else if (index == hourlyData.length) {
                          text = '18';
                        } else {
                          return const SizedBox.shrink();
                        }

                        // 가독성을 위해 숫자를 막대 기둥의 좌측 경계(꼭지점)로 쉬프트 (바 너비 22의 절반인 11픽셀 정도이동)
                        return SideTitleWidget(
                          meta: meta,
                          space: 8,
                          child: Transform.translate(
                            offset: const Offset(-11, 0),
                            child: Text(
                              text,
                              style: AppTextStyles.micro.copyWith(
                                fontSize: 10,
                                fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
                                color: isBold
                                    ? AppTextStyles.primaryBlue
                                    : AppTextStyles.textLightGray,
                              ),
                            ),
                          ),
                        );
                      },
                      reservedSize: 28,
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 0.25,
                  getDrawingHorizontalLine: (value) => const FlLine(
                    color: Color(0xFFEDF2F7),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(hourlyData.length + 1, (index) {
                  if (index == hourlyData.length) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: 0,
                          color: Colors.transparent,
                          width: 22,
                        ),
                      ],
                    );
                  }

                  final data = hourlyData[index];
                  final isCurrent = data.hour == currentHour;
                  final isTouched = _touchedIndex == index;
                  final barColor = _barColor(data.congestionRate);

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data.congestionRate,
                        color: isTouched ? barColor.withValues(alpha: 0.65) : barColor,
                        width: 22,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 1.0,
                          color: const Color(0xFFF7F9FC),
                        ),
                      ),
                    ],
                    showingTooltipIndicators: isCurrent ? [0] : [],
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: Color(0xFF4ADE80), label: '여유'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFFBBF24), label: '보통'),
              SizedBox(width: 16),
              _LegendDot(color: Color(0xFFF87171), label: '혼잡'),
            ],
          ),
        ],
      ),
    );
  }

  /// 방문 최적 시간 추천 카드
  Widget _buildBestTimeCard(List<HourlyCongestion> hourlyData) {
    // 운영 시간 내 가장 낮은 혼잡도 시간대 탐색
    final best = hourlyData.reduce(
      (a, b) => a.congestionRate < b.congestionRate ? a : b,
    );
    final amPm = best.hour < 12 ? '오전' : '오후';
    final displayHour = best.hour > 12 ? best.hour - 12 : best.hour;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTextStyles.primaryBlue.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTextStyles.primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tips_and_updates_rounded,
              color: AppTextStyles.primaryBlue,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '방문하기 가장 좋은 시간',
                  style: AppTextStyles.caption.copyWith(
                    color: AppTextStyles.textGray,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$amPm $displayHour시 ~ ${displayHour + 1}시 사이에 방문하시면 가장 빠르게 업무를 보실 수 있습니다.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppTextStyles.textBlack,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 혼잡도 비율에 따른 색상 반환
  Color _barColor(double rate) {
    if (rate >= 0.7) return const Color(0xFFF87171); // 혼잡 - 빨강
    if (rate >= 0.4) return const Color(0xFFFBBF24); // 보통 - 노랑
    return const Color(0xFF4ADE80); // 여유 - 초록
  }

  /// Fallback 임시 데이터 (csoSn이 없거나, 빈 문자열일 때 사용)
  List<HourlyCongestion> _fallbackData() {
    return const [
      HourlyCongestion(hour: 8,  congestionRate: 0.20, isFallback: true),
      HourlyCongestion(hour: 9,  congestionRate: 0.30, isFallback: true),
      HourlyCongestion(hour: 10, congestionRate: 0.55, isFallback: true),
      HourlyCongestion(hour: 11, congestionRate: 0.75, isFallback: true),
      HourlyCongestion(hour: 12, congestionRate: 0.90, isFallback: true),
      HourlyCongestion(hour: 13, congestionRate: 0.60, isFallback: true),
      HourlyCongestion(hour: 14, congestionRate: 0.85, isFallback: true),
      HourlyCongestion(hour: 15, congestionRate: 0.70, isFallback: true),
      HourlyCongestion(hour: 16, congestionRate: 0.45, isFallback: true),
      HourlyCongestion(hour: 17, congestionRate: 0.35, isFallback: true),
      HourlyCongestion(hour: 18, congestionRate: 0.20, isFallback: true),
      HourlyCongestion(hour: 19, congestionRate: 0.15, isFallback: true),
      HourlyCongestion(hour: 20, congestionRate: 0.10, isFallback: true),
    ];
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
