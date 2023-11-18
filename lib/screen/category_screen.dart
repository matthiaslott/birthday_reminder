import 'package:birthday_reminder/models/app_state_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        actions: [
          IconButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => CategoryDialog(
                title: const Text('Add Category'),
                appStateModel: Provider.of<AppStateModel>(context, listen: false),
                callback: (name, color, appStateModel) {
                  appStateModel.addCategory(name, color);
                },
              ),
            ),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Consumer<AppStateModel>(
        builder: (context, appStateModel, child) {
          return ListView.builder(
            itemCount: appStateModel.getCategories().length,
            itemBuilder: (context, index) {
              String elementName = appStateModel.getCategories()[index].key;
              Color elementColor = appStateModel.getCategories()[index].value;
              return ListTile(
                leading: Chip(
                  label: Text(elementName),
                  backgroundColor: elementColor,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => CategoryDialog(
                          title: const Text('Modify Category'),
                          initialName: elementName,
                          initialColor: elementColor,
                          appStateModel: appStateModel,
                          callback: (name, color, appStateModel) {
                            appStateModel.modifyCategory(elementName, name, color);
                          },
                        ),
                      ),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () => showDialog(
                        context: context,
                        builder: (context) => DeleteDialog(
                          title: const Text('Delete Category'),
                          initialName: elementName,
                          initialColor: elementColor,
                          appStateModel: appStateModel,
                          callback: (name, color, appStateModel) {
                            appStateModel.removeCategory(name);
                            if (name == AppStateModel.MISC) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Category \'${AppStateModel.MISC}\' cannot be deleted')));
                            }
                          },
                        ),
                      ),
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class CategoryDialog extends StatefulWidget {

  final Widget title;
  final AppStateModel appStateModel;
  final Function(String, Color, AppStateModel) callback;
  final String? initialName;
  final Color? initialColor;


  const CategoryDialog({Key? key, required this.title, required this.appStateModel, required this.callback, this.initialName, this.initialColor}) : super(key: key);

  @override
  State<CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<CategoryDialog> {

  static List<Color> COLORS = [Colors.green, Colors.lightGreen, Colors.lime, Colors.yellow, Colors.amber, Colors.orange, Colors.deepOrange,
    Colors.red, Colors.pink, Colors.purple, Colors.deepPurple, Colors.indigo, Colors.blue, Colors.lightBlue, Colors.cyan, Colors.teal,
    Colors.blueGrey, Colors.brown, Colors.grey].map((e) => Color(e.value)).toList();

  late TextEditingController _textEditingController;
  late int selectedColor;


  @override
  void initState() {
    _textEditingController = TextEditingController(text: widget.initialName);
    selectedColor = widget.initialColor != null ? COLORS.indexOf(widget.initialColor!) : COLORS.length - 1;
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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _textEditingController,
            autovalidateMode: AutovalidateMode.always,
            validator: (value) => widget.appStateModel.validCategory(widget.initialName, value),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Category name',
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            height: 220,
            width: 300,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
                childAspectRatio: 1,
              ),
              shrinkWrap: true,
              primary: false,
              itemCount: COLORS.length,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => setState(() {
                  selectedColor = index;
                }),
                child: Container(
                  decoration: BoxDecoration(
                      color: COLORS[index],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        width: index == selectedColor ? 3 : 1,
                        color: Colors.white,
                      )
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (widget.appStateModel.validCategory(widget.initialName, _textEditingController.text) == null) {
              widget.callback(_textEditingController.text, COLORS[selectedColor], widget.appStateModel);
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class DeleteDialog extends StatefulWidget {

  final Widget title;
  final AppStateModel appStateModel;
  final Function(String, Color, AppStateModel) callback;
  final String initialName;
  final Color initialColor;

  const DeleteDialog({Key? key, required this.title, required this.appStateModel, required this.callback, required this.initialName, required this.initialColor}) : super(key: key);

  @override
  State<DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {

  late int counter;

  @override
  void initState() {
    counter = widget.appStateModel.canRemoveCategory(widget.initialName) ? 1 : 3;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: widget.title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Do you really want to delete category \'${widget.initialName}\'?'),
          const SizedBox(
            height: 15,
          ),
          const Text('If the category is currently in use, the corresponding birthdays will be moved to category ${AppStateModel.MISC}'),
          const SizedBox(
            height: 15,
          ),
          Text('Press \'DELETE\' $counter more time${counter == 1 ? '' : 's'} to proceed',
            style: Theme.of(context).textTheme.subtitle1?.copyWith(
              color: Colors.red,
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (counter == 1) {
              widget.callback(widget.initialName, widget.initialColor, widget.appStateModel);
              Navigator.pop(context);
            }
            else {
              setState(() {
                counter--;
              });
            }
          },
          child: const Text('DELETE'),
        ),
      ],
    );
  }
}
