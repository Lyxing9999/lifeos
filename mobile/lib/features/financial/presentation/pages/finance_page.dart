import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../../../core/widgets/day_navigator_header.dart';
import '../../../auth/application/auth_providers.dart';
import '../../../user/application/user_providers.dart';
import '../../application/financial_providers.dart';
import '../../application/financial_state.dart';
import '../../domain/model/financial_event.dart';
import '../../domain/model/payway_callback_log.dart';
import '../../domain/model/payway_payment_link.dart';

class FinancePage extends ConsumerStatefulWidget {
  const FinancePage({super.key});

  @override
  ConsumerState<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends ConsumerState<FinancePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId.isEmpty) return;

    if (ref.read(userNotifierProvider).profile == null) {
      await ref.read(userNotifierProvider.notifier).loadProfile(userId);
    }

    final timezone = _timezone;

    await ref
        .read(financialNotifierProvider.notifier)
        .load(
          userId: userId,
          date: ref.read(financialNotifierProvider).selectedDate,
          timezone: timezone,
        );
  }

  String get _timezone {
    final profile = ref.read(userNotifierProvider).profile;
    return (profile?.timezone ?? '').trim().isNotEmpty
        ? profile!.timezone
        : 'Asia/Phnom_Penh';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(financialNotifierProvider);
    final userId = ref.read(currentUserIdProvider);
    final timezone = _timezone;

    ref.listen(financialNotifierProvider, (previous, next) {
      if (next.successMessage != null &&
          next.successMessage != previous?.successMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.successMessage!)));
      }

      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.errorMessage!)));
      }
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _load,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const AppPageHeader(
              title: 'Spending',
              subtitle: 'Spending summary and recent activity',
            ),
            SliverToBoxAdapter(
              child: DayNavigatorHeader(
                date: state.selectedDate,
                subtitle: state.dayEvents.isNotEmpty
                    ? '${state.dayEvents.length} events'
                    : null,
                isLoadingDay: state.isLoading,
                onPreviousDay: () async {
                  await ref
                      .read(financialNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.subtract(
                          const Duration(days: 1),
                        ),
                        timezone: timezone,
                      );
                },
                onNextDay: () async {
                  await ref
                      .read(financialNotifierProvider.notifier)
                      .changeDay(
                        userId: userId,
                        date: state.selectedDate.add(const Duration(days: 1)),
                        timezone: timezone,
                      );
                },
              ),
            ),
            if (state.isLoading &&
                state.daySummary == null &&
                state.dayEvents.isEmpty &&
                state.callbackLogs.isEmpty)
              const SliverFillRemaining(child: AppLoadingView())
            else
              SliverPadding(
                padding: EdgeInsets.only(
                  left: AppSpacing.pageHorizontal,
                  right: AppSpacing.pageHorizontal,
                  top: AppSpacing.sm,
                  bottom: AppSpacing.navBarClearance(context),
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _SummaryCard(state: state),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _RecentRangeCard(events: state.rangeEvents),
                    const SizedBox(height: AppSpacing.sectionGap),
                    _SectionHeader(
                      title: 'Spending events',
                      subtitle: state.dayEvents.isEmpty
                          ? 'No spending activity recorded for this day yet.'
                          : '${state.dayEvents.length} event${state.dayEvents.length == 1 ? '' : 's'} on ${DateFormat('dd MMM').format(state.selectedDate)}',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (state.dayEvents.isEmpty)
                      const Card(
                        child: Padding(
                          padding: AppSpacing.cardInsets,
                          child: AppEmptyView(
                            icon: Icons.payments_outlined,
                            title: 'No spending activity yet',
                            subtitle:
                                'Spending events will appear here once transactions are available for this day.',
                            centered: false,
                          ),
                        ),
                      )
                    else
                      ...state.dayEvents.map(
                        (event) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.listItemGap,
                          ),
                          child: _FinancialEventCard(
                            event: event,
                            onDelete: () => _confirmDeleteEvent(
                              context,
                              userId: userId,
                              timezone: timezone,
                              event: event,
                            ),
                          ),
                        ),
                      ),
                    if (kDebugMode) ...[
                      const SizedBox(height: AppSpacing.sectionGap),
                      _QuickActionsCard(
                        isSaving: state.isSaving,
                        onImportCsv: () => _pickAndImportCsv(userId, timezone),
                        onPollPayWay: () async {
                          await ref
                              .read(financialNotifierProvider.notifier)
                              .pollPayWay(userId: userId, timezone: timezone);
                        },
                        onCreateLink: () => _showCreatePaymentLinkSheet(userId),
                        onSendCallback: () => _showCallbackSheet(
                          userId: userId,
                          timezone: timezone,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _LatestPaymentLinkCard(
                        link: state.latestPaymentLink,
                        onOpen: state.latestPaymentLink == null
                            ? null
                            : () => _openUrl(
                                state.latestPaymentLink!.paymentLink,
                              ),
                        onCopy: state.latestPaymentLink == null
                            ? null
                            : () => _copyToClipboard(
                                context,
                                state.latestPaymentLink!.paymentLink,
                                'Payment link copied',
                              ),
                      ),
                      const SizedBox(height: AppSpacing.sectionGap),
                      _SectionHeader(
                        title: 'Callback logs',
                        subtitle: state.callbackLogs.isEmpty
                            ? 'No callback traffic recorded yet.'
                            : '${state.callbackLogs.length} recorded callback${state.callbackLogs.length == 1 ? '' : 's'}',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (state.callbackLogs.isEmpty)
                        const Card(
                          child: Padding(
                            padding: AppSpacing.cardInsets,
                            child: AppEmptyView(
                              icon: Icons.receipt_long_outlined,
                              title: 'No callback logs',
                              subtitle:
                                  'Callback traffic will appear here when the backend receives it.',
                              centered: false,
                            ),
                          ),
                        )
                      else
                        ...state.callbackLogs
                            .take(6)
                            .map(
                              (log) => Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.listItemGap,
                                ),
                                child: _CallbackLogCard(log: log),
                              ),
                            ),
                    ],
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndImportCsv(String userId, String timezone) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv'],
      withData: true,
    );

    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null || bytes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No CSV file selected.')));
      return;
    }

    await ref
        .read(financialNotifierProvider.notifier)
        .importCsv(
          userId: userId,
          timezone: timezone,
          bytes: bytes,
          fileName: file.name,
        );
  }

  Future<void> _showCreatePaymentLinkSheet(String userId) async {
    final titleCtrl = TextEditingController(text: 'LifeOS test payment');
    final amountCtrl = TextEditingController(text: '2.50');
    final currencyCtrl = TextEditingController(text: 'USD');
    final descriptionCtrl = TextEditingController(text: 'LifeOS mobile test');
    final paymentLimitCtrl = TextEditingController();
    final expiredDateCtrl = TextEditingController();
    final merchantRefCtrl = TextEditingController(
      text: 'lifeos-mobile-${DateTime.now().millisecondsSinceEpoch}',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create PayWay link',
                  style: AppTextStyles.cardTitle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'This hits `/financial-provider/payway/payment-link/create/{userId}` with the exact backend payload.',
                  style: AppTextStyles.bodySecondary(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _LabeledField(controller: titleCtrl, label: 'Title'),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        controller: amountCtrl,
                        label: 'Amount',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _LabeledField(
                        controller: currencyCtrl,
                        label: 'Currency',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _LabeledField(
                  controller: descriptionCtrl,
                  label: 'Description',
                ),
                const SizedBox(height: AppSpacing.md),
                _LabeledField(
                  controller: merchantRefCtrl,
                  label: 'Merchant ref no',
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _LabeledField(
                        controller: paymentLimitCtrl,
                        label: 'Payment limit',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _LabeledField(
                        controller: expiredDateCtrl,
                        label: 'Expired date',
                        hintText: 'Optional raw value',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: 'Create Payment Link',
                    icon: Icons.link,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(financialNotifierProvider.notifier)
                          .createPaymentLink(
                            userId: userId,
                            title: titleCtrl.text.trim(),
                            amount: amountCtrl.text.trim(),
                            currency: currencyCtrl.text.trim(),
                            description: _emptyToNull(descriptionCtrl.text),
                            paymentLimit: _emptyToNull(paymentLimitCtrl.text),
                            expiredDate: _emptyToNull(expiredDateCtrl.text),
                            merchantRefNo: _emptyToNull(merchantRefCtrl.text),
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showCallbackSheet({
    required String userId,
    required String timezone,
  }) async {
    final latestLink = ref.read(financialNotifierProvider).latestPaymentLink;
    final tranIdCtrl = TextEditingController(text: latestLink?.tranId ?? '');
    final merchantRefCtrl = TextEditingController(
      text: latestLink?.merchantRefNo ?? '',
    );
    final statusCtrl = TextEditingController(text: '0');
    final apvCtrl = TextEditingController(text: '993329');

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send PayWay callback',
                  style: AppTextStyles.cardTitle(context),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Useful for local end-to-end testing when you want Flutter to trigger the callback controller directly.',
                  style: AppTextStyles.bodySecondary(context),
                ),
                const SizedBox(height: AppSpacing.lg),
                _LabeledField(controller: tranIdCtrl, label: 'tran_id'),
                const SizedBox(height: AppSpacing.md),
                _LabeledField(
                  controller: merchantRefCtrl,
                  label: 'merchant_ref_no',
                ),
                const SizedBox(height: AppSpacing.md),
                _LabeledField(
                  controller: statusCtrl,
                  label: 'status',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: AppSpacing.md),
                _LabeledField(controller: apvCtrl, label: 'apv'),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.secondary(
                    label: 'Send Callback',
                    icon: Icons.send_outlined,
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await ref
                          .read(financialNotifierProvider.notifier)
                          .simulateCallback(
                            userId: userId,
                            tranId: tranIdCtrl.text.trim(),
                            merchantRefNo: merchantRefCtrl.text.trim(),
                            status: int.tryParse(statusCtrl.text.trim()) ?? 0,
                            apv: _emptyToNull(apvCtrl.text),
                            timezone: timezone,
                          );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDeleteEvent(
    BuildContext context, {
    required String userId,
    required String timezone,
    required FinancialEvent event,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete financial event?'),
          content: Text(
            'This will remove ${event.displayMerchantName} from the current backend dataset.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await ref
        .read(financialNotifierProvider.notifier)
        .deleteEvent(userId: userId, eventId: event.id, timezone: timezone);
  }

  Future<void> _openUrl(String rawUrl) async {
    final url = Uri.tryParse(rawUrl);
    if (url == null) return;
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

  Future<void> _copyToClipboard(
    BuildContext context,
    String value,
    String message,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String? _emptyToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SummaryCard extends StatelessWidget {
  final FinancialState state;

  const _SummaryCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final summary = state.daySummary;
    final latestLabel =
        summary == null || summary.latestMerchantName.trim().isEmpty
        ? 'No recent merchant'
        : summary.latestMerchantName;
    final latestAmount = summary?.latestAmount;
    final latestCurrency = summary?.latestCurrency ?? '';

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SectionIcon(
                  icon: Icons.account_balance_wallet_outlined,
                  color: AppColors.sky,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Spending summary',
                        style: AppTextStyles.cardTitle(context),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'A quick read on what you spent and where',
                        style: AppTextStyles.bodySecondary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: 'Spent',
                    value:
                        '${(summary?.totalOutgoingAmount ?? 0).toStringAsFixed(2)} ${summary?.totalEvents == 0 ? '' : latestCurrency}'
                            .trim(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricBlock(
                    label: 'Events',
                    value: '${summary?.totalEvents ?? state.dayEvents.length}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricBlock(
                    label: 'Latest',
                    value: latestAmount == null
                        ? latestLabel
                        : '${latestAmount.toStringAsFixed(2)} $latestCurrency',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(latestLabel, style: AppTextStyles.cardTitle(context)),
            if ((summary?.summaryText ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                summary!.summaryText,
                style: AppTextStyles.bodySecondary(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onImportCsv;
  final VoidCallback onPollPayWay;
  final VoidCallback onCreateLink;
  final VoidCallback onSendCallback;

  const _QuickActionsCard({
    required this.isSaving,
    required this.onImportCsv,
    required this.onPollPayWay,
    required this.onCreateLink,
    required this.onSendCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Developer tools', style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'These actions map directly to import, polling, payment-link, and callback endpoints.',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                AppButton.secondary(
                  label: 'Import CSV',
                  icon: Icons.upload_file_outlined,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onImportCsv,
                ),
                AppButton.secondary(
                  label: 'Poll PayWay',
                  icon: Icons.sync_outlined,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onPollPayWay,
                ),
                AppButton.primary(
                  label: 'Create Link',
                  icon: Icons.link,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onCreateLink,
                ),
                AppButton.secondary(
                  label: 'Send Callback',
                  icon: Icons.send_outlined,
                  isLoading: isSaving,
                  onPressed: isSaving ? null : onSendCallback,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentRangeCard extends StatelessWidget {
  final List<FinancialEvent> events;

  const _RecentRangeCard({required this.events});

  @override
  Widget build(BuildContext context) {
    final outgoing = events
        .where((event) => event.isOutgoingType)
        .fold<double>(0, (sum, event) => sum + event.amount);
    final latest = events.isEmpty ? null : events.first;

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent range', style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'A seven-day snapshot of spending activity.',
              style: AppTextStyles.bodySecondary(context),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _MetricBlock(
                    label: '7d events',
                    value: '${events.length}',
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricBlock(
                    label: '7d spent',
                    value: outgoing.toStringAsFixed(2),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _MetricBlock(
                    label: 'Latest merchant',
                    value: latest?.displayMerchantName ?? '—',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestPaymentLinkCard extends StatelessWidget {
  final PayWayPaymentLink? link;
  final VoidCallback? onOpen;
  final VoidCallback? onCopy;

  const _LatestPaymentLinkCard({
    required this.link,
    required this.onOpen,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latest payment link',
              style: AppTextStyles.cardTitle(context),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (link == null)
              Text(
                'Create a payment link to test the hosted checkout flow.',
                style: AppTextStyles.bodySecondary(context),
              )
            else ...[
              Text(link!.title, style: AppTextStyles.cardTitle(context)),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${link!.amount?.toStringAsFixed(2) ?? '0.00'} ${link!.currency} · ref ${link!.merchantRefNo}',
                style: AppTextStyles.bodySecondary(context),
              ),
              if ((link!.statusMessage ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  link!.statusMessage!,
                  style: AppTextStyles.bodySecondary(context),
                ),
              ],
              if (link!.paymentLink.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    AppButton.primary(
                      label: 'Open Link',
                      icon: Icons.open_in_new,
                      onPressed: onOpen,
                    ),
                    AppButton.secondary(
                      label: 'Copy URL',
                      icon: Icons.copy_outlined,
                      onPressed: onCopy,
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _FinancialEventCard extends StatelessWidget {
  final FinancialEvent event;
  final VoidCallback onDelete;

  const _FinancialEventCard({required this.event, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final paidAt = event.paidAt;
    final timeLabel = paidAt == null
        ? 'Unknown time'
        : DateFormat('h:mm a').format(paidAt.toLocal());
    final color = _eventColor(event.category);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionIcon(icon: Icons.payments_outlined, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.displayMerchantName,
                          style: AppTextStyles.cardTitle(context),
                        ),
                      ),
                      Text(
                        '${event.amount.toStringAsFixed(2)} ${event.currency}',
                        style: AppTextStyles.cardTitle(
                          context,
                        ).copyWith(color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${event.category} · $timeLabel',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  if ((event.description ?? '').trim().isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      event.description!,
                      style: AppTextStyles.bodySecondary(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              onPressed: onDelete,
              tooltip: 'Delete event',
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  Color _eventColor(String category) {
    switch (category.toUpperCase()) {
      case 'FOOD':
        return AppColors.green;
      case 'TRANSPORT':
        return AppColors.amber;
      case 'SHOPPING':
        return AppColors.sky;
      case 'TRAVEL':
        return AppColors.violet;
      default:
        return AppColors.sky;
    }
  }
}

class _CallbackLogCard extends StatelessWidget {
  final PayWayCallbackLog log;

  const _CallbackLogCard({required this.log});

  @override
  Widget build(BuildContext context) {
    final createdAt = log.createdAt;
    final createdLabel = createdAt == null
        ? 'Unknown time'
        : DateFormat('dd MMM, h:mm a').format(createdAt);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _SectionIcon(
                  icon: log.processed
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: log.processed ? AppColors.green : AppColors.amber,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.transactionId.isEmpty
                            ? 'No transaction id'
                            : log.transactionId,
                        style: AppTextStyles.cardTitle(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${log.merchantRefNo} · $createdLabel',
                        style: AppTextStyles.bodySecondary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if ((log.processingError ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                log.processingError!,
                style: AppTextStyles.bodySecondary(
                  context,
                ).copyWith(color: AppColors.danger),
              ),
            ],
            if (log.rawPayloadJson.trim().isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              SelectableText(
                log.rawPayloadJson,
                style: AppTextStyles.metaLabel(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricBlock extends StatelessWidget {
  final String label;
  final String value;

  const _MetricBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.metaLabel(context)),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.cardTitle(context),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.cardTitle(context)),
        const SizedBox(height: 2),
        Text(subtitle, style: AppTextStyles.bodySecondary(context)),
      ],
    );
  }
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SectionIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;

  const _LabeledField({
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.metaLabel(context)),
        const SizedBox(height: AppSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(hintText: hintText),
        ),
      ],
    );
  }
}
