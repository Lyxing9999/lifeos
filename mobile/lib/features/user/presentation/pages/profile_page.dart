import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_icons.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../../../../core/content/product_terms.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_loading_view.dart';
import '../../../../core/widgets/app_page_header.dart';
import '../../application/user_providers.dart';
import '../../application/user_state.dart';
import '../widgets/theme_settings_section.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    await ref.read(userNotifierProvider.notifier).loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(userNotifierProvider);

    ref.listen(userNotifierProvider, (previous, next) {
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
            AppPageHeader(
              title: 'Profile',
              subtitle: 'Account, appearance, and daily defaults',
              actions: [
                if (state.profile != null)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.md),
                    child: IconButton(
                      icon: const Icon(AppIcons.edit),
                      tooltip: 'Edit profile',
                      onPressed: () async {
                        await context.push(ProfileRoutes.editPath());
                        if (mounted) await _load();
                      },
                    ),
                  ),
              ],
            ),
            _buildBody(context, state),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserState state) {
    if (state.isLoading && state.profile == null) {
      return const SliverFillRemaining(child: AppLoadingView());
    }

    if (state.errorMessage != null && state.profile == null) {
      return SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.profile,
          title: 'Failed to load profile',
          subtitle: state.errorMessage ?? 'Something went wrong.',
        ),
      );
    }

    final profile = state.profile;
    if (profile == null) {
      return const SliverFillRemaining(
        child: AppEmptyView(
          icon: AppIcons.profile,
          title: 'No profile found',
          subtitle: 'Your profile information will appear here.',
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.only(
        left: AppSpacing.pageHorizontal,
        right: AppSpacing.pageHorizontal,
        top: AppSpacing.xs, // Even tighter
        bottom: AppSpacing.navBarClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          const _SectionLabel('Account'),
          _ProfileHeroCard(name: profile.name, email: profile.email),
          const SizedBox(height: AppSpacing.sm),
          _ProfileInfoGroup(
            items: [
              _ProfileInfoRow(
                icon: AppIcons.email,
                iconColor: AppColors.green,
                label: 'Email',
                value: profile.email,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const _SectionLabel('Appearance'),
          const ThemeSettingsSection(),
          const SizedBox(height: AppSpacing.sectionGap),
          const _SectionLabel('Preferences'),
          _ProfileInfoGroup(
            items: [
              _ProfileInfoRow(
                icon: AppIcons.timezone,
                iconColor: AppColors.violet,
                label: 'Timezone',
                value: _readableTimezone(profile.timezone),
              ),
              _ProfileInfoRow(
                icon: AppIcons.language,
                iconColor: AppColors.sky,
                label: 'Language',
                value: _readableLocale(profile.locale),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const _SectionLabel('Daily tools'),
          _ProfileLinkGroup(
            items: [
              _ProfileLinkRow(
                icon: AppIcons.summary,
                iconColor: AppColors.violet,
                label: 'Daily reflection',
                subtitle: 'Read the day summary and key takeaways',
                onTap: () => context.push(AppRoutes.summary),
              ),
              _ProfileLinkRow(
                icon: AppIcons.spending,
                iconColor: AppColors.sky,
                label: 'Spending',
                subtitle: 'See where money moved through your day',
                onTap: () => context.push(FinanceRoutes.root),
              ),
              _ProfileLinkRow(
                icon: AppIcons.score,
                iconColor: AppColors.amber,
                label: ProductTerms.dailyScore,
                subtitle: 'Generate and inspect daily scoring signals',
                onTap: () => context.push(AppRoutes.score),
              ),
              _ProfileLinkRow(
                icon: AppIcons.place,
                iconColor: AppColors.green,
                label: 'Location logs',
                subtitle: 'Review raw location data for the selected day',
                onTap: () => context.push(AppRoutes.location),
              ),
              _ProfileLinkRow(
                icon: AppIcons.places,
                iconColor: AppColors.violet,
                label: 'Stay sessions',
                subtitle: 'Review derived stay sessions for the selected day',
                onTap: () => context.push(AppRoutes.staySessions),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const _SectionLabel('Structure'),
          _ProfileLinkGroup(
            items: [
              _ProfileLinkRow(
                icon: AppIcons.places,
                iconColor: AppColors.green,
                label: 'Places',
                subtitle: 'Manage saved places used by stay sessions',
                onTap: () => context.push(AppRoutes.places),
              ),
              _ProfileLinkRow(
                icon: AppIcons.schedule,
                iconColor: AppColors.sky,
                label: 'Schedule',
                subtitle: 'Manage recurring structure and planned blocks',
                onTap: () => context.push(ScheduleRoutes.root),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          const _SectionLabel('Import & sync'),
          _ProfileLinkGroup(
            items: [
              _ProfileLinkRow(
                icon: AppIcons.upload,
                iconColor: AppColors.indigo,
                label: 'Import & sync',
                subtitle: 'Manage data import and provider sync tools',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Import & sync — coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md), // Tighter
        ]),
      ),
    );
  }

  String _readableLocale(String locale) {
    switch (locale) {
      case 'km':
        return 'ខ្មែរ';
      case 'en':
      default:
        return 'English';
    }
  }

  String _readableTimezone(String timezone) {
    switch (timezone) {
      case 'Asia/Phnom_Penh':
        return 'Phnom Penh (UTC+7)';
      case 'Asia/Bangkok':
        return 'Bangkok (UTC+7)';
      case 'Asia/Singapore':
        return 'Singapore (UTC+8)';
      case 'Asia/Tokyo':
        return 'Tokyo (UTC+9)';
      case 'UTC':
        return 'UTC';
      default:
        return timezone;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Text(text, style: AppTextStyles.sectionHeader(context)),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileHeroCard({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _buildInitials(name);

    return Card(
      child: Padding(
        padding: AppSpacing.cardInsets,
        child: Row(
          children: [
            CircleAvatar(
              radius: AppSpacing.avatarRadius,
              backgroundColor: theme.colorScheme.primary,
              child: Text(
                initials,
                style: AppTextStyles.cardTitle(
                  context,
                ).copyWith(color: theme.colorScheme.onPrimary, fontSize: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: 4),
                  Text(email, style: AppTextStyles.bodySecondary(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildInitials(String value) {
    final words = value.trim().split(' ').where((e) => e.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first[0].toUpperCase();
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}

class _ProfileInfoGroup extends StatelessWidget {
  final List<_ProfileInfoRow> items;

  const _ProfileInfoGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: AppSpacing.lg + 32 + AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.iconBg(context, iconColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: Text(label, style: AppTextStyles.cardTitle(context)),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodySecondary(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileLinkGroup extends StatelessWidget {
  final List<_ProfileLinkRow> items;

  const _ProfileLinkGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              Divider(height: 1, indent: AppSpacing.lg + 32 + AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _ProfileLinkRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileLinkRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.iconBg(context, iconColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.bodySecondary(context)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Icon(
              AppIcons.chevronRight,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
