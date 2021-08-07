import 'package:flutter/material.dart';
import 'package:ytsmovies/pages/index.dart';
import 'package:ytsmovies/widgets/buttons/theme_button.dart';
// import '../../pages/favourites.dart';

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
        const ThemeToggleButton(),
        IconButton(
          onPressed: () async {
            try {
              await Navigator.of(context).push(Routes.favourites(context));
            } catch (e) {
              print(e);
            }
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
