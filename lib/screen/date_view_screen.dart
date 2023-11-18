import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:birthday_reminder/util/date_utilities.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DateViewScreen extends StatelessWidget {

  final DateTime dateTime;

  const DateViewScreen({Key? key, required this.dateTime}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asString(dateTime)),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => DateDialog(
                initialBirthday: Birthday(name: '', date: dateTime, category: AppStateModel.MISC),
                title: const Text('Add birthday'),
                appStateModel: Provider.of<AppStateModel>(context, listen: false),
                callback: (name, date, category, appStateModel) {
                  appStateModel.addBirthday(Birthday(name: name, date: date, category: category));
                },
              ),
            ),
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: Consumer<AppStateModel>(
        builder: (context, appStateModel, child) => ListView.builder(
          itemCount: appStateModel.getBirthdays(dateTime).length,
          itemBuilder: (context, index) {
            Birthday birthday = appStateModel.getBirthdays(dateTime)[index];
            int age = getAge(dateTime, birthday.date);
            return ListTile(
              leading: Chip(
                label: Text(age < 0 ? "-" : age.toString()),
                backgroundColor: appStateModel.getCategory(birthday.category),
              ),
              title: Text(birthday.name),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => DateDialog(
                        title: const Text('Modify Birthday'),
                        initialBirthday: birthday,
                        appStateModel: appStateModel,
                        callback: (name, date, category , appStateModel) {
                          appStateModel.modifyBirthday(birthday.name, name, date, category);
                        },
                      ),
                    ),
                    icon: const Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Birthday'),
                        content: Text('Do you really want to delete birthday \'${birthday.name}\'?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              appStateModel.removeBirthday(birthday);
                              Navigator.pop(context);
                            },
                            child: const Text('DELETE'),
                          ),
                        ],
                      ),
                    ),
                    icon: const Icon(Icons.delete),
                  ),
                ],
              ),
            );
          }
        ),
      ),
    );
  }
}

class DateDialog extends StatefulWidget {

  final Widget title;
  final AppStateModel appStateModel;
  final Function(String, DateTime, String, AppStateModel) callback;
  final Birthday initialBirthday;

  const DateDialog({Key? key, required this.title, required this.appStateModel, required this.callback, required this.initialBirthday}) : super(key: key);

  @override
  State<DateDialog> createState() => _DateDialogState();
}

class _DateDialogState extends State<DateDialog> {

  late TextEditingController _textEditingController;
  late DateTime date;
  late String category;

  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.initialBirthday.name);
    date = widget.initialBirthday.date;
    category = widget.initialBirthday.category;
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
      title: widget.title,
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _textEditingController,
            autovalidateMode: AutovalidateMode.always,
            validator: (value) => widget.appStateModel.validName(widget.initialBirthday.name, value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Name',
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Date: ${asString(date)}"),
              IconButton(
                onPressed: () async {
                  DateTime? res = await showDatePicker(
                    context: context,
                    initialDate: widget.initialBirthday.date,
                    firstDate: DateTime(widget.initialBirthday.date.year - 100),
                  lastDate: DateTime(widget.initialBirthday.date.year + 100)
                  );
                  if (res != null) {
                    setState(() {
                      date = res;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          Wrap(
            spacing: 5,
            children: widget.appStateModel.getCategories().map((e) => ActionChip(
              onPressed: () {
                setState(() {
                  category = e.key;
                });
              },
              label: Text(e.key),
              backgroundColor: e.value,
              elevation: category == e.key ? 0 : 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                  width: 2,
                  color: category == e.key ? Colors.white : e.value,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.appStateModel.validName(widget.initialBirthday.name, _textEditingController.text) == null) {
              widget.callback(_textEditingController.text, date, category, widget.appStateModel);
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
