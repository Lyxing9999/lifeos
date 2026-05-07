import '../../../core/enums/loading_status.dart';
import '../domain/model/financial_event.dart';
import '../domain/model/financial_summary.dart';
import '../domain/model/payway_callback_log.dart';
import '../domain/model/payway_payment_link.dart';

const _unset = Object();

class FinancialState {
  final LoadingStatus status;
  final DateTime selectedDate;
  final List<FinancialEvent> dayEvents;
  final List<FinancialEvent> rangeEvents;
  final FinancialSummary? daySummary;
  final PayWayPaymentLink? latestPaymentLink;
  final List<PayWayCallbackLog> callbackLogs;
  final String? errorMessage;
  final String? successMessage;

  const FinancialState({
    required this.status,
    required this.selectedDate,
    required this.dayEvents,
    required this.rangeEvents,
    required this.daySummary,
    required this.latestPaymentLink,
    required this.callbackLogs,
    required this.errorMessage,
    required this.successMessage,
  });

  bool get isIdle => status.isIdle;
  bool get isLoading => status.isLoading;
  bool get isSaving => status.isSaving;
  bool get isSuccess => status.isSuccess;
  bool get isError => status.isError;

  factory FinancialState.initial() {
    return FinancialState(
      status: LoadingStatus.idle,
      selectedDate: DateTime.now(),
      dayEvents: const [],
      rangeEvents: const [],
      daySummary: null,
      latestPaymentLink: null,
      callbackLogs: const [],
      errorMessage: null,
      successMessage: null,
    );
  }

  FinancialState copyWith({
    LoadingStatus? status,
    DateTime? selectedDate,
    List<FinancialEvent>? dayEvents,
    List<FinancialEvent>? rangeEvents,
    Object? daySummary = _unset,
    Object? latestPaymentLink = _unset,
    List<PayWayCallbackLog>? callbackLogs,
    Object? errorMessage = _unset,
    Object? successMessage = _unset,
  }) {
    return FinancialState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      dayEvents: dayEvents ?? this.dayEvents,
      rangeEvents: rangeEvents ?? this.rangeEvents,
      daySummary: identical(daySummary, _unset)
          ? this.daySummary
          : daySummary as FinancialSummary?,
      latestPaymentLink: identical(latestPaymentLink, _unset)
          ? this.latestPaymentLink
          : latestPaymentLink as PayWayPaymentLink?,
      callbackLogs: callbackLogs ?? this.callbackLogs,
      errorMessage: identical(errorMessage, _unset)
          ? this.errorMessage
          : errorMessage as String?,
      successMessage: identical(successMessage, _unset)
          ? this.successMessage
          : successMessage as String?,
    );
  }
}
