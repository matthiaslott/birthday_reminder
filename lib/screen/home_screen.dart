import 'package:birthday_reminder/models/date_scroller_model.dart';
import 'package:birthday_reminder/widget/month_display.dart';
import 'package:birthday_reminder/widget/date_scroller.dart';
import 'package:birthday_reminder/widget/custom_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DateScrollerModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const MonthDisplay(),
        ),
        drawer: const CustomDrawer(),
        body: const DateScroller(),
      ),
    );
  }
}
