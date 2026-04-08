import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/entities/cso_info.dart';
import '../notifier/nearby_cso_notifier.dart';
import '../core/theme/app_text_styles.dart';

class CsoListScreen extends ConsumerStatefulWidget {
  const CsoListScreen({super.key});

  @override
  ConsumerState<CsoListScreen> createState() => _CsoListScreenState();
}

class _CsoListScreenState extends ConsumerState<CsoListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncCsoList = ref.watch(nearbyCsoProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F5F9),
        body: RefreshIndicator(
          edgeOffset: MediaQuery.of(context).padding.top + kToolbarHeight,
          color: const Color(0xFF0A3DA8),
          onRefresh: () async => ref.invalidate(nearbyCsoProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── 앱바 ──────────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                leading: Navigator.canPop(context)
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppTextStyles.primaryBlue),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    : null,
                title: Text(
                  '내 주변 민원실',
                  style: AppTextStyles.appBarTitle,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.map_rounded, color: AppTextStyles.primaryBlue),
                    tooltip: '지도에서 보기',
                    onPressed: () => context.push('/map'),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // ── 검색바 섹션 (상시 노출) ──────────────────────────────────
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      style: AppTextStyles.bodyMedium.copyWith(fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '찾으시는 민원실 이름을 입력하세요',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppTextStyles.textLightGray,
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppTextStyles.textLightGray, size: 22),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 20, color: AppTextStyles.textLightGray),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
              ),

              // ── 본문 ──────────────────────────────────────────────────────
              asyncCsoList.when(
                data: (csoList) {
                  final filteredList = csoList.where((cso) {
                    final query = _searchQuery.toLowerCase();
                    return cso.csoNm.toLowerCase().contains(query) ||
                        cso.address.toLowerCase().contains(query);
                  }).toList();

                  if (filteredList.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: AppTextStyles.textLightGray,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty 
                                  ? '주변 관공서 데이터를 찾을 수 없습니다.'
                                  : '검색 결과가 없습니다',
                              style: AppTextStyles.bodyMedium.copyWith(color: AppTextStyles.textGray),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cso = filteredList[index];
                          // 검색 중이 아닐 때만 실제 최단 거리(1순위) 항목을 강조
                          final bool isNearest = index == 0 && _searchQuery.isEmpty;
                          
                          return _CsoCard(
                            cso: cso,
                            isNearest: isNearest,
                            onTap: () {
                              final uri = Uri(
                                path: '/detail/${cso.csoSn}',
                                queryParameters: {'csoNm': cso.csoNm},
                              );
                              context.push(uri.toString());
                            },
                          );
                        },
                        childCount: filteredList.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E5BB1),
                      strokeWidth: 2.5,
                    ),
                  ),
                ),
                error: (error, _) => const SliverFillRemaining(
                  child: Center(child: Text('데이터를 불러오지 못했습니다')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CsoCard extends StatelessWidget {
  final CsoInfo cso;
  final bool isNearest;
  final VoidCallback onTap;

  const _CsoCard({
    required this.cso,
    this.isNearest = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                // ── 아이콘 배지 (최단 거리 여부에 따라 변화) ──
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isNearest 
                        ? AppTextStyles.primaryBlue 
                        : const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      isNearest ? Icons.near_me_rounded : Icons.location_city_rounded, 
                      color: isNearest ? Colors.white : const Color(0xFFCBD5E0), 
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // ── 이름 & 주소 ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cso.csoNm,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        cso.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppTextStyles.textGray,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── 거리 정보 ──
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isNearest)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '가장 가까워요!',
                          style: AppTextStyles.micro.copyWith(
                            color: AppTextStyles.primaryBlue,
                            fontWeight: FontWeight.w800,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    Text(
                      cso.distanceInKm != null
                          ? _formatDistance(cso.distanceInKm!)
                          : '-',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isNearest ? AppTextStyles.primaryBlue : AppTextStyles.textGray,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '거리',
                      style: AppTextStyles.caption.copyWith(
                        color: AppTextStyles.textLightGray,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.chevron_right_rounded, 
                      color: Color(0xFFCBD5E0), size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1.0) return '${(km * 1000).round()}m';
    return '${km.toStringAsFixed(1)}km';
  }
}
