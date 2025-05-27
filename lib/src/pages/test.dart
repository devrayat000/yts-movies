import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/index.dart';

class ImageAppbar extends StatefulWidget {
  const ImageAppbar({Key? key}) : super(key: key);

  @override
  ImageAppbarState createState() => ImageAppbarState();
}

class ImageAppbarState extends State<ImageAppbar> {
  late ScrollController _scrollController;

  bool isDetails = true;

  @override
  void initState() {
    _scrollController = ScrollController();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels > 180 && isDetails) {
        setState(() {
          isDetails = false;
        });
      }
      if (_scrollController.position.pixels <= 180 && !isDetails) {
        setState(() {
          isDetails = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme().dark,
      child: Scaffold(
        body: Center(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // CustomSliverAppbar(),
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.width,
                forceElevated: true,
                elevation: 5.0,
                stretchTriggerOffset: 100.0,
                stretch: true,
                onStretchTrigger: () async {
                  debugPrint('stretched');
                },
                actions: [
                  if (!isDetails)
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.favorite_outline,
                        color: Colors.pinkAccent[400],
                      ),
                    ),
                ],
                pinned: true,
                backgroundColor: Colors.blue,
                leading: ClipOval(
                  child: ColoredBox(
                    color:
                        Colors.grey.withValues(alpha: isDetails ? 0.38 : 0.0),
                    child: const CupertinoNavigationBarBackButton(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black87,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(rect),
                    blendMode: BlendMode.darken,
                    child: Image.network(
                      'https://img.yts.mx/assets/images/movies/the_suicide_squad_2021/medium-cover.jpg',
                      errorBuilder: (c, e, s) => const Center(
                        child: Text('😥'),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  stretchModes: const [StretchMode.zoomBackground],
                  centerTitle: true,
                  title: _detailsCard,
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    return ListTile(
                      leading: const Icon(Icons.list),
                      title: Text('$i'),
                    );
                  },
                  childCount: 50,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _detailsCard => AnimatedContainer(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        width: double.infinity,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.grey[400]?.withValues(alpha: isDetails ? 0.38 : 0.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: isDetails
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                _title,
                if (isDetails)
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_outline,
                      color: Colors.pinkAccent[400],
                    ),
                  ),
              ],
            ),
            if (isDetails)
              Wrap(
                spacing: 4.0,
                alignment: WrapAlignment.start,
                children: [
                  Chip(
                    label: const Text('Action'),
                    backgroundColor: Colors.pink,
                    padding: EdgeInsets.zero,
                    labelStyle:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 10.0,
                            ),
                  ),
                  Chip(
                    label: const Text('2.30 Hours'),
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.zero,
                    labelStyle:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 10.0,
                            ),
                  ),
                  Chip(
                    label: const Text('7.8'),
                    // avatar: Icon(Icons.star),
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.zero,
                    labelStyle:
                        Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontSize: 10.0,
                            ),
                  ),
                ],
              ),
          ],
        ),
      );

  Widget get _title => const Text('The Suicide Squad');
}
