// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cso_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PortalResponse<T> _$PortalResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PortalResponse<T>(
  header: PortalHeader.fromJson(json['header'] as Map<String, dynamic>),
  body: PortalBody<T>.fromJson(
    json['body'] as Map<String, dynamic>,
    (value) => fromJsonT(value),
  ),
);

PortalHeader _$PortalHeaderFromJson(Map<String, dynamic> json) => PortalHeader(
  resultCode: json['resultCode'] as String,
  resultMsg: json['resultMsg'] as String,
);

PortalBody<T> _$PortalBodyFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PortalBody<T>(
  items: json['items'] == null
      ? null
      : PortalItems<T>.fromJson(
          json['items'] as Map<String, dynamic>,
          (value) => fromJsonT(value),
        ),
  numOfRows: (json['numOfRows'] as num?)?.toInt(),
  pageNo: (json['pageNo'] as num?)?.toInt(),
  totalCount: (json['totalCount'] as num?)?.toInt(),
);

PortalItems<T> _$PortalItemsFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PortalItems<T>(
  item: (json['item'] as List<dynamic>).map(fromJsonT).toList(),
);

CsoRealtimeDto _$CsoRealtimeDtoFromJson(Map<String, dynamic> json) =>
    CsoRealtimeDto(
      totDt: json['totDt'] as String?,
      stdgCd: json['stdgCd'] as String?,
      csoSn: json['csoSn'] as String?,
      taskNo: json['taskNo'] as String?,
      taskNm: json['taskNm'] as String?,
      clotNo: json['clotNo'] as String?,
      wtngCnt: json['wtngCnt'] as String?,
      clotCnterNo: json['clotCnterNo'] as String?,
      csoNm: json['csoNm'] as String?,
    );

CsoInfoDto _$CsoInfoDtoFromJson(Map<String, dynamic> json) => CsoInfoDto(
  csoSn: json['csoSn'] as String?,
  csoNm: json['csoNm'] as String?,
  roadNmAddr: json['roadNmAddr'] as String?,
  lat: json['lat'] as String?,
  lot: json['lot'] as String?,
  wkdyOperBgngTm: json['wkdyOperBgngTm'] as String?,
  wkdyOperEndTm: json['wkdyOperEndTm'] as String?,
  nghtOperYn: json['nghtOperYn'] as String?,
  wkndOperYn: json['wkndOperYn'] as String?,
  nghtDowExpln: json['nghtDowExpln'] as String?,
  wkndDowExpln: json['wkndDowExpln'] as String?,
);
