import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/loading_status.dart';
import '../../../core/error/error_mapper.dart';
import '../domain/model/financial_event.dart';
import '../domain/model/financial_summary.dart';
import '../domain/model/payway_callback_log.dart';
import '../domain/repository/financial_repository.dart';
import 'financial_state.dart';

class FinancialNotifier extends StateNotifier<FinancialState> {
  final FinancialRepository repository;

  FinancialNotifier(this.repository) : super(FinancialState.initial());

  Future<void> load({
    required String userId,
    required DateTime date,
    required String timezone,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.loading,
      selectedDate: date,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final rangeStart = date.subtract(const Duration(days: 6));
      final results = await Future.wait<dynamic>([
        repository.getDaySummary(
          userId: userId,
          date: date,
          timezone: timezone,
        ),
        repository.getEventsByDay(
          userId: userId,
          date: date,
          timezone: timezone,
        ),
        repository.getEventsByRange(
          userId: userId,
          startDate: rangeStart,
          endDate: date,
          timezone: timezone,
        ),
        repository.getCallbackLogs(userId),
      ]);

      final summary = results[0] as FinancialSummary;
      final dayEvents = _sortEvents(results[1] as List<FinancialEvent>);
      final rangeEvents = _sortEvents(results[2] as List<FinancialEvent>);
      final callbackLogs = List<PayWayCallbackLog>.from(
        results[3] as List<PayWayCallbackLog>,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        selectedDate: date,
        daySummary: summary,
        dayEvents: dayEvents,
        rangeEvents: rangeEvents,
        callbackLogs: callbackLogs,
        errorMessage: null,
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        daySummary: null,
        dayEvents: const [],
        rangeEvents: const [],
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> changeDay({
    required String userId,
    required DateTime date,
    required String timezone,
  }) async {
    await load(userId: userId, date: date, timezone: timezone);
  }

  Future<void> deleteEvent({
    required String userId,
    required String eventId,
    required String timezone,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.deleteEvent(eventId);
      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: 'Financial event deleted',
      );
      await load(userId: userId, date: state.selectedDate, timezone: timezone);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> importCsv({
    required String userId,
    required String timezone,
    required List<int> bytes,
    required String fileName,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final message = await repository.importCsv(
        userId: userId,
        timezone: timezone,
        bytes: bytes,
        fileName: fileName,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: message,
      );
      await load(userId: userId, date: state.selectedDate, timezone: timezone);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> createPaymentLink({
    required String userId,
    required String title,
    required String amount,
    required String currency,
    String? description,
    String? paymentLimit,
    String? expiredDate,
    String? merchantRefNo,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final link = await repository.createPaymentLink(
        userId: userId,
        title: title,
        amount: amount,
        currency: currency,
        description: description,
        paymentLimit: paymentLimit,
        expiredDate: expiredDate,
        merchantRefNo: merchantRefNo,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        latestPaymentLink: link,
        successMessage: 'PayWay payment link created',
      );
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> simulateCallback({
    required String userId,
    required String tranId,
    required String merchantRefNo,
    required int status,
    String? apv,
    required String timezone,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await repository.simulateCallback(
        userId: userId,
        tranId: tranId,
        merchantRefNo: merchantRefNo,
        status: status,
        apv: apv,
      );

      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage: 'PayWay callback sent',
      );
      await load(userId: userId, date: state.selectedDate, timezone: timezone);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  Future<void> pollPayWay({
    required String userId,
    required String timezone,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    state = state.copyWith(
      status: LoadingStatus.saving,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final results = await repository.pollPayWay(
        userId: userId,
        fromDate: fromDate ?? state.selectedDate,
        toDate: toDate ?? state.selectedDate,
        timezone: timezone,
      );

      final count = results.length;
      state = state.copyWith(
        status: LoadingStatus.success,
        successMessage:
            'PayWay polling completed${count > 0 ? ' ($count event${count == 1 ? '' : 's'})' : ''}',
      );
      await load(userId: userId, date: state.selectedDate, timezone: timezone);
    } catch (error) {
      state = state.copyWith(
        status: LoadingStatus.error,
        errorMessage: ErrorMapper.message(error),
      );
    }
  }

  List<FinancialEvent> _sortEvents(List<FinancialEvent> events) {
    return List<FinancialEvent>.from(events)..sort((a, b) {
      final aTime = a.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.paidAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });
  }
}
