import 'package:flutter/foundation.dart';

/// 관공서(민원실) 기본 정보 및 현재 위치로부터의 거리 정보 엔티티
@immutable
class CsoInfo {
  final String csoSn;
  final String csoNm;
  final String address;
  final double latitude;
  final double longitude;
  final double? distanceInKm; // 사용자 위치 기반 처리 전까지 null 가능
  final String? operatingHoursStr;
  final bool isNightOperating;
  final bool isWeekendOperating;
  final String? nightOperatingExpln;
  final String? weekendOperatingExpln;

  const CsoInfo({
    required this.csoSn,
    required this.csoNm,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.distanceInKm,
    this.operatingHoursStr,
    this.isNightOperating = false,
    this.isWeekendOperating = false,
    this.nightOperatingExpln,
    this.weekendOperatingExpln,
  });

  CsoInfo copyWith({
    String? csoSn,
    String? csoNm,
    String? address,
    double? latitude,
    double? longitude,
    double? distanceInKm,
    String? operatingHoursStr,
    bool? isNightOperating,
    bool? isWeekendOperating,
    String? nightOperatingExpln,
    String? weekendOperatingExpln,
  }) {
    return CsoInfo(
      csoSn: csoSn ?? this.csoSn,
      csoNm: csoNm ?? this.csoNm,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceInKm: distanceInKm ?? this.distanceInKm,
      operatingHoursStr: operatingHoursStr ?? this.operatingHoursStr,
      isNightOperating: isNightOperating ?? this.isNightOperating,
      isWeekendOperating: isWeekendOperating ?? this.isWeekendOperating,
      nightOperatingExpln: nightOperatingExpln ?? this.nightOperatingExpln,
      weekendOperatingExpln: weekendOperatingExpln ?? this.weekendOperatingExpln,
    );
  }
}
