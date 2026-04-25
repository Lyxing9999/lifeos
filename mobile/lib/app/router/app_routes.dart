class AppRoutes {
  const AppRoutes._();

  // Shell tabs (primary)
  static const today = '/today';
  static const timeline = '/timeline';
  static const tasks = '/tasks';
  static const profile = '/profile';

  // Secondary routes (details / hubs)
  static const summary = '/summary';
  static const places = '/places';
  static const schedule = '/schedule';
  static const location = '/location';
  static const score = '/score';
  static const staySessions = '/stay-sessions';
  static const finance = '/finance';

  // Debug
  static const swipeBackTest = '/swipe-back-test';
}

class TaskRoutes {
  const TaskRoutes._();

  static const root = AppRoutes.tasks;
  static const detailParam = 'id';

  static String detail(String id) => '$root/$id';
}

class PlaceRoutes {
  const PlaceRoutes._();

  static const root = AppRoutes.places;
  static const create = 'create';
  static const detailParam = 'id';
  static const edit = 'edit';

  static String createPath() => '$root/$create';
  static String detail(String id) => '$root/$id';
  static String editPath(String id) => '$root/$id/$edit';
}

class ProfileRoutes {
  const ProfileRoutes._();

  static const root = AppRoutes.profile;
  static const edit = 'edit';

  static String editPath() => '$root/$edit';
}

class ScheduleRoutes {
  const ScheduleRoutes._();

  static const root = AppRoutes.schedule;
  static const detailParam = 'id';

  static String detail(String id) => '$root/$id';
}

class FinanceRoutes {
  const FinanceRoutes._();

  static const root = AppRoutes.finance;
}
