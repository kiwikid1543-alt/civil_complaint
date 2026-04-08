import 'package:flutter/material.dart';
import '../../models/entities/cso_status.dart';
import '../../core/theme/app_text_styles.dart';

class CsoWaitingCard extends StatelessWidget {
  final CsoStatus status;

  const CsoWaitingCard({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTotalWaiting(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Divider(height: 1, color: Color(0xFFF1F4F8)),
          ),
          _buildDetailInfo(),
          const SizedBox(height: 24),
          _buildOperatingInfobar(),
          const SizedBox(height: 12),
          _buildProgressBar(_getCongestionProgress(status.congestionLevel)),
        ],
      ),
    );
  }

  Widget _buildTotalWaiting() {
    return Column(
      children: [
        Text(
          '총 대기 인원',
          style: AppTextStyles.bodyLarge.copyWith(color: AppTextStyles.textGray),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('${status.totalWaitingCount}', style: AppTextStyles.giant),
            const SizedBox(width: 4),
            Text(
              '명',
              style: AppTextStyles.heading2.copyWith(color: AppTextStyles.textGray),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // 정보를 가운데로 모음
      children: [
        Expanded(
          child: Column(
            children: [
              Text('예상 대기 시간', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              Text(
                '약 ${status.expectedWaitTimeMinutes}분',
                style: AppTextStyles.heading1,
              ),
            ],
          ),
        ),
        Container(
          width: 1.5,
          height: 40, // 원래 높이로 복구
          color: const Color(0xFFF1F4F8),
        ),
        Expanded(
          child: Column(
            children: [
              Text('전체 혼잡도', style: AppTextStyles.caption),
              const SizedBox(height: 8),
              Text(
                status.congestionLevel.label,
                style: AppTextStyles.heading1.copyWith(
                  color: _getCongestionColor(status.congestionLevel),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOperatingInfobar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status.congestionLevel == CongestionLevel.unknown
            ? '현재 창구운영 정보를 확인할 수 없습니다'
            : '현재 창구 ${status.operatingWindows}개 운영 중 (창구당 평균 ${status.avgWaitingPerWindow.toStringAsFixed(1)}명)',
        textAlign: TextAlign.center,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppTextStyles.textGray,
        ),
      ),
    );
  }

  Color _getCongestionColor(CongestionLevel level) {
    switch (level) {
      case CongestionLevel.low:
        return const Color(0xFF27AE60);
      case CongestionLevel.medium:
        return const Color(0xFFF2994A);
      case CongestionLevel.high:
        return const Color(0xFFEB5757);
      case CongestionLevel.unknown:
        return AppTextStyles.textLightGray;
    }
  }

  double _getCongestionProgress(CongestionLevel level) {
    switch (level) {
      case CongestionLevel.low:
        return 0.25;
      case CongestionLevel.medium:
        return 0.55;
      case CongestionLevel.high:
        return 0.9;
      case CongestionLevel.unknown:
        return 0.0;
    }
  }

  Widget _buildProgressBar(double progress) {
    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(3),
      ),
      child: progress > 0
          ? FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress > 1.0 ? 1.0 : progress,
              child: Container(
                decoration: BoxDecoration(
                  color: AppTextStyles.primaryBlue,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
