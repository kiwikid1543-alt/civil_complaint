import 'package:flutter/material.dart';
import '../../models/entities/cso_status.dart';
import '../../core/theme/app_text_styles.dart';

/// 업무별 상세 대기 현황 (아코디언)
class CsoTaskAccordion extends StatelessWidget {
  final List<CsoTaskStatus> tasks;
  const CsoTaskAccordion({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1),
      ),
      child: ExpansionTile(
        title: Text(
          '업무별 상세 대기 현황',
          style: AppTextStyles.bodyLarge,
        ),
        trailing: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF718096)),
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 16),
        children: tasks.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '현재 상세 대기 내역이 없습니다.',
                    style: AppTextStyles.bodySmall.copyWith(color: AppTextStyles.textLightGray),
                  ),
                )
              ]
            : tasks.map(_buildTaskItem).toList(),
      ),
    );
  }

  Widget _buildTaskItem(CsoTaskStatus task) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            task.taskNm,
            style: AppTextStyles.bodyMedium,
          ),
          Row(
            children: [
              Text(
                '${task.waitingCount}',
                style: AppTextStyles.heading2.copyWith(color: AppTextStyles.primaryBlue),
              ),
              const SizedBox(width: 4),
              Text(
                '명',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
