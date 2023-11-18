import 'package:flutter/material.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red[700] ?? Colors.red,
                  Colors.deepPurple[700] ?? Colors.deepPurple,
                ],
              )
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 10.0,
                  left: 10.0,
                  child: Text("Birthday",
                    style: Theme.of(context).textTheme.headline6,
                  )
                ),
                Center(
                  child: Image.asset("assets/images/ic_launcher_w.png",
                    width: 100,
                    height: 100,
                  ),
                ),
                Positioned(
                  bottom: 10.0,
                  right: 10.0,
                  child: Text("Reminder",
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context); // close the drawer
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
    );
  }
}
