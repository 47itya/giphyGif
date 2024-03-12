import 'package:flutter/material.dart';
import 'package:giphyGif/src/model/giphy_repository.dart';
import 'package:giphyGif/src/widgets/giphy_error_view.dart';
import 'package:giphyGif/src/widgets/giphy_search_page.dart';
import 'package:giphyGif/src/widgets/giphy_search_text.dart';
import 'package:giphyGif/src/widgets/giphy_thumbnail_grid.dart';

import '../../giphy_picker.dart';

/// Defines the function for building pages.
typedef PageBuilder = Widget Function(BuildContext context, Widget? title);

/// Defines the function for building search text editors.
typedef SearchTextBuilder = Widget Function(BuildContext context,
    TextEditingController controller, ValueChanged<String> onChanged);

/// Defines the function for displaying search results.
typedef ResultsBuilder = Widget Function(BuildContext context,
    GiphyRepository repo, ScrollController scrollController);

/// Defines the function for displaying runtime errors.
typedef SearchErrorBuilder = Widget Function(
    BuildContext context, Object error);

/// Provides the context for a Giphy search operation, and makes its data available to its widget sub-tree.
class GiphyContext extends InheritedWidget {
  final String apiKey;
  final String rating;
  final String language;
  final bool sticker;
  final ValueChanged<GiphyGif>? onSelected;
  final ErrorListener? onError;
  final bool showPreviewPage;
  final bool showGiphyAttribution;
  final String searchHintText;
  final GiphyPreviewType? previewType;
  final PageBuilder pageBuilder;
  final SearchTextBuilder searchTextBuilder;
  final WidgetBuilder loadingBuilder;
  final ResultsBuilder resultsBuilder;
  final WidgetBuilder noResultsBuilder;
  final SearchErrorBuilder errorBuilder;

  /// Debounce delay when searching
  final Duration searchDelay;

  const GiphyContext(
      {super.key,
      required super.child,
      required this.apiKey,
      this.rating = GiphyRating.g,
      this.language = GiphyLanguage.english,
      this.sticker = false,
      this.onSelected,
      this.onError,
      this.showPreviewPage = true,
      this.showGiphyAttribution = true,
      this.searchHintText = 'Search Giphy',
      this.searchDelay = const Duration(milliseconds: 500),
      this.previewType,
      PageBuilder? pageBuilder,
      SearchTextBuilder? searchTextBuilder,
      WidgetBuilder? loadingBuilder,
      ResultsBuilder? resultsBuilder,
      WidgetBuilder? noResultsBuilder,
      SearchErrorBuilder? errorBuilder})
      : pageBuilder = pageBuilder ?? _buildDefaultPage,
        searchTextBuilder = searchTextBuilder ?? _buildDefaultSearchText,
        loadingBuilder = loadingBuilder ?? _buildDefaultLoading,
        resultsBuilder = resultsBuilder ?? _buildDefaultResults,
        noResultsBuilder = noResultsBuilder ?? _buildDefaultNoResults,
        errorBuilder = errorBuilder ?? _buildDefaultError;

  void select(GiphyGif gif) => onSelected?.call(gif);
  void error(dynamic error) => onError?.call(error);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => false;

  static GiphyContext of(BuildContext context) {
    final giphy = context
        .getElementForInheritedWidgetOfExactType<GiphyContext>()
        ?.widget as GiphyContext?;

    if (giphy == null) {
      throw 'Required GiphyContext widget not found. Make sure to wrap your widget with GiphyContext.';
    }
    return giphy;
  }

  static Widget _buildDefaultPage(BuildContext context, Widget? title) =>
      GiphySearchPage(title: title);

  static Widget _buildDefaultSearchText(
    BuildContext context,
    TextEditingController controller,
    ValueChanged<String> onChanged,
  ) =>
      GiphySearchText(controller: controller, onChanged: onChanged);

  static Widget _buildDefaultLoading(BuildContext context) =>
      const Center(child: CircularProgressIndicator());

  static Widget _buildDefaultResults(
    BuildContext context,
    GiphyRepository repo,
    ScrollController scrollController,
  ) =>
      GiphyThumbnailGrid(
          key: Key('${repo.hashCode}'),
          repo: repo,
          scrollController: scrollController);

  static Widget _buildDefaultNoResults(BuildContext context) =>
      const Center(child: Text('No results'));

  static Widget _buildDefaultError(BuildContext context, Object error) =>
      GiphyErrorView(error: error);
}
