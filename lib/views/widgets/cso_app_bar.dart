import 'package:flutter/material.dart';
import '../../core/theme/app_text_styles.dart';

/// 상단 앱바 (뒤로가기, 타이틀)
class CsoAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const CsoAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Scaffold의 leading 속성을 null로 설정하기 위한 로직 (go_router 대응)
    final canPop = Navigator.canPop(context);
    
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: canPop 
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, 
                  size: 20, color: AppTextStyles.primaryBlue),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
