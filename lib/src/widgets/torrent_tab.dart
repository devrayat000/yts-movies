part of app_widgets;

class TorrentTab extends StatelessWidget {
  final List<Torrent> _torrents;
  const TorrentTab({super.key, required List<Torrent> torrents})
      : _torrents = torrents;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: _torrents.length,
      child: Container(
        height: 212,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            TabBar(
              isScrollable: true,
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
              indicator: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16.0),
              ),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              labelColor: Colors.white,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withOpacity(0.7),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: _tabs,
              tabAlignment: _torrents.length > 2
                  ? TabAlignment.start
                  : TabAlignment.center,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
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
    return _torrents
        .map((e) => Tab(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '${e.quality}${e.type != null ? ' ${e.type!.toUpperCase()}' : ''}',
                ),
              ),
            ))
        .toList();
  }

  List<Widget> _tabViews(BuildContext context) {
    final theme = Theme.of(context);

    return _torrents
        .map(
          (torrent) => Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _modernInfoCard(
                context,
                icon: Icons.folder_rounded,
                title: 'File Size',
                value: torrent.size,
                color: theme.colorScheme.primary,
              ),
              _modernInfoCard(
                context,
                icon: Icons.high_quality_rounded,
                title: 'Quality',
                value: torrent.quality,
                color: theme.colorScheme.secondary,
              ),
              _modernInfoCard(
                context,
                icon: Icons.share_rounded,
                title: 'Peers / Seeds',
                value: '${torrent.peers} / ${torrent.seeds}',
                color: Colors.green.shade600,
              ),
            ],
          ),
        )
        .toList();
  }

  Widget _modernInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
