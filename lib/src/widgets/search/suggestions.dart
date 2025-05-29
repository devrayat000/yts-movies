part of app_widget.search;

class SearchSuggestions extends StatelessWidget {
  final List<String> history;
  final Future<List<Movie>>? future;
  final void Function(int) onShowHistory;
  final VoidCallback onTap;

  const SearchSuggestions({
    super.key,
    required this.history,
    required this.future,
    required this.onShowHistory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (future == null) {
      return _buildHistoryView(context);
    }

    return FutureBuilder<List<Movie>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return _buildHistoryView(context);
        }

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return _buildMovieResults(context, snapshot.data!);
        }

        return _buildHistoryView(context);
      },
    );
  }

  Widget _buildHistoryView(BuildContext context) {
    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: history.length,
      itemBuilder: (context, index) {
        return _buildHistoryItem(context, history[index], index);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Search for movies',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find your favorite movies by title, genre, or year',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, String query, int index) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onShowHistory(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.history,
              size: 20,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                query,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Icon(
              Icons.call_made,
              size: 18,
              color: Colors.grey[500],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieResults(BuildContext context, List<Movie> movies) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        return _buildMovieItem(context, movies[index]);
      },
    );
  }

  Widget _buildMovieItem(BuildContext context, Movie movie) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        onTap();
        Navigator.of(context).pop();
        context.push('/movie/${movie.id}');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 120,
                height: 68,
                child: CachedNetworkImage(
                  imageUrl: movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.movie,
                      color: Colors.grey[400],
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Movie details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${movie.year}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      if (movie.genres.isNotEmpty) ...[
                        Text(
                          ' • ',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        Flexible(
                          child: Text(
                            movie.genres.take(2).join(', '),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: Colors.amber[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${movie.rating}/10',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        ' • ${movie.runtime}m',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // More options button
            IconButton(
              onPressed: () {
                // TODO: Show movie options menu
              },
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey[600],
                size: 20,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
