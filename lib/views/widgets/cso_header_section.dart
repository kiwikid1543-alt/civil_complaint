import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// 헤더 섹션 (타이틀, 주간 필터 칩, 운영 시간)
class CsoHeaderSection extends StatelessWidget {
  final String operatingHours;
  final String csoNm;
  final bool isNightOperating;
  final bool isWeekendOperating;
  final String? nightOperatingExpln;
  final String? weekendOperatingExpln;

  const CsoHeaderSection({
    super.key,
    required this.operatingHours,
    this.csoNm = '민원실',
    this.isNightOperating = false,
    this.isWeekendOperating = false,
    this.nightOperatingExpln,
    this.weekendOperatingExpln,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text(csoNm, style: AppTextStyles.display1),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            // 주간 칩 (인터랙티브 배지화)
            _buildFilterChip(
              '주간',
              color: AppTextStyles.primaryBlue,
              icon: Icons.light_mode_rounded,
              onTap: () => _showExplnBottomSheet(
                context,
                title: '주간 운영 안내',
                content: '평일 운영 시간: $operatingHours',
                icon: Icons.light_mode_rounded,
                accentColor: AppTextStyles.primaryBlue,
              ),
            ),

            // 야간 칩 (운영 시에만)
            if (isNightOperating)
              _buildFilterChip(
                '야간',
                color: const Color(0xFF5A67D8), // Indigo
                icon: Icons.dark_mode_rounded,
                onTap: () => _showExplnBottomSheet(
                  context,
                  title: '야간 운영 안내',
                  content: nightOperatingExpln ?? '야간 운영에 대한 상세 설명이 없습니다.',
                  icon: Icons.dark_mode_rounded,
                  accentColor: const Color(0xFF5A67D8),
                ),
              ),

            // 주말 칩 (운영 시에만)
            if (isWeekendOperating)
              _buildFilterChip(
                '주말',
                color: const Color(0xFFED8936), // Orange
                icon: Icons.event_available_rounded,
                onTap: () => _showExplnBottomSheet(
                  context,
                  title: '주말 운영 안내',
                  content: weekendOperatingExpln ?? '주말 운영에 대한 상세 설명이 없습니다.',
                  icon: Icons.event_available_rounded,
                  accentColor: const Color(0xFFED8936),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label, {
    required Color color,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(onTap != null ? 1.0 : 0.8),
            borderRadius: BorderRadius.circular(10),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: Colors.white),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExplnBottomSheet(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color accentColor,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accentColor, size: 24),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: AppTextStyles.heading2.copyWith(
                    color: AppTextStyles.textGray,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEDF2F7)),
              ),
              child: Text(
                content,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF2D3748),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTextStyles.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
