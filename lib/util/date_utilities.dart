final DateTime CURRENT_DATE = DateTime.now();

DateTime getDayFromIndex(int index) {
  return DateTime(CURRENT_DATE.year, CURRENT_DATE.month, CURRENT_DATE.day + index);
}

String getMonthString(DateTime dateTime) {
  switch(dateTime.month) {
    case 1: return 'January';
    case 2: return 'February';
    case 3: return 'March';
    case 4: return 'April';
    case 5: return 'May';
    case 6: return 'June';
    case 7: return 'July';
    case 8: return 'August';
    case 9: return 'September';
    case 10: return 'October';
    case 11: return 'November';
    case 12: return 'December';
    default: return 'Invalid Month';
  }
}

String getYearString(DateTime dateTime) {
  return dateTime.year.toString();
}

String asString(DateTime dateTime) {
  return "${dateTime.day}. ${getMonthString(dateTime)} ${dateTime.year}";
}

String asStringNumber(DateTime dateTime) {
  return "${dateTime.day}. ${dateTime.month}. ${dateTime.year}";
}

// will also return negative ages
int getAge(DateTime dateTime, DateTime birthday) {
  return dateTime.year - birthday.year;
}

bool sameDay(DateTime d1, DateTime d2) {
  return d1.day == d2.day && d1.month == d2.month && d1.year == d2.year;
}