import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import '../core/theme/app_text_styles.dart';
import '../models/entities/cso_status.dart';
import '../notifier/all_cso_congestion_provider.dart';
import 'widgets/cso_app_bar.dart';

class CsoMapScreen extends ConsumerStatefulWidget {
  const CsoMapScreen({super.key});

  @override
  ConsumerState<CsoMapScreen> createState() => _CsoMapScreenState();
}

class _CsoMapScreenState extends ConsumerState<CsoMapScreen> {
  final MapController _mapController = MapController();
  CsoStatus? _selectedStatus;
  
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      
      setState(() {
        _currentPosition = position;
      });
      
      // 처음 위치를 가져오면 내 위치로 지도 이동
      _moveToCurrentLocation();
    } catch (e) {
      debugPrint('위치 획득 실패: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _moveToCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude), 
        14.0
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusListAsync = ref.watch(allCsoCongestionProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFF),
      appBar: const CsoAppBar(
        title: '지도에서 찾기',
        actions: [], 
      ),
      body: statusListAsync.when(
        data: (statuses) => Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(37.5665, 126.9780), // 기본 서울 지역 중앙
                initialZoom: 11.5,
                onTap: (_, __) {
                  // 바닥 클릭 시 선택 해제
                  if (_selectedStatus != null) {
                    setState(() {
                      _selectedStatus = null;
                    });
                  }
                },
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all, // 핀치 줌, 더블 탭 줌 등 모든 제스처 활성화
                ),
              ),
              children: [
                TileLayer(
                  // 깔끔하고 텍스트 가독성이 높은 CartoDB Positron 테마
                  urlTemplate: 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.civil_complaint',
                ),
                MarkerLayer(
                  markers: statuses.map((status) {
                    final lat = status.locationInfo?.latitude ?? 0.0;
                    final lot = status.locationInfo?.longitude ?? 0.0;
                    final isSelected = _selectedStatus == status;
                    
                    return Marker(
                      width: 120, // 텍스트를 담을 수 있게 충분히 넓힘
                      height: 80,
                      point: LatLng(lat, lot),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedStatus = status;
                          });
                          _mapController.move(LatLng(lat, lot), 14.5);
                        },
                        child: _buildMarkerIcon(status.csoNm, status.congestionLevel, isSelected),
                      ),
                    );
                  }).toList(),
                ),
                // 현위치 마커 표시
                if (_currentPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 24,
                        height: 24,
                        point: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF4285F4),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            
            // 제어용 버튼 세트 (내 위치 위에 배치)
            Positioned(
              right: 20,
              bottom: _selectedStatus != null ? 220 : 30, // 카드가 열려있을 땐 카드 위로
              child: AnimatedPadding(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.only(bottom: _selectedStatus != null ? 20 : 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 줌 인 (+) 버튼
                    _buildControlButton(
                      icon: Icons.add_rounded,
                      onPressed: () {
                        final nextZoom = (_mapController.camera.zoom + 1).clamp(3.0, 18.0);
                        _mapController.move(_mapController.camera.center, nextZoom);
                      },
                    ),
                    const SizedBox(height: 8),
                    // 줌 아웃 (-) 버튼
                    _buildControlButton(
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        final nextZoom = (_mapController.camera.zoom - 1).clamp(3.0, 18.0);
                        _mapController.move(_mapController.camera.center, nextZoom);
                      },
                    ),
                    const SizedBox(height: 16),
                    // 내 위치 버튼
                    FloatingActionButton(
                      heroTag: 'my_location',
                      backgroundColor: Colors.white,
                      onPressed: _fetchCurrentLocation, // 다시 위치를 가져오며 이동
                      child: _isLoadingLocation 
                          ? const SizedBox(
                              width: 20, 
                              height: 20, 
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppTextStyles.primaryBlue)
                            )
                          : const Icon(Icons.my_location, color: AppTextStyles.primaryBlue),
                    ),
                  ],
                ),
              ),
            ),

            if (_selectedStatus != null)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: _buildLocationCard(_selectedStatus!),
              ),
          ],
        ),
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTextStyles.primaryBlue)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
              const SizedBox(height: 16),
              Text('오류 발생: $err', style: AppTextStyles.bodyMedium.copyWith(color: Colors.red)),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTextStyles.primaryBlue),
                onPressed: () => ref.read(allCsoCongestionProvider.notifier).refresh(),
                child: Text('다시 시도', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarkerIcon(String name, CongestionLevel level, bool isSelected) {
    Color color;
    switch (level) {
      case CongestionLevel.high:
        color = const Color(0xFFF87171); // 혼잡 - 빨강
        break;
      case CongestionLevel.medium:
        color = const Color(0xFFFBBF24); // 보통 - 노랑
        break;
      case CongestionLevel.low:
        color = const Color(0xFF4ADE80); // 여유 - 초록
        break;
      case CongestionLevel.unknown:
        color = const Color(0xFF94A3B8); // 알 수 없음 - 회색
        break;
    }

    return AnimatedScale(
      scale: isSelected ? 1.15 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color, width: isSelected ? 2 : 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            child: Text(
              name.replaceAll(' 민원실', ''), // 이름 길이를 줄이기 위해
              style: AppTextStyles.caption.copyWith(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.bold,
                color: isSelected ? AppTextStyles.primaryBlue : const Color(0xFF1A202C),
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.location_on, color: color, size: 36),
              if (isSelected)
                const Positioned(
                  top: 6,
                  child: Icon(Icons.circle, color: Colors.white, size: 10),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(CsoStatus status) {
    final info = status.locationInfo;
    if (info == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  status.csoNm,
                  style: AppTextStyles.heading2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getCongestionColor(status.congestionLevel).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.congestionLevel.label,
                  style: AppTextStyles.caption.copyWith(
                    color: _getCongestionColor(status.congestionLevel),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            info.address,
            style: AppTextStyles.bodyMedium.copyWith(color: AppTextStyles.textGray),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge('주간: ${info.operatingHoursStr}', true),
              if (info.isNightOperating) 
                _buildBadgeWithTooltip('야간운영', info.nightOperatingExpln),
              if (info.isWeekendOperating) 
                _buildBadgeWithTooltip('주말운영', info.weekendOperatingExpln),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                context.push('/detail/${info.csoSn}', extra: info.csoNm);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTextStyles.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: Text(
                '상세 대기 현황 보기',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeWithTooltip(String label, String? explanation) {
    final badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF8FF),
        border: Border.all(color: const Color(0xFF90CDF4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: const Color(0xFF2B6CB0),
              fontWeight: FontWeight.bold,
            ),
          ),
          if (explanation != null && explanation.isNotEmpty) ...[
            const SizedBox(width: 4),
            const Icon(Icons.info_outline, size: 14, color: Color(0xFF2B6CB0)),
          ]
        ],
      ),
    );

    if (explanation == null || explanation.isEmpty) {
      return badge;
    }

    return Tooltip(
      message: explanation,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      triggerMode: TooltipTriggerMode.tap,
      showDuration: const Duration(seconds: 4),
      child: badge,
    );
  }

  Widget _buildBadge(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF7FAFC) : const Color(0xFFEDF2F7),
        border: Border.all(
          color: isActive ? const Color(0xFFE2E8F0) : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: isActive ? AppTextStyles.textGray : AppTextStyles.textLightGray,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Color _getCongestionColor(CongestionLevel level) {
    switch (level) {
      case CongestionLevel.high:
        return const Color(0xFFF87171);
      case CongestionLevel.medium:
        return const Color(0xFFFBBF24);
      case CongestionLevel.low:
        return const Color(0xFF4ADE80);
      case CongestionLevel.unknown:
        return const Color(0xFF94A3B8);
    }
  }

  Widget _buildControlButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF4A5568)),
        onPressed: onPressed,
      ),
    );
  }
}
