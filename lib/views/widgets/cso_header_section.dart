import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// 헤더 섹션 (타이틀, 주간 필터 칩, 운영 시간)
class CsoHeaderSection extends StatelessWidget {
  final String operatingHours;
  final String csoNm;

  const CsoHeaderSection({
    super.key,
    required this.operatingHours,
    this.csoNm = '민원실',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          csoNm,
          style: AppTextStyles.display1,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 주간 칩만 표시 (야간/주말 제거)
            _buildFilterChip('주간'),
            const SizedBox(width: 16),
            const Icon(Icons.access_time, size: 16, color: Color(0xFF4A5568)),
            const SizedBox(width: 4),
            Text(
              operatingHours,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTextStyles.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '주간',
        style: AppTextStyles.bodyMedium.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
