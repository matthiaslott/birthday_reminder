

import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/material.dart';

class DateScrollerModel extends ChangeNotifier {
  DateTime _currentDate = CURRENT_DATE;
  bool _forward = true;

  DateTime get getCurrentDate => _currentDate;
  bool get isForward => _forward;

  // Setter for currentMonth
  void setCurrentDate(DateTime newDate, bool forward) {
    _currentDate = newDate;
    _forward = forward;
    notifyListeners();
  }
}