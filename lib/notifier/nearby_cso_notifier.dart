import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/entities/cso_info.dart';
import 'cso_repository_provider.dart';

part 'nearby_cso_notifier.g.dart';

// 한국 영토 위경도 범위
const _koreaNorthLat = 38.9;
const _koreaSouthLat = 33.0;
const _koreaWestLng = 124.0;
const _koreaEastLng = 132.0;

bool _isInKorea(double lat, double lng) {
  return lat >= _koreaSouthLat &&
      lat <= _koreaNorthLat &&
      lng >= _koreaWestLng &&
      lng <= _koreaEastLng;
}

/// 사용자 위치를 기반으로 가까운 관공서 목록을 반환
@riverpod
Future<List<CsoInfo>> nearbyCso(Ref ref) async {
  // 1. 위치 서비스 활성화 확인
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return _fetchWithLocation(ref, null, null);
  }

  // 2. 위치 권한 확인 및 요청
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    return _fetchWithLocation(ref, null, null);
  }

  // 3. 현재 위치 획득
  Position position;
  try {
    position = await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  } catch (_) {
    return _fetchWithLocation(ref, null, null);
  }

  // 4. 한국 범위 밖이면(시뮬레이터 기본 위치 = 미국 등) 위치 알 수 없음 처리
  if (!_isInKorea(position.latitude, position.longitude)) {
    return _fetchWithLocation(ref, null, null);
  }

  return _fetchWithLocation(ref, position.latitude, position.longitude);
}

/// 위경도를 기반으로 전체 목록 조회 및 거리 계산 정렬
Future<List<CsoInfo>> _fetchWithLocation(
  Ref ref,
  double? lat,
  double? lng,
) async {
  final repository = ref.watch(csoRepositoryProvider);
  final result = await repository.getAllCsoList();

  return result.fold(
    (list) {
      if (lat == null || lng == null) {
        return list; // 거리 계산 없이 원본 목록 반환
      }

      final calculatedList = list.map((cso) {
        final distanceInMeters = Geolocator.distanceBetween(
          lat,
          lng,
          cso.latitude,
          cso.longitude,
        );
        return cso.copyWith(distanceInKm: distanceInMeters / 1000.0);
      }).toList();

      calculatedList.sort(
        (a, b) => (a.distanceInKm ?? 0).compareTo(b.distanceInKm ?? 0),
      );
      return calculatedList;
    },
    (failure) => throw Exception(failure.message),
  );
}
