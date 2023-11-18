import 'package:birthday_reminder/models/date_scroller_model.dart';
import 'package:birthday_reminder/util/configuration.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MonthDisplay extends StatelessWidget {

  const MonthDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 20,
      children: [
        Consumer<DateScrollerModel>(
          builder: (context, dateScrollerModel, child) => AnimatedSwitcher(
            duration: DURATION,
            child: Text(getYearString(dateScrollerModel.getCurrentDate),
              key: ValueKey(getYearString(dateScrollerModel.getCurrentDate)),
            ),
          ),
        ),
        Consumer<DateScrollerModel>(
          builder: (context, dateScrollerModel, child) => AnimatedSwitcher(
            duration: DURATION,
            child: ConstrainedBox(
              key: ValueKey(getMonthString(dateScrollerModel.getCurrentDate)),
              constraints: const BoxConstraints(minWidth: 120, maxWidth: 120),
              child: Text(getMonthString(dateScrollerModel.getCurrentDate),

              ),
            ),
          ),
        ),
      ],
    );
  }
}