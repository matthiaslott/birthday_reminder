import 'dart:convert';

import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () => Navigator.pushNamed(context, '/categories'),
            title: const Text('Manage Categories'),
            subtitle: const Text('Add, modify or remove categories'),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            trailing: const Icon(Icons.keyboard_arrow_right),
          ),
          Consumer<AppStateModel>(
            builder: (context, appStateModel, child) => Column(
              children: appStateModel.getBirthdays(CURRENT_DATE, everything: true).map((bday) => ListTile(
                trailing: Chip(
                  label: Text(asStringNumber(bday.date)),
                  backgroundColor: appStateModel.getCategory(bday.category),
                ),
                title: Text(bday.name),
              )).toList(),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => ImportDialog(
                    appStateModel: Provider.of<AppStateModel>(context, listen: false),
                  ),
                ),
                child: const Text("Import Data")
              ),
              OutlinedButton(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: jsonEncode(Provider.of<AppStateModel>(context, listen: false).toJson())
                      )
                    ).then((value) =>
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied data to the clipboard")))
                    );
                  },
                  child: const Text("Export Data")
              ),
              /*OutlinedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('backgroundTask_day');
                    print(prefs.getString('backgroundTask_day'));
                  },
                  child: const Text("Clear Shared Prefs")
              ),*/
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Consumer<AppStateModel>(
              builder: (context, appStateModel, child) {
                var prettyPrint = const JsonEncoder.withIndent('  ').convert(appStateModel.toJson());
                return Text(prettyPrint);
              },
            ),
          )
        ],
      )
    );
  }
}

class ImportDialog extends StatefulWidget {

  final AppStateModel appStateModel;

  const ImportDialog({Key? key, required this.appStateModel}) : super(key: key);

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {

  late TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: "");
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Import Data"),
      scrollable: true,
      content: TextFormField(
        controller: _textEditingController,
        autovalidateMode: AutovalidateMode.always,
        validator: (value) => value == "" ? "Please enter data" : null,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Data',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            AppStateModel? appStateModel = AppStateModel.fromJson(_textEditingController.text);
            if (appStateModel != null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading new data")));
              widget.appStateModel.saveExternalAppStateModel(appStateModel); // save the new appstate model and load it
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Loading successfull")));
              Navigator.pop(context);
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}