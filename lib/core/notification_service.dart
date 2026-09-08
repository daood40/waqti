import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../state/app_state.dart';
import 'l10n.dart';

/// تذكيرات محلية بلا خادم: لكل عادة لها وقت تذكير نجدول إشعارًا في كل
/// يوم مستحق خلال الأسبوعين القادمين، إضافةً إلى ملخص صباحي ومسائي.
/// تُعاد الجدولة كاملة عند أي تغيير في الحالة (بمهلة قصيرة لتجميع
/// التعديلات المتتابعة). على الويب كل الاستدعاءات لا تفعل شيئًا.
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'waqti_reminders';
  static const _horizonDays = 14;
  static const _morningId = 900001;
  static const _eveningId = 900002;
  static const _morningHour = 8;
  static const _eveningHour = 20;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _permissionAsked = false;
  Timer? _debounce;

  /// معرّف المهمة التي نقر المستخدم إشعارها (يُستهلك من الواجهة ثم يُصفَّر).
  final ValueNotifier<String?> tappedTaskId = ValueNotifier<String?>(null);

  /// يهيئ الحزمة والمنطقة الزمنية ويطلب الإذن. آمن على كل المنصات.
  Future<void> init() async {
    if (kIsWeb) return;
    try {
      tzdata.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        // منطقة غير معروفة: نبقى على UTC بدل تعطيل التذكيرات.
      }
      // لا نطلب الإذن هنا؛ يُطلب في سياقه عند أول تذكير فعلي (_ensurePermission).
      const darwin = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
        macOS: darwin,
      );
      _ready =
          await _plugin.initialize(
            settings,
            onDidReceiveNotificationResponse: (response) {
              final payload = response.payload;
              if (payload != null && payload.isNotEmpty) {
                tappedTaskId.value = payload;
              }
            },
          ) ??
          false;
      if (!_ready) return;
      // فُتح التطبيق من إشعار وهو مغلق؟ نوجّه لنفس المهمة.
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final launchPayload = launch?.notificationResponse?.payload;
      if ((launch?.didNotificationLaunchApp ?? false) &&
          launchPayload != null &&
          launchPayload.isNotEmpty) {
        tappedTaskId.value = launchPayload;
      }
    } catch (_) {
      _ready = false; // منصة بلا دعم (مثل ويندوز بلا تسجيل): نتجاهل بهدوء
    }
  }

  /// يربط الخدمة بالحالة: مزامنة أولية ثم بعد كل تغيير.
  void bind(AppState state) {
    if (kIsWeb || !_ready) return;
    unawaited(sync(state));
    state.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), () => sync(state));
    });
  }

  /// يطلب إذن الإشعارات مرة واحدة، وفي سياقه: عندما يوجد فعلًا ما يُجدوَل.
  Future<void> _ensurePermission() async {
    if (_permissionAsked) return;
    _permissionAsked = true;
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  /// هل يوجد ما يستحق الجدولة أصلًا؟ (يمنع طلب إذن بلا سبب)
  bool _hasAnythingToSchedule(AppState state) =>
      state.morningRecap ||
      state.eveningRecap ||
      state.tasks.any(
        (t) => t.reminderMinutes != null && t.notificationsOn && !t.isPaused,
      );

  /// يلغي كل الجدول ويعيد بناءه من الحالة الحالية.
  Future<void> sync(AppState state) async {
    if (kIsWeb || !_ready) return;
    try {
      await _plugin.cancelAll();
      if (!state.notifMaster || !_hasAnythingToSchedule(state)) return;
      await _ensurePermission();
      final s = AppStrings.of(state.lang);
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          s.notifChannelName,
          channelDescription: s.notifChannelDesc,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      );
      final now = tz.TZDateTime.now(tz.local);
      var counter = 0;
      for (final task in state.tasks) {
        final minutes = task.reminderMinutes;
        if (minutes == null || !task.notificationsOn || task.isPaused) {
          continue;
        }
        for (var d = 0; d < _horizonDays; d++) {
          final day = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day + d,
            minutes ~/ 60,
            minutes % 60,
          );
          if (!day.isAfter(now)) continue;
          final plain = DateTime(day.year, day.month, day.day);
          if (!task.isApplicableOn(plain)) continue;
          if (task.statusOn(plain) != null) continue; // أُنجزت أو حُدّدت
          await _plugin.zonedSchedule(
            1000 + counter++,
            '${task.icon} ${task.name}',
            s.notifReminderBody,
            day,
            details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: task.id,
          );
        }
      }
      if (state.morningRecap && !state.isQuietAt(_morningHour * 60)) {
        await _scheduleDaily(
          _morningId,
          _morningHour,
          s.notifMorningTitle,
          s.notifMorningBody,
          details,
          now,
        );
      }
      if (state.eveningRecap && !state.isQuietAt(_eveningHour * 60)) {
        await _scheduleDaily(
          _eveningId,
          _eveningHour,
          s.notifEveningTitle,
          s.notifEveningBody,
          details,
          now,
        );
      }
    } catch (_) {
      // فشل الجدولة لا يجب أن يعطل التطبيق.
    }
  }

  Future<void> _scheduleDaily(
    int id,
    int hour,
    String title,
    String body,
    NotificationDetails details,
    tz.TZDateTime now,
  ) async {
    var first = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!first.isAfter(now)) {
      first = tz.TZDateTime(tz.local, now.year, now.month, now.day + 1, hour);
    }
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      first,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
