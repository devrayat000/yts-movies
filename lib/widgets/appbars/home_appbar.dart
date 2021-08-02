import 'package:flutter/material.dart';
import '../../pages/favourites.dart';

class HomeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppbar({Key? key})
      : preferredSize = const Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  final Size preferredSize;

  @override
  PreferredSizeWidget build(BuildContext context) {
    return AppBar(
      title: Image.asset(
        'images/logo-YTS.png',
      ),
      elevation: 5,
      actions: [
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, FavouratesPage.routeName);
          },
          icon: const Icon(
            Icons.favorite_outline_rounded,
            color: Colors.pink,
          ),
          tooltip: 'Favourites',
        ),
      ],
    );
  }
}
