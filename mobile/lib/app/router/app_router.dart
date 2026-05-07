import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'app_transitions.dart';

import '../../features/navigation/presentation/pages/main_shell_page.dart';

import '../../features/today/presentation/pages/today_page.dart';
import '../../features/timeline/presentation/pages/timeline_page.dart';
import '../../features/summary/presentation/pages/summary_page.dart';

import '../../features/task/presentation/pages/task_list_page.dart';
import '../../features/task/presentation/pages/task_detail_page.dart';

import '../../features/place/presentation/pages/place_list_page.dart';
import '../../features/place/presentation/pages/create_place_page.dart';
import '../../features/place/presentation/pages/edit_place_page.dart';
import '../../features/place/presentation/pages/place_detail_page.dart';

import '../../features/user/presentation/pages/profile_page.dart';
import '../../features/user/presentation/pages/edit_profile_page.dart';

import '../../features/schedule/presentation/pages/schedule_page.dart';
import '../../features/schedule/presentation/pages/schedule_detail_page.dart';

import '../../features/location/presentation/pages/location_history_page.dart';
import '../../features/score/presentation/pages/score_page.dart';
import '../../features/stay_session/presentation/pages/stay_session_page.dart';
import '../../features/financial/presentation/pages/finance_page.dart';

import '../../features/devtools/presentation/pages/swipe_back_test_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.today,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.today,
                pageBuilder: (context, state) => AppTransitions.slide(
                  pageKey: state.pageKey,
                  child: const TodayPage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.timeline,
                pageBuilder: (context, state) => AppTransitions.slide(
                  pageKey: state.pageKey,
                  child: const TimelinePage(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: TaskRoutes.root,
                pageBuilder: (context, state) => AppTransitions.slide(
                  pageKey: state.pageKey,
                  child: const TaskListPage(),
                ),
                routes: [
                  GoRoute(
                    path: TaskRoutes.detailParam,
                    pageBuilder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return AppTransitions.modal(
                        pageKey: state.pageKey,
                        child: TaskDetailPage(taskId: id),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                pageBuilder: (context, state) => AppTransitions.slide(
                  pageKey: state.pageKey,
                  child: const ProfilePage(),
                ),
                routes: [
                  GoRoute(
                    path: ProfileRoutes.edit,
                    pageBuilder: (context, state) => AppTransitions.modal(
                      pageKey: state.pageKey,
                      child: const EditProfilePage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.summary,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const SummaryPage(),
        ),
      ),
      GoRoute(
        path: PlaceRoutes.root,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const PlaceListPage(),
        ),
        routes: [
          GoRoute(
            path: PlaceRoutes.create,
            pageBuilder: (context, state) => AppTransitions.modal(
              pageKey: state.pageKey,
              child: const CreatePlacePage(),
            ),
          ),
          GoRoute(
            path: PlaceRoutes.detailParam,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppTransitions.modal(
                pageKey: state.pageKey,
                child: PlaceDetailPage(id: id),
              );
            },
            routes: [
              GoRoute(
                path: PlaceRoutes.edit,
                pageBuilder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return AppTransitions.modal(
                    pageKey: state.pageKey,
                    child: EditPlacePage(placeId: id),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: ScheduleRoutes.root,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const SchedulePage(),
        ),
        routes: [
          GoRoute(
            path: ScheduleRoutes.detailParam,
            pageBuilder: (context, state) {
              final id = state.pathParameters['id']!;
              return AppTransitions.modal(
                pageKey: state.pageKey,
                child: ScheduleDetailPage(id: id),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.location,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const LocationHistoryPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.score,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const ScorePage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.staySessions,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const StaySessionPage(),
        ),
      ),
      GoRoute(
        path: AppRoutes.finance,
        pageBuilder: (context, state) => AppTransitions.slide(
          pageKey: state.pageKey,
          child: const FinancePage(),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.swipeBackTest,
          pageBuilder: (context, state) => AppTransitions.slide(
            pageKey: state.pageKey,
            child: const SwipeBackTestPage(),
          ),
        ),
    ],
  );
});
