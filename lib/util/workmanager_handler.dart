import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:birthday_reminder/util/local_notification_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io';

void setupWorkManager() {
  Workmanager().initialize(
      callbackDispatcher, //isInDebugMode: true
  );
  Workmanager().registerPeriodicTask( // runs ideally every 15 minutes
    "BirthdayReminder-BackgroundTaskIdentifier",
    "BirthdayReminder-BackgroundTask",
    tag: "BirthdayReminder",
    existingWorkPolicy: ExistingWorkPolicy.replace, // replace the old task
  );
}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "BirthdayReminder-BackgroundTask") {
      if (kDebugMode) { print("[TASK] Executing background task ($task)"); }
      File file = await AppStateModel.getFile();
      final prefs = await SharedPreferences.getInstance();
      String? lastDay = prefs.getString('backgroundTask_day');
      if (kDebugMode) { print("[TASK] File exists: ${file.existsSync()}, Last executed: $lastDay"); }
      // only do notifications iff file exists and no notifications displayed yet today
      if (file.existsSync() && (lastDay == null || lastDay != asStringNumber(DateTime.now()))) {
        // getAppStateModel from file
        AppStateModel? appStateModel = AppStateModel.fromJson(await file.readAsString());
        if (appStateModel == null) {
          if (kDebugMode) { print("[TASK] Failed to extract AppStateModel"); }
        }
        // Invariant: AppStateModel != null
        String body = appStateModel!.getBirthdays(DateTime.now())
                          .where((birthday) => getAge(DateTime.now(), birthday.date) >= 0)
                          .map((birthday) => "${birthday.name} is turning ${getAge(DateTime.now(), birthday.date)}, congratulations!")
                          .join("\n");
        showNotification("Today's Birthdays:", body);
        // update lastDay
        lastDay = asStringNumber(DateTime.now());
        await prefs.setString('backgroundTask_day', lastDay);
        if (kDebugMode) { print("[TASK] Set backgroundTask_day to $lastDay"); }
      }
    }
    return Future.value(true);
  });
}