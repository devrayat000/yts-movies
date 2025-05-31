part of 'index.dart';

class SearchTile extends StatelessWidget {
  const SearchTile({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.pushNamed("search"),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.blueGrey[800]!.withAlpha((0.9 * 255).toInt()),
                    Colors.blueGrey[900]!.withAlpha((0.9 * 255).toInt()),
                  ]
                : [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withAlpha((0.3 * 255).toInt())
                  : Colors.grey.withAlpha((0.15 * 255).toInt()),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          enabled: false, // Make it non-interactive, just for display
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: '🔍 Search for movies...',
            hintStyle: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            fillColor: Colors.transparent,
            filled: true,
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.withAlpha((0.8 * 255).toInt()),
                    Colors.indigo.withAlpha((0.8 * 255).toInt()),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
