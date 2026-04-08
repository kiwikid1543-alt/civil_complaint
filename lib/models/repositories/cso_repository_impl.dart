import 'package:dio/dio.dart';
import '../../core/result.dart';
import '../entities/cso_status.dart';
import '../entities/cso_info.dart';
import 'cso_repository.dart';
import '../dto/cso_response_dto.dart';

class CsoRepositoryImpl implements CsoRepository {
  final Dio _dio;

  CsoRepositoryImpl(this._dio);

  @override
  Future<Result<List<CsoInfo>, AppFailure>> getAllCsoList() async {
    try {
      final response = await _dio.get('/cso_info_v2', queryParameters: {
        'numOfRows': 1000, // 충분히 큰 값으로 설정하여 전체 목록을 가져옴
      });
      
      final infoDtoResult = PortalResponse<CsoInfoDto>.fromJson(
        response.data,
        (json) => CsoInfoDto.fromJson(json as Map<String, dynamic>),
      );

      if (infoDtoResult.header.resultCode != '00' && infoDtoResult.header.resultCode != 'K0') {
        throw Exception('API Error: ${infoDtoResult.header.resultMsg}');
      }

      final items = infoDtoResult.body.items?.item ?? [];
      
      final csoInfoList = items.map((dto) {
        String? operatingHoursStr;
        if (dto.wkdyOperBgngTm != null && dto.wkdyOperEndTm != null && 
            dto.wkdyOperBgngTm!.length >= 4 && dto.wkdyOperEndTm!.length >= 4) {
          final start = _formatTime(dto.wkdyOperBgngTm!);
          final end = _formatTime(dto.wkdyOperEndTm!);
          operatingHoursStr = '$start — $end';
        }

        return CsoInfo(
          csoSn: dto.csoSn ?? '',
          csoNm: dto.csoNm ?? '이름 없음',
          address: dto.roadNmAddr ?? '',
          latitude: double.tryParse(dto.lat ?? '0') ?? 0.0,
          longitude: double.tryParse(dto.lot ?? '0') ?? 0.0,
          operatingHoursStr: operatingHoursStr ?? '09:00 — 18:00', // 기본값
          isNightOperating: dto.nghtOperYn == 'Y',
          isWeekendOperating: dto.wkndOperYn == 'Y',
          nightOperatingExpln: dto.nghtDowExpln,
          weekendOperatingExpln: dto.wkndDowExpln,
        );
      }).toList();

      return Result.success(csoInfoList);
    } on DioException catch (e) {
      return Result.failure(AppFailure('네트워크 통신 중 오류가 발생했습니다.', originalError: e));
    } catch (e) {
      return Result.failure(AppFailure('데이터를 불러오는데 실패했습니다.', originalError: e));
    }
  }

  @override
  Future<Result<List<CsoStatus>, AppFailure>> getAllCsoStatus() async {
    try {
      final results = await Future.wait([
        getAllCsoList(),
        _dio.get('/cso_realtime_v2', queryParameters: {'numOfRows': 1000}),
      ]);

      final infoResult = results[0] as Result<List<CsoInfo>, AppFailure>;
      if (!infoResult.isSuccess) {
        return Result.failure(infoResult.errorOrNull!);
      }
      final allInfos = infoResult.valueOrNull!;

      final realtimeResponse = results[1] as Response;
      final realtimeDtoResult = PortalResponse<CsoRealtimeDto>.fromJson(
        realtimeResponse.data,
        (json) => CsoRealtimeDto.fromJson(json as Map<String, dynamic>),
      );

      final allRealtimeItems = realtimeDtoResult.body.items?.item ?? [];
      final realtimeMap = <String, List<CsoRealtimeDto>>{};
      for (var item in allRealtimeItems) {
        if (item.csoSn != null) {
          realtimeMap.putIfAbsent(item.csoSn!, () => []).add(item);
        }
      }

      final statusList = allInfos.map((info) {
        final realtimeItems = realtimeMap[info.csoSn] ?? [];
        int totalWaitingCount = 0;
        int activeWindows = 0;
        List<CsoTaskStatus> taskStatuses = [];

        for (var item in realtimeItems) {
          final waitCount = int.tryParse(item.wtngCnt ?? '0') ?? 0;
          totalWaitingCount += waitCount;
          if (item.clotCnterNo != null && item.clotCnterNo!.isNotEmpty) {
            activeWindows++;
          }
          taskStatuses.add(CsoTaskStatus(
            taskNm: item.taskNm ?? '알 수 없는 업무',
            waitingCount: waitCount,
          ));
        }

        activeWindows = activeWindows > 0 ? activeWindows : 1;
        CongestionLevel level = CongestionLevel.low;
        if (totalWaitingCount > 30) {
          level = CongestionLevel.high;
        } else if (totalWaitingCount > 15) {
          level = CongestionLevel.medium;
        }

        return CsoStatus(
          csoNm: info.csoNm,
          totalWaitingCount: totalWaitingCount,
          expectedWaitTimeMinutes: totalWaitingCount * 3,
          congestionLevel: level,
          operatingWindows: activeWindows,
          avgWaitingPerWindow: totalWaitingCount / activeWindows,
          updatedAt: DateTime.now(),
          taskStatuses: taskStatuses,
          locationInfo: info, // location 정보를 첨부하려면 CsoStatus 수정 필요 - Wait, we can add it or just pass CsoStatus. 
        );
      }).toList();

      return Result.success(statusList);
    } on DioException catch (e) {
      return Result.failure(AppFailure('네트워크 오류 (전체 현황조회)', originalError: e));
    } catch (e) {
      return Result.failure(AppFailure('데이터 처리 오류 (전체 현황조회)', originalError: e));
    }
  }

  @override
  Future<Result<CsoStatus, AppFailure>> getCsoStatus(String csoSn) async {
    try {
      // 1. 병렬로 두 API 엔드포인트 호출 (성능 최적화)
      final results = await Future.wait([
        _dio.get('/cso_info_v2', queryParameters: {
          'csoSn': csoSn,
          'numOfRows': 10, // 단일 SN 조회이므로 10개면 충분
        }),
        _dio.get('/cso_realtime_v2', queryParameters: {
          'csoSn': csoSn,
          'numOfRows': 100, // 업무 분류가 많을 수 있으므로 대역폭 확보
        }),
      ]);

      final infoResponse = results[0];
      final realtimeResponse = results[1];

      // 2. 응답 데이터를 DTO로 역직렬화
      final infoDtoResult = PortalResponse<CsoInfoDto>.fromJson(
        infoResponse.data,
        (json) => CsoInfoDto.fromJson(json as Map<String, dynamic>),
      );

      final realtimeDtoResult = PortalResponse<CsoRealtimeDto>.fromJson(
        realtimeResponse.data,
        (json) => CsoRealtimeDto.fromJson(json as Map<String, dynamic>),
      );

      // 에러 확인
      if (infoDtoResult.header.resultCode != '00' && infoDtoResult.header.resultCode != 'K0') {
        throw Exception('API Error: ${infoDtoResult.header.resultMsg}');
      }

      // 3. 실시간 대기 현황 (tasks) 추출 및 csoSn으로 필터링
      final allRealtimeItems = realtimeDtoResult.body.items?.item ?? [];
      final realtimeItems = allRealtimeItems.where((e) => e.csoSn == csoSn).toList();
      
      int totalWaitingCount = 0;
      List<CsoTaskStatus> taskStatuses = [];
      int activeWindows = 0;

      for (var item in realtimeItems) {
        final waitCount = int.tryParse(item.wtngCnt ?? '0') ?? 0;
        totalWaitingCount += waitCount;
        
        // 업무명 정제: null, 빈 문자열, 혹은 공백만 있는 경우 처리
        String refinedTaskNm = (item.taskNm ?? '').trim();
        if (refinedTaskNm.isEmpty) {
          refinedTaskNm = '일반 민원/기타';
        }
        
        // 대기 인원이 있는 경우에만 상세 목록에 추가 (UI 깔끔하게 유지)
        if (waitCount > 0) {
          taskStatuses.add(CsoTaskStatus(
            taskNm: refinedTaskNm,
            waitingCount: waitCount,
          ));
        }
      }

      // 고유 창구 번호 추출 (중복 제거)

      // 고유 창구 번호 추출 및 정밀 계산 (쉼표 분리 포함)
      final allWindowNumbers = <String>{};
      for (var item in realtimeItems) {
        final rawNo = item.clotCnterNo;
        if (rawNo != null && rawNo.isNotEmpty && rawNo != '0') {
          // "1, 2, 3" 또는 "1~3", "1/2"와 같은 패턴 대응
          final splitNos = rawNo.split(RegExp(r'[,/~]'));
          for (var no in splitNos) {
            final trimmed = no.trim();
            if (trimmed.isNotEmpty && trimmed != '0') {
              allWindowNumbers.add(trimmed);
            }
          }
        }
      }
      
      activeWindows = allWindowNumbers.length;
      
      // 혼잡도 계산 (창구 정보가 없으면 알 수 없음으로 처리)
      CongestionLevel level;
      if (activeWindows == 0) {
        level = CongestionLevel.unknown;
      } else {
        final avgPerWindow = totalWaitingCount / activeWindows;
        if (avgPerWindow > 10) {
          level = CongestionLevel.high;
        } else if (avgPerWindow > 5) {
          level = CongestionLevel.medium;
        } else {
          level = CongestionLevel.low;
        }
      }

      // 4. 앱에서 사용할 최종 CsoStatus 엔티티로 매핑
      final allInfoItems = infoDtoResult.body.items?.item ?? [];
      final infoItem = allInfoItems.where((e) => e.csoSn == csoSn).firstOrNull;

      // CsoInfo 엔티티로 변환
      CsoInfo? locationInfo;
      if (infoItem != null) {
        String? operatingHoursStr;
        if (infoItem.wkdyOperBgngTm != null && infoItem.wkdyOperEndTm != null && 
            infoItem.wkdyOperBgngTm!.length >= 4 && infoItem.wkdyOperEndTm!.length >= 4) {
          final start = _formatTime(infoItem.wkdyOperBgngTm!);
          final end = _formatTime(infoItem.wkdyOperEndTm!);
          operatingHoursStr = '$start — $end';
        }

        locationInfo = CsoInfo(
          csoSn: infoItem.csoSn ?? '',
          csoNm: infoItem.csoNm ?? '이름 없음',
          address: infoItem.roadNmAddr ?? '',
          latitude: double.tryParse(infoItem.lat ?? '0') ?? 0.0,
          longitude: double.tryParse(infoItem.lot ?? '0') ?? 0.0,
          operatingHoursStr: operatingHoursStr ?? '09:00 — 18:00',
          isNightOperating: infoItem.nghtOperYn == 'Y',
          isWeekendOperating: infoItem.wkndOperYn == 'Y',
          nightOperatingExpln: infoItem.nghtDowExpln,
          weekendOperatingExpln: infoItem.wkndDowExpln,
        );
      }

      // 4. 앱에서 사용할 최종 CsoStatus 엔티티로 매핑
      final status = CsoStatus(
        csoNm: locationInfo?.csoNm ?? realtimeItems.firstOrNull?.csoNm ?? '민원실',
        totalWaitingCount: totalWaitingCount,
        expectedWaitTimeMinutes: totalWaitingCount * 3,
        congestionLevel: level,
        operatingWindows: activeWindows,
        avgWaitingPerWindow: totalWaitingCount / activeWindows,
        updatedAt: DateTime.now(),
        taskStatuses: taskStatuses,
        locationInfo: locationInfo,
      );

      return Result.success(status);

    } on DioException catch (e) {
      return Result.failure(AppFailure('네트워크 통신 중 오류가 발생했습니다.', originalError: e));
    } catch (e) {
      return Result.failure(AppFailure('데이터를 불러오는데 실패했습니다.', originalError: e));
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.length >= 4) {
      final hour = timeStr.substring(0, 2);
      final minute = timeStr.substring(2, 4);
      return '$hour:$minute';
    }
    return timeStr;
  }
}
