import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_text_styles.dart';

/// 앱의 메인 탭 구조를 담고 있는 쉘 위젯
class MainShellScreen extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShellScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppTextStyles.micro.copyWith(
                  color: AppTextStyles.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                );
              }
              return AppTextStyles.micro.copyWith(
                color: AppTextStyles.textLightGray,
                fontSize: 11,
              );
            }),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: AppTextStyles.primaryBlue,
                  size: 24,
                );
              }
              return const IconThemeData(
                color: AppTextStyles.textLightGray,
                size: 24,
              );
            }),
            indicatorColor: AppTextStyles.primaryBlue.withValues(alpha: 0.1),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (index) => _onTap(context, index),
            backgroundColor: Colors.white,
            elevation: 0,
            height: 64,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.list_alt_rounded),
                selectedIcon: Icon(Icons.list_alt_rounded),
                label: '주변',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: '현황',
              ),
              NavigationDestination(
                icon: Icon(Icons.description_outlined),
                selectedIcon: Icon(Icons.description_rounded),
                label: '가이드',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
