import '../../domain/entities/schedule_select_option.dart';
import '../dto/schedule_select_option_dto.dart';

class ScheduleSelectOptionMapper {
  const ScheduleSelectOptionMapper();

  ScheduleSelectOption toDomain(ScheduleSelectOptionDto dto) {
    final id = (dto.scheduleBlockId ?? dto.value ?? '').trim();

    return ScheduleSelectOption(
      value: (dto.value ?? id).trim(),
      scheduleBlockId: id,
      label: (dto.label ?? dto.title ?? 'Schedule block').trim(),
      title: (dto.title ?? '').trim(),
      type: (dto.type ?? 'OTHER').trim(),
      startTime: (dto.startTime ?? '').trim(),
      endTime: (dto.endTime ?? '').trim(),
      active: dto.active ?? false,
    );
  }
}
