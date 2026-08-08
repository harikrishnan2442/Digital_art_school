import 'package:flutter/widgets.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
/// Every icon used anywhere in the app is referenced through this one
/// class instead of calling the icon package directly.
///
/// Why: icon packages occasionally rename an icon between versions.
/// By funnelling every reference through `AppIcons`, a rename only
/// ever needs a one-line fix here instead of a hunt across the whole
/// codebase. If `flutter pub get` complains that a name below doesn't
/// exist, open the Lucide icon list on pub.dev/lucide.dev and swap
/// just that one line.
class AppIcons {
  AppIcons._();

  // Navigation
  static const IconData dashboard = LucideIcons.layoutGrid;
  static const IconData schedule = LucideIcons.calendarDays;
  static const IconData courses = LucideIcons.bookOpen;
  static const IconData progress = LucideIcons.lineChart;
  static const IconData profile = LucideIcons.user;
  static const IconData settings = LucideIcons.settings;

  // Common actions
  static const IconData back = LucideIcons.arrowLeft;
  static const IconData forward = LucideIcons.arrowRight;
  static const IconData chevronLeft = LucideIcons.chevronLeft;
  static const IconData chevronRight = LucideIcons.chevronRight;
  static const IconData close = LucideIcons.x;
  static const IconData check = LucideIcons.check;
  static const IconData checkCircle = LucideIcons.checkCircle2;
  static const IconData send = LucideIcons.send;
  static const IconData download = LucideIcons.download;
  static const IconData search = LucideIcons.search;
  static const IconData edit = LucideIcons.pencil;
  static const IconData trash = LucideIcons.trash2;
  static const IconData plus = LucideIcons.plus;

  // Account / auth
  static const IconData mail = LucideIcons.mail;
  static const IconData lock = LucideIcons.lock;
  static const IconData eye = LucideIcons.eye;
  static const IconData eyeOff = LucideIcons.eyeOff;
  static const IconData logout = LucideIcons.logOut;
  static const IconData badge = LucideIcons.badgeCheck;
  static const IconData shield = LucideIcons.shieldCheck;

  // Content / discipline
  static const IconData palette = LucideIcons.palette;
  static const IconData brush = LucideIcons.paintbrush;
  static const IconData trendingUp = LucideIcons.trendingUp;
  static const IconData flag = LucideIcons.flag;
  static const IconData accessibility = LucideIcons.accessibility;
  static const IconData graduationCap = LucideIcons.graduationCap;
  static const IconData users = LucideIcons.users;
  static const IconData award = LucideIcons.award;
  static const IconData flame = LucideIcons.flame;
  static const IconData clock = LucideIcons.clock;
  static const IconData sparkles = LucideIcons.sparkles;
  static const IconData messageCircle = LucideIcons.messageCircle;
  static const IconData bell = LucideIcons.bell;
  static const IconData mapPin = LucideIcons.mapPin;
  static const IconData locateFixed = LucideIcons.locateFixed;
  static const IconData globe = LucideIcons.globe;
  static const IconData database = LucideIcons.database;
  static const IconData bookOpen = LucideIcons.bookOpen;
  static const IconData fileText = LucideIcons.fileText;
  static const IconData video = LucideIcons.video;
  static const IconData mic = LucideIcons.mic;
  static const IconData tune = LucideIcons.slidersHorizontal;
  static const IconData assignment = LucideIcons.clipboardList;
  static const IconData calendarMonth = LucideIcons.calendar;
  static const IconData eventAvailable = LucideIcons.calendarCheck2;
  static const IconData lightbulb = LucideIcons.lightbulb;
  static const IconData sun = LucideIcons.sun;
  static const IconData moon = LucideIcons.moon;
  static const IconData lockOutline = LucideIcons.lock;
  static const IconData unlock = LucideIcons.unlock;
}
