import 'package:json_annotation/json_annotation.dart';

part 'cso_response_dto.g.dart';

/// 공공데이터포털 공통 응답 구조
@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PortalResponse<T> {
  final PortalHeader header;
  final PortalBody<T> body;

  PortalResponse({required this.header, required this.body});

  factory PortalResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PortalResponseFromJson(json, fromJsonT);
}

@JsonSerializable(createToJson: false)
class PortalHeader {
  final String resultCode;
  final String resultMsg;

  PortalHeader({required this.resultCode, required this.resultMsg});

  factory PortalHeader.fromJson(Map<String, dynamic> json) =>
      _$PortalHeaderFromJson(json);
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PortalBody<T> {
  final PortalItems<T>? items; // items가 null이거나 빈 배열일 수 있음
  final int? numOfRows;
  final int? pageNo;
  final int? totalCount;

  PortalBody({this.items, this.numOfRows, this.pageNo, this.totalCount});

  factory PortalBody.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PortalBodyFromJson(json, fromJsonT);
}

@JsonSerializable(genericArgumentFactories: true, createToJson: false)
class PortalItems<T> {
  // 공공데이터 API 특정 상: 아이템이 1개면 객체, 2개 이상이면 배열로 오므로 dynamic 처리 후 내부 변환 권장
  // 하지만 일단 일반적인 리스트로 매핑되도록 설정
  @JsonKey(name: 'item')
  final List<T> item;

  PortalItems({required this.item});

  factory PortalItems.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    // API에서 항목이 1개일 때 배열이 아닌 단일 객체로 내려오는 고질적 문제 해결 루틴
    // json이 unmodifiable map일 수 있으므로 복사본 생성
    final map = Map<String, dynamic>.from(json);
    if (map['item'] is Map) {
      map['item'] = [map['item']];
    } else if (map['item'] == null) {
      map['item'] = [];
    }
    return _$PortalItemsFromJson(map, fromJsonT);
  }
}

/// 실시간 대기 현황 DTO (cso_realtime_v2)
@JsonSerializable(createToJson: false)
class CsoRealtimeDto {
  final String? totDt;       // 집계기준일시
  final String? stdgCd;      // 지자체 코드
  final String? csoSn;       // 민원실 일련번호
  final String? taskNo;      // 업무번호
  final String? taskNm;      // 업무명
  final String? clotNo;      // 호출번호
  final String? wtngCnt;     // 대기인수
  final String? clotCnterNo; // 호출창구번호
  final String? csoNm;       // 민원실명

  CsoRealtimeDto({
    this.totDt,
    this.stdgCd,
    this.csoSn,
    this.taskNo,
    this.taskNm,
    this.clotNo,
    this.wtngCnt,
    this.clotCnterNo,
    this.csoNm,
  });

  factory CsoRealtimeDto.fromJson(Map<String, dynamic> json) =>
      _$CsoRealtimeDtoFromJson(json);
}

/// 기본 정보 DTO (cso_info_v2) 
/// 필드가 다양하므로 필요한 것 위주로 선언합니다.
@JsonSerializable(createToJson: false)
class CsoInfoDto {
  final String? csoSn;
  final String? csoNm;
  final String? roadNmAddr;
  final String? lat;
  final String? lot;
  
  // 운영시간 및 요일 정보
  final String? wkdyOperBgngTm;
  final String? wkdyOperEndTm;
  final String? nghtOperYn;
  final String? wkndOperYn;
  final String? nghtDowExpln; // 야간 운영 설명
  final String? wkndDowExpln; // 주말 운영 설명
  
  CsoInfoDto({
    this.csoSn, 
    this.csoNm,
    this.roadNmAddr,
    this.lat,
    this.lot,
    this.wkdyOperBgngTm,
    this.wkdyOperEndTm,
    this.nghtOperYn,
    this.wkndOperYn,
    this.nghtDowExpln,
    this.wkndDowExpln,
  });

  factory CsoInfoDto.fromJson(Map<String, dynamic> json) =>
      _$CsoInfoDtoFromJson(json);
}
