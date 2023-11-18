import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:birthday_reminder/screen/category_screen.dart';
import 'package:birthday_reminder/screen/home_screen.dart';
import 'package:birthday_reminder/screen/settings_screen.dart';
import 'package:birthday_reminder/util/local_notification_service.dart';
import 'package:birthday_reminder/util/workmanager_handler.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // initialise local notificaitons
  await setupLocalNotifications();
  // initialise Workmanager
  setupWorkManager();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AppStateModel.loadAppStateModel(),
      builder: (context, snapshot) {
        // while state is being loaded
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        else if (snapshot.hasError) {
          return const Center(
            child: Text('Error occurred while loading', textDirection: TextDirection.ltr),
          );
        }
        return ChangeNotifierProvider(
          create: (_) => snapshot.data,
          lazy: false,
          child: MaterialApp(
            title: 'Birthday Reminder',
            theme: ThemeData(
              brightness: Brightness.light,
              primarySwatch: Colors.red,
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.red,
              accentColor: Colors.red,
            ),
            themeMode: ThemeMode.dark, // only use derk mode
            initialRoute: '/home',
            routes: {
              '/home': (context) => const HomeScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/categories': (context) => const CategoryScreen(),
            }
          ),
        );
      },
    );
  }
}
