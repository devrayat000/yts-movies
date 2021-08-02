import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/theme.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    Consumer<AppTheme>(
                      builder: (context, theme, child) {
                        return IconButton(
                          onPressed: theme.toggleTheme,
                          icon: Icon(
                            theme.isDark
                                ? Icons.light_mode_rounded
                                : Icons.dark_mode,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          DrawerItem(
            title: 'Latest Movies',
            leadingIcon: Icons.new_releases,
          ),
          DrawerItem(
            title: 'Profile',
            leadingIcon: Icons.account_circle,
          ),
          DrawerItem(
            title: 'Settings',
            leadingIcon: Icons.settings,
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
      onTap: () {
        Navigator.pop(context);
        this.onClose?.call();
      },
    );
  }
}


//   keytool -genkey -v -keystore c:\Users\rayat\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

