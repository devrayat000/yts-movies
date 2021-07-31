import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ytsmovies/providers/filter_provider.dart';
import 'package:ytsmovies/utils/mixins.dart';

import '../providers/mamus_provider.dart';
import '../widgets/appbars/search_appbar.dart';
import '../widgets/drawers/filter_drawer.dart';
import '../widgets/gas_page.dart';
import '../widgets/buttons/grid_list_toggle.dart';

@immutable
class SearchPage extends StatefulWidget {
  static const routeName = '/search';

  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with PageStorageCache<SearchPage> {
  late final TextEditingController _inputController;
  late final Filter _filter;

  final _mamuKey = GlobalKey<MamuMovieListpageState<SearchMamus>>();
  final _searchMamu = SearchMamus();
  final _filterCacheKey = PageStorageKey('movie-filter');

  @override
  void initState() {
    _inputController = TextEditingController();
    _filter = Filter();
    final initialValues = getCache<Filter>(key: _filterCacheKey);
    if (initialValues != null) {
      _filter.initialValues = initialValues;
    }
    super.initState();
  }

  @override
  void dispose() {
    setCache<Filter>(key: _filterCacheKey, data: _filter);
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Filter>.value(
      value: _filter,
      child: MamuMovieListpage<SearchMamus>(
        key: _mamuKey,
        label: 'search',
        handler: _searchMamu,
        appBar: SearchAppbar(
          controller: _inputController,
          onSearch: () {
            _searchMamu.search({
              'query_term': _inputController.text,
              ..._filter.values,
            });
            _mamuKey.currentState
              ?..refresh()
              ..scrollToTop();
          },
          onSuggest: _searchMamu.listMoviesSearch,
        ),
        endDrawer: SearchFilterDrawer(
            key: _filterCacheKey,
            onApplyFilter: () {
              _searchMamu.search(
                {
                  'query_term': _inputController.text,
                  ..._filter.values,
                },
              );
              _mamuKey.currentState?.scrollToTop();
              Navigator.pop(context);
              _mamuKey.currentState?.refresh();
            }),
        actions: [
          IconButton(
            onPressed: () {
              _mamuKey.currentState?.scaffoldState?.openEndDrawer();
            },
            icon: const Icon(Icons.filter_alt_outlined),
            splashRadius: 20,
          ),
          GridListToggle(controller: _mamuKey.currentState?.scrollController),
        ],
        noItemBuilder: (context) => Center(
          child: Text(
              'Search for movies using Movie Title/IMDb Code, Actor Name/IMDb Code, Director Name/IMDb Code'),
        ),
      ),
    );
  }
}
