import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class AppStateModel extends ChangeNotifier {
  Set<Birthday> _birthdays = {};
  Map<String, Color> _categories = HashMap();
  static const String MISC = "Miscellaneous";

  void ensureMisc() {
    _categories.putIfAbsent(MISC, () => Colors.grey);
    _categories.remove("");
  }

  UnmodifiableListView<Birthday> getBirthdays(DateTime date, {bool? everything}) {
    ensureMisc();
    var temp = _birthdays.where((element) => (everything != null && everything) || ((element.date.day == date.day) && element.date.month == date.month)).toList();
    temp.sort((a,b) => a.name.compareTo(b.name));
    return UnmodifiableListView(temp);
  }

  // change all birthdays in one go
  void setBirthdays(Set<Birthday> birthdays) {
    ensureMisc();
    _birthdays = birthdays;
    notifyListeners();
  }

  String? validName(String oldName, String? newName) {
    if (newName == null || newName == "") {
      return "Names must be non-empty";
    }
    if (oldName == newName) {
      return null;
    }
    return _birthdays.contains(Birthday(name: newName, date: CURRENT_DATE, category: MISC)) ? "This entry already exists" : null;
  }

  // add a birthday (returns false if the birthday already exists)
  bool addBirthday(Birthday birthday) {
    ensureMisc();
    if (_birthdays.contains(birthday)) {
      return false;
    }
    _birthdays.add(birthday);
    saveAppStateModel();
    notifyListeners();
    return true;
  }

  bool modifyBirthday(String oldName, String newName, DateTime newDate, String newCategory) {
    ensureMisc();
    if (!_birthdays.contains(Birthday(name: oldName, date: CURRENT_DATE, category: MISC))
        || (newName != oldName && _birthdays.contains(Birthday(name: newName, date: CURRENT_DATE, category: MISC)))
        || newName == "") {
      return false;
    }
    _birthdays.remove(Birthday(name: oldName, date: CURRENT_DATE, category: MISC));
    _birthdays.add(Birthday(name: newName, date: newDate, category: newCategory));
    saveAppStateModel();
    notifyListeners();
    return true;
  }

  // remove a birthday (returns false if the birthday does not exist)
  bool removeBirthday(Birthday birthday) {
    if (!_birthdays.contains(birthday)) {
      return false;
    }
    _birthdays.remove(birthday);
    saveAppStateModel();
    notifyListeners();
    return true;
  }
  
  // get categories as ordered list
  UnmodifiableListView<MapEntry<String, Color>> getCategories() {
    ensureMisc();
    List<MapEntry<String, Color>> temp = _categories.entries.toList();
    temp.removeWhere((element) => element.key == MISC);
    temp.sort((a, b) => a.key.compareTo(b.key));
    temp.insert(0, MapEntry(MISC, _categories[MISC]!));
    return UnmodifiableListView(temp);
  }

  Color? getCategory(String key) {
    return _categories[key];
  }

  // change all categories in one go
  void setCategories(Map<String, Color> categories) {
    _categories = categories;
    ensureMisc();
    notifyListeners();
  }

  String? validCategory(String? oldName, String? name) {
    if (name == "") {
      return "Categories must be non-empty";
    }
    else if (oldName == name) {
      return null;
    }
    else if (_categories.containsKey(name)) {
      return "Category names must be unique";
    }
    return null;
  }

  // adds a new category (returns false if the category already exists or the name is empty)
  bool addCategory(String name, Color color) {
    bool alreadyExists = _categories.containsKey(name);
    if (alreadyExists || name == "") {
      return false;
    }
    _categories.putIfAbsent(name, () => color);
    saveAppStateModel();
    notifyListeners();
    return true;
  }

  // changes the name and color of a category (returns false if the old category does not exist or the new one already exists or the newName is empty)
  bool modifyCategory(String oldName, String newName, Color newColor) {
    if (!_categories.containsKey(oldName) || (newName != oldName && _categories.containsKey(newName)) || newName == "") {
      return false;
    }
    _categories.remove(oldName)!;
    _categories.putIfAbsent(newName, () => newColor);
    // update birthdays
    _birthdays = _birthdays.map((e) {
      if (e.category == oldName) {
        e.category = newName;
      }
      return e;
    }).toSet();
    saveAppStateModel();
    notifyListeners();
    return true;
  }

  // returns true iff a category is unused
  bool canRemoveCategory(String name) {
    for (Birthday birthday in _birthdays) {
      if (birthday.category == name) {
        return false;
      }
    }
    return true;
  }

  // remove a category (returns false if the category does not exist) (set categories to miscellaneous if birthdays use this category)
  bool removeCategory(String name) {
    if (!_categories.containsKey(name)) {
      return false;
    }
    _categories.remove(name);
    ensureMisc();
    // update Birthdays that used this category
    for (Birthday birthday in _birthdays) {
      if (birthday.category == name) {
        birthday.category = MISC;
      }
    }
    saveAppStateModel();
    notifyListeners();
    return true;
  }

  // save a new appStateModel
  Future<void> saveExternalAppStateModel(AppStateModel appStateModel) async {
    setCategories(appStateModel._categories);
    setBirthdays(appStateModel._birthdays);
    saveAppStateModel();
    notifyListeners();
  }

  // save the app state to file
  Future<void> saveAppStateModel() async {
    if (kDebugMode) { print("[saveAppStateModel] Saving"); }
    File file = await getFile();
    if (!file.existsSync()) {
      if (kDebugMode) { print("[saveAppStateModel] File does not exist"); }
      file.create();
    }
    await file.writeAsString(jsonEncode(toJson()));
  }

  // load the app state from the file
  static Future<AppStateModel?> loadAppStateModel() async {

    if (kDebugMode) { print("[loadAppStateModel] Loading"); }
    File file = await getFile();
    if (!file.existsSync()) {
      if (kDebugMode) { print("[loadAppStateModel] File does not exist"); }
      return AppStateModel();
    }
    // extract json
    String contents = await file.readAsString();
    // create appState
    AppStateModel appStateModel = AppStateModel.fromJson(contents) ?? AppStateModel();

    if (kDebugMode) { print("[RETURN] $appStateModel"); }
    return appStateModel;
  }

  static Future<File> getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.txt");
  }

  Map<String, dynamic> toJson() {
    return {
      'categories': _categories.map((name, color) => MapEntry(name, color.value)),
      'birthdays': _birthdays.toList(),
    };
  }

  static AppStateModel? fromJson(json) {
    try {
      AppStateModel appStateModel = AppStateModel();
      var res = jsonDecode(json);
      // categories
      Map<String, Color> cat = Map.from(res['categories']).map((key, value) => MapEntry(key, Color(value)));
      appStateModel.setCategories(cat);
      // birthdays
      Set<Birthday> bday = res['birthdays'].map((e) => Birthday.fromJson(e)).toSet().cast<Birthday>();
      appStateModel.setBirthdays(bday);
      return appStateModel;
    }
    on Exception catch (_) {
      // in case the input is malformed in any way
      return null;
    }
  }
}


class Birthday {
  String name;
  DateTime date;
  String category;

  Birthday({required this.name, required this.date, required this.category});

  @override
  bool operator == (Object other) {
    return other is Birthday && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;

  Birthday.fromJson(Map<String, dynamic> json) : name = json['name'], date = DateTime(json['year'], json['month'], json['day']), category = json['category'];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'year': date.year,
      'month': date.month,
      'day': date.day,
      'category': category,
    };
  }
}
