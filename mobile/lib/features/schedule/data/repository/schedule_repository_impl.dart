import 'package:flutter/material.dart';

import '../../domain/enum/schedule_block_type.dart';
import '../../domain/enum/schedule_recurrence_type.dart';
import '../../domain/entities/schedule_block.dart';
import '../../domain/entities/schedule_select_option.dart';
import '../../domain/repository/schedule_repository.dart';
import '../../domain/entities/schedule_surface.dart';
import '../datasource/schedule_remote_datasource.dart';
import '../dto/create_schedule_block_request_dto.dart';
import '../dto/update_schedule_block_request_dto.dart';
import '../mapper/schedule_mapper.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final ScheduleRemoteDataSource remoteDataSource;
  final ScheduleMapper mapper;

  const ScheduleRepositoryImpl({
    required this.remoteDataSource,
    required this.mapper,
  });

  // ==========================================
  // QUERIES & BFF SURFACES (READ)
  // ==========================================

  @override
  Future<ScheduleSurfaceOverview> getSurfaces({required DateTime date}) async {
    final dto = await remoteDataSource.getSurfaces(date);
    return mapper.toSurfaceDomain(dto);
  }

  @override
  Future<List<ScheduleSelectOption>> getSelectOptions() async {
    // Dropdowns require the effective active options for today
    final today = DateTime.now();
    final dtos = await remoteDataSource.getSelectOptions(date: today);
    return dtos.map(mapper.toSelectOptionDomain).toList();
  }

  @override
  Future<ScheduleBlock?> getScheduleBlockById({required String id}) async {
    // Directly query the backend for the specific ID instead of fetching all
    final dto = await remoteDataSource.getScheduleBlockById(id);
    return mapper.toBlockDomain(dto);
  }

  // ==========================================
  // MUTATIONS (WRITE)
  // ==========================================

  @override
  Future<ScheduleBlock> createScheduleBlock({
    required String title,
    required ScheduleBlockType type,
    String? description,
    required ScheduleRecurrenceType recurrenceType,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
  }) async {
    final recurrenceDaysPayload = _toRecurrenceDaysPayload(
      recurrenceType: recurrenceType,
      daysOfWeek: daysOfWeek,
    );

    final dto = await remoteDataSource.createScheduleBlock(
      CreateScheduleBlockRequestDto(
        title: title,
        type: type.apiValue,
        description: _nullIfBlank(description),
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        recurrenceType: recurrenceType.apiValue,
        recurrenceDaysOfWeek: recurrenceDaysPayload,
        recurrenceStartDate: _formatDate(recurrenceStartDate),
        recurrenceEndDate: _formatNullableDate(recurrenceEndDate),
      ),
    );

    return mapper.toBlockDomain(dto);
  }

  @override
  Future<ScheduleBlock> updateScheduleBlock({
    required String id,
    required String title,
    required ScheduleBlockType type,
    String? description,
    required ScheduleRecurrenceType recurrenceType,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required List<int> daysOfWeek,
    required DateTime recurrenceStartDate,
    DateTime? recurrenceEndDate,
    bool? active,
  }) async {
    final recurrenceDaysPayload = _toRecurrenceDaysPayload(
      recurrenceType: recurrenceType,
      daysOfWeek: daysOfWeek,
    );

    final dto = await remoteDataSource.updateScheduleBlock(
      id: id,
      request: UpdateScheduleBlockRequestDto(
        title: title,
        type: type.apiValue,
        description: _nullIfBlank(description),
        startTime: _formatTime(startTime),
        endTime: _formatTime(endTime),
        recurrenceType: recurrenceType.apiValue,
        recurrenceDaysOfWeek: recurrenceDaysPayload,
        recurrenceStartDate: _formatDate(recurrenceStartDate),
        recurrenceEndDate: _formatNullableDate(recurrenceEndDate),
        active: active,
      ),
    );

    return mapper.toBlockDomain(dto);
  }

  @override
  Future<void> deleteScheduleBlock(String id) async {
    await remoteDataSource.deleteScheduleBlock(id);
  }

  @override
  Future<void> deactivateScheduleBlock(String id) async {
    await remoteDataSource.deactivateScheduleBlock(id);
  }

  @override
  Future<void> activateScheduleBlock(String id) async {
    await remoteDataSource.activateScheduleBlock(id);
  }

  // ==========================================
  // UTILS
  // ==========================================

  List<int> _normalizeDays(List<int> daysOfWeek) {
    return daysOfWeek.toSet().toList()..sort();
  }

  String? _toRecurrenceDaysPayload({
    required ScheduleRecurrenceType recurrenceType,
    required List<int> daysOfWeek,
  }) {
    if (recurrenceType != ScheduleRecurrenceType.customWeekly) {
      return null;
    }

    final normalizedDays = _normalizeDays(daysOfWeek);
    if (normalizedDays.isEmpty) return null;

    final names = normalizedDays
        .map((value) => _toDayOfWeekName(value))
        .whereType<String>()
        .toList(growable: false);
    return names.isEmpty ? null : names.join(',');
  }

  String? _nullIfBlank(String? value) {
    final text = (value ?? '').trim();
    return text.isEmpty ? null : text;
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String? _formatNullableDate(DateTime? date) {
    if (date == null) return null;
    return _formatDate(date);
  }

  String? _toDayOfWeekName(int value) {
    switch (value) {
      case 1:
        return 'MONDAY';
      case 2:
        return 'TUESDAY';
      case 3:
        return 'WEDNESDAY';
      case 4:
        return 'THURSDAY';
      case 5:
        return 'FRIDAY';
      case 6:
        return 'SATURDAY';
      case 7:
        return 'SUNDAY';
      default:
        return null;
    }
  }

  String _formatTime(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m:00';
  }
}