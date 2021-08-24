part of app_widgets;

class TorrentTab extends StatelessWidget {
  final List<Torrent> _torrents;
  const TorrentTab({Key? key, required List<Torrent> torrents})
      : _torrents = torrents,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _torrents.length,
      child: Container(
        height: 240,
        constraints: const BoxConstraints(maxHeight: 250),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          border: Border.all(
            color: Theme.of(context).scaffoldBackgroundColor,
            width: 2.0,
          ),
        ),
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              tabs: _tabs,
            ),
            Expanded(
              child: ColoredBox(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: TabBarView(
                  children: _tabViews(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> get _tabs {
    return _torrents.map((e) => Tab(text: '${e.quality}-${e.type}')).toList();
  }

  List<Widget> _tabViews(BuildContext context) {
    return _torrents
        .map(
          (torrent) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ListTile.divideTiles(
                context: context,
                tiles: [
                  ListTile(
                    leading: Icon(Icons.folder),
                    title: Text(torrent.size),
                  ),
                  ListTile(
                    leading: Icon(Icons.fit_screen),
                    title: Text(torrent.quality),
                  ),
                  ListTile(
                    leading: Text(
                      'P/S',
                      style: Theme.of(context).textTheme.headline5?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                            fontSize: 20,
                          ),
                    ),
                    title: Text('${torrent.peers} / ${torrent.seeds}'),
                  ),
                ],
              ).toList(),
            ),
          ),
        )
        .toList();
  }
}
