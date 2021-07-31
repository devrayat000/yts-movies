import 'package:flutter/material.dart';
import 'package:provider/provider.dart' show ReadContext, SelectContext;

import '../../models/theme.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void _closeDrawer() => Navigator.of(context).pop();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.black26,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Movies App',
                      style: Theme.of(context).textTheme.headline4,
                      textAlign: TextAlign.start,
                    ),
                    IconButton(
                      onPressed: context.read<AppTheme>().toggleTheme,
                      icon: Icon(
                        context.select<AppTheme, bool>((theme) => theme.isDark)
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          DrawerItem(
            title: 'Latest Movies',
            leadingIcon: Icons.new_releases,
            onClose: _closeDrawer,
          ),
          DrawerItem(
            title: 'Profile',
            leadingIcon: Icons.account_circle,
            onClose: _closeDrawer,
          ),
          DrawerItem(
            title: 'Settings',
            leadingIcon: Icons.settings,
            onClose: _closeDrawer,
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final void Function()? onClose;
  final IconData leadingIcon;
  final String title;

  const DrawerItem({
    Key? key,
    required this.leadingIcon,
    required this.title,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        leadingIcon,
        color: Theme.of(context).textTheme.headline5?.color,
      ),
      title: Text(
        this.title,
        style: TextStyle(
          color: Theme.of(context).textTheme.headline6?.color,
          fontSize: 20.0,
        ),
      ),
      onTap: this.onClose,
    );
  }
}


//   keytool -genkey -v -keystore c:\Users\rayat\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

