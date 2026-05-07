import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Product icon vocabulary.
/// Keep Lucide mappings here so screens use one visual language.
abstract final class AppIcons {
  static const IconData today = LucideIcons.calendarDays;
  static const IconData todayActive = LucideIcons.calendarCheck;
  static const IconData timeline = LucideIcons.route;
  static const IconData timelineActive = LucideIcons.route;
  static const IconData tasks = LucideIcons.listChecks;
  static const IconData tasksActive = LucideIcons.clipboardCheck;
  static const IconData profile = LucideIcons.circleUserRound;
  static const IconData profileActive = LucideIcons.userCog;

  static const IconData add = LucideIcons.plus;
  static const IconData addTask = LucideIcons.listPlus;
  static const IconData schedule = LucideIcons.calendarClock;
  static const IconData calendar = LucideIcons.calendar;
  static const IconData date = LucideIcons.calendarDays;
  static const IconData time = LucideIcons.clock;
  static const IconData refresh = LucideIcons.refreshCw;
  static const IconData sync = LucideIcons.refreshCcw;
  static const IconData retry = LucideIcons.rotateCcw;
  static const IconData edit = LucideIcons.pencilLine;
  static const IconData delete = LucideIcons.trash2;
  static const IconData archive = LucideIcons.archive;
  static const IconData inbox = LucideIcons.inbox;
  static const IconData paused = LucideIcons.circlePause;
  static const IconData resume = LucideIcons.circlePlay;
  static const IconData close = LucideIcons.x;
  static const IconData moreHorizontal = LucideIcons.ellipsis;
  static const IconData moreVertical = LucideIcons.ellipsisVertical;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData chevronUp = LucideIcons.chevronUp;
  static const IconData chevronDown = LucideIcons.chevronDown;
  static const IconData externalLink = LucideIcons.externalLink;
  static const IconData copy = LucideIcons.copy;
  static const IconData send = LucideIcons.send;
  static const IconData upload = LucideIcons.upload;
  static const IconData settings = LucideIcons.settings2;
  static const IconData focus = LucideIcons.crosshair;
  static const IconData arrowRight = LucideIcons.arrowRight;

  static const IconData check = LucideIcons.check;
  static const IconData complete = LucideIcons.circleCheck;
  static const IconData success = LucideIcons.circleCheckBig;
  static const IconData incomplete = LucideIcons.circle;
  static const IconData reopen = LucideIcons.rotateCcw;
  static const IconData error = LucideIcons.circleAlert;
  static const IconData warning = LucideIcons.triangleAlert;
  static const IconData insight = LucideIcons.lightbulb;
  static const IconData sparkle = LucideIcons.sparkles;
  static const IconData magic = LucideIcons.wandSparkles;
  static const IconData achieved = LucideIcons.trophy;
  static const IconData history = LucideIcons.history;
  static const IconData score = LucideIcons.gauge;
  static const IconData explanation = LucideIcons.brain;
  static const IconData summary = LucideIcons.fileText;
  static const IconData info = LucideIcons.info;
  static const IconData warningTriangle = LucideIcons.triangleAlert;
  static const IconData errorCircle = LucideIcons.circleAlert;
  static const IconData restore = LucideIcons.inbox;

  static const IconData urgentTask = LucideIcons.alarmClock;
  static const IconData progressTask = LucideIcons.chartLine;
  static const IconData dailyTask = LucideIcons.repeat;
  static const IconData standardTask = LucideIcons.circleCheck;
  static const IconData lowPriority = LucideIcons.arrowDown;
  static const IconData priority = LucideIcons.flag;
  static const IconData highPriority = LucideIcons.badgeAlert;
  static const IconData label = LucideIcons.tag;
  static const IconData tags = LucideIcons.tags;
  static const IconData linked = LucideIcons.gitBranch;
  static const IconData unlinked = LucideIcons.link2Off;
  static const IconData note = LucideIcons.stickyNote;
  static const IconData addNote = LucideIcons.notebookPen;
  static const IconData start = LucideIcons.circlePlay;
  static const IconData stop = LucideIcons.circleStop;
  static const IconData recurrence = LucideIcons.repeat2;
  static const IconData taskTree = LucideIcons.listTree;

  static const IconData place = LucideIcons.mapPin;
  static const IconData addPlace = LucideIcons.mapPinPlus;
  static const IconData places = LucideIcons.mapPinned;
  static const IconData map = LucideIcons.map;
  static const IconData locate = LucideIcons.locateFixed;
  static const IconData radius = LucideIcons.slidersHorizontal;
  static const IconData tap = LucideIcons.pointer;
  static const IconData home = LucideIcons.house;
  static const IconData work = LucideIcons.briefcase;
  static const IconData study = LucideIcons.bookOpen;
  static const IconData exercise = LucideIcons.dumbbell;
  static const IconData cafe = LucideIcons.coffee;
  static const IconData restaurant = LucideIcons.utensils;
  static const IconData store = LucideIcons.store;
  static const IconData travel = LucideIcons.plane;
  static const IconData commute = LucideIcons.car;
  static const IconData rest = LucideIcons.bed;
  static const IconData personal = LucideIcons.userRound;
  static const IconData meeting = LucideIcons.users;

  static const IconData finance = LucideIcons.wallet;
  static const IconData spending = LucideIcons.receipt;
  static const IconData payment = LucideIcons.creditCard;
  static const IconData money = LucideIcons.dollarSign;

  static const IconData email = LucideIcons.mail;
  static const IconData timezone = LucideIcons.clock;
  static const IconData language = LucideIcons.languages;
  static const IconData lock = LucideIcons.lock;
  static const IconData secure = LucideIcons.shieldCheck;
  static const IconData appearance = LucideIcons.palette;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;

  static const IconData sun = LucideIcons.sun;
  static const IconData moon = LucideIcons.moon;
  static const IconData cloud = LucideIcons.cloud;
  static const IconData cloudSun = LucideIcons.cloudSun;
  static const IconData rain = LucideIcons.cloudRain;
  static const IconData umbrella = LucideIcons.umbrella;

  static const IconData file = LucideIcons.file;
  static const IconData folder = LucideIcons.folder;
  static const IconData attachment = LucideIcons.paperclip;
  static const IconData camera = LucideIcons.camera;
  static const IconData photo = LucideIcons.image;
  static const IconData video = LucideIcons.video;
  static const IconData audio = LucideIcons.mic;
}
