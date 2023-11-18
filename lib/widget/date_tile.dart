import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:birthday_reminder/models/date_scroller_model.dart';
import 'package:birthday_reminder/screen/date_view_screen.dart';
import 'package:birthday_reminder/util/configuration.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateTile extends StatelessWidget{

  static const BORDERRADIUS = BorderRadius.all(Radius.circular(15));
  final DateTime dateTime;

  const DateTile({Key? key, required this.dateTime}) : super(key: key);

  BoxDecoration getDecoration(DateScrollerModel dateScrollerModel, AppStateModel appStateModel) {
    Color color = dateScrollerModel.getCurrentDate.month == dateTime.month ? Colors.grey[700]! : Colors.grey[800]!;
    List<Color> colors = appStateModel.getBirthdays(dateTime).map((e) => appStateModel.getCategory(e.category)!).toList();
    Border? border = sameDay(CURRENT_DATE, dateTime) ? Border.all(
        width: 1,
        color: Colors.grey[400]!
    ) : null;
    if (colors.isEmpty) {
      return BoxDecoration(
        color: color,
        borderRadius: BORDERRADIUS,
        border: border
      );
    }
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [color]..addAll(colors)..add(color),
      ),
      borderRadius: BORDERRADIUS,
      border: border
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DateScrollerModel, AppStateModel>(
      builder: (context, dateScrollerModel, appStateModel, child) => AnimatedContainer(
        decoration: getDecoration(dateScrollerModel, appStateModel),
        duration: DURATION,
        child: child,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BORDERRADIUS,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DateViewScreen(dateTime: dateTime)));},
          child: Center(
            child: Text(dateTime.day.toString()),
          ),
        ),
      ),
    );
  }
}

