import 'package:flutter/material.dart';

import '../../domain/enum/schedule_block_type.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/schedule_occurrence.dart';
import '../../domain/entities/schedule_select_option.dart';
import '../../domain/entities/schedule_surface.dart';
import '../../domain/entities/schedule_count_summary.dart';
import '../dto/schedule_surface_response_dto.dart';
import '../dto/schedule_block_response_dto.dart';
import '../dto/schedule_occurrence_response_dto.dart';
import '../dto/schedule_select_option_response_dto.dart';

class ScheduleMapper {
  const ScheduleMapper();

  ScheduleBlock toBlockDomain(ScheduleBlockResponseDto dto) {
    return ScheduleBlock(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      title: dto.title ?? '',
      type: ScheduleBlockTypeX.fromApi(dto.type ?? 'OTHER'),
      description: dto.description,
      startTime: _parseTimeOfDay(dto.startTime),
      endTime: _parseTimeOfDay(dto.endTime),
      recurrenceType: ScheduleRecurrenceTypeX.fromApi(
        dto.recurrenceType ?? 'NONE',
      ),
      recurrenceStartDate: _parseRequiredDate(dto.recurrenceStartDate),
      recurrenceEndDate: _parseDate(dto.recurrenceEndDate),
      recurrenceDaysOfWeek: _parseDays(dto.recurrenceDaysOfWeek),
      active: dto.active ?? true,

      archived: dto.archived ?? false, // <-- ADD THIS LINE
    );
  }

  ScheduleOccurrence toOccurrenceDomain(ScheduleOccurrenceResponseDto dto) {
    return ScheduleOccurrence(
      scheduleBlockId: dto.scheduleBlockId ?? '',
      userId: dto.userId ?? '',
      title: dto.title ?? '',
      type: ScheduleBlockTypeX.fromApi(dto.type ?? 'OTHER'),
      recurrenceType: ScheduleRecurrenceTypeX.fromApi(
        dto.recurrenceType ?? 'NONE',
      ), // ADD THIS
      occurrenceDate:
          DateTime.tryParse(dto.occurrenceDate ?? '') ?? DateTime.now(),
      startDateTime:
          DateTime.tryParse(dto.startDateTime ?? '') ?? DateTime.now(),
      endDateTime: DateTime.tryParse(dto.endDateTime ?? '') ?? DateTime.now(),
    );
  }

  ScheduleSelectOption toSelectOptionDomain(
    ScheduleSelectOptionResponseDto dto,
  ) {
    final scheduleBlockId = dto.scheduleBlockId ?? dto.value ?? '';

    return ScheduleSelectOption(
      value: dto.value ?? scheduleBlockId,
      scheduleBlockId: scheduleBlockId,
      label: dto.label ?? dto.title ?? 'Untitled schedule',
      title: dto.title ?? '',
      type: ScheduleBlockTypeX.fromApi(dto.type ?? 'OTHER'),
      startTime: _parseTimeOfDay(dto.startTime),
      endTime: _parseTimeOfDay(dto.endTime),
      active: dto.active ?? true,
    );
  }

  DateTime? _parseDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  DateTime _parseRequiredDate(String? raw) {
    final parsed = _parseDate(raw);
    if (parsed != null) return parsed;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  TimeOfDay _parseTimeOfDay(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final parts = raw.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return TimeOfDay(hour: hour, minute: minute);
  }

  List<int> _parseDays(Object? raw) {
    if (raw == null) return const [];

    final tokens = switch (raw) {
      String value => value.split(','),
      List<dynamic> values =>
        values.map((value) => value?.toString() ?? '').toList(growable: false),
      _ => [raw.toString()],
    };

    final result = <int>[];
    for (final token in tokens) {
      final value = token.trim();
      if (value.isEmpty) continue;

      final number = int.tryParse(value);
      if (number != null && number >= 1 && number <= 7) {
        result.add(number);
        continue;
      }

      final day = _fromDayName(value);
      if (day != null) {
        result.add(day);
      }
    }

    return result.toSet().toList()..sort();
  }

  ScheduleSurfaceOverview toSurfaceDomain(ScheduleSurfaceResponseDto dto) {
    final parsedDate = _parseDate(dto.date) ?? DateTime.now();
    final localDate = DateTime(
      parsedDate.year,
      parsedDate.month,
      parsedDate.day,
    );

    return ScheduleSurfaceOverview(
      date: localDate,
      activeBlocks: dto.activeBlocks.map(toBlockDomain).toList(),
      inactiveBlocks: dto.inactiveBlocks.map(toBlockDomain).toList(),
      historyBlocks: (dto.historyBlocks ?? []).map(toBlockDomain).toList(),
      counts: ScheduleCountSummary(
        total: dto.counts?.total ?? 0,
        active: dto.counts?.active ?? 0,
        inactive: dto.counts?.inactive ?? 0,
        history: dto.counts?.history ?? 0,
      ),
    );
  }

  int? _fromDayName(String raw) {
    switch (raw.toUpperCase()) {
      case 'MONDAY':
      case 'MON':
        return 1;
      case 'TUESDAY':
      case 'TUE':
        return 2;
      case 'WEDNESDAY':
      case 'WED':
        return 3;
      case 'THURSDAY':
      case 'THU':
        return 4;
      case 'FRIDAY':
      case 'FRI':
        return 5;
      case 'SATURDAY':
      case 'SAT':
        return 6;
      case 'SUNDAY':
      case 'SUN':
        return 7;
      default:
        return null;
    }
  }
}
