import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:surdotv_app/features/search/viewmodels/search_viewmodel.dart';
import 'package:surdotv_app/widgets/common_widgets.dart';
import 'package:surdotv_app/widgets/video_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onQueryChanged);
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final searchVm = context.read<SearchViewModel>();
      if (searchVm.recommendations.isEmpty &&
          !searchVm.isLoadingRecommendations) {
        searchVm.loadRecommendations();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onQueryChanged)
      ..dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      context.read<SearchViewModel>().loadMore();
    }
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }
    _scrollController.jumpTo(0);
  }

  void _onQueryChanged() {
    setState(() {});

    final query = _controller.text.trim();
    final vm = context.read<SearchViewModel>();
    _debounce?.cancel();

    if (query.isEmpty) {
      _scrollToTop();
      vm.clearResults();
      return;
    }

    if (query.length < 2) {
      _scrollToTop();
      vm.clearResults();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      vm.search(query);
    });
  }

  void _submitSearch([String? value]) {
    _debounce?.cancel();
    final query = (value ?? _controller.text).trim();
    if (query.isEmpty) {
      context.read<SearchViewModel>().clearResults();
      return;
    }
    if (query.length < 2) {
      setState(() {});
      return;
    }

    _focusNode.unfocus();
    _scrollToTop();
    context.read<SearchViewModel>().search(query);
  }

  void _applySuggestion(String phrase) {
    _controller.value = TextEditingValue(
      text: phrase,
      selection: TextSelection.collapsed(offset: phrase.length),
    );
    _submitSearch(phrase);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: const SurdoLogoAppBar(),
      body: Column(
        children: [
          _SearchInput(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _submitSearch,
            onClearTap: () {
              _controller.clear();
              _focusNode.requestFocus();
            },
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: _buildContent(vm),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SearchViewModel vm) {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      return _SearchDiscover(
        isLoadingRecommendations: vm.isLoadingRecommendations,
        recommendations: vm.recommendations,
        recommendationsError: vm.recommendationsErrorMessage,
        onRetryRecommendations: vm.loadRecommendations,
        onSuggestionTap: _applySuggestion,
      );
    }

    if (query.length < 2) {
      return const EmptyStateView(
        message: 'Axtarış üçün ən azı 2 simvol daxil edin.',
      );
    }

    if (vm.isSearching && vm.results.isEmpty) {
      return const LoadingView();
    }

    if (vm.errorMessage != null && vm.results.isEmpty) {
      return ErrorStateView(
        message:
            'Axtarış servisi hazırda əlçatan deyil. Bir az sonra yenidən cəhd edin.',
        onRetry: () => _submitSearch(query),
      );
    }

    if (vm.results.isEmpty) {
      return EmptyStateView(message: '"$query" üçün nəticə tapılmadı.');
    }

    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 900
        ? 4
        : width >= 600
            ? 3
            : 2;

    return RefreshIndicator(
      onRefresh: vm.retryLastSearch,
      child: ListView(
        key: const ValueKey('search-results'),
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Text(
                  '${vm.results.length} nəticə',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (vm.isLoadingMore)
                  const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              shrinkWrap: true,
              primary: false,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 8,
                mainAxisSpacing: 10,
                childAspectRatio: 100 / 80,
              ),
              itemCount: vm.results.length,
              itemBuilder: (context, index) =>
                  VideoCard(video: vm.results[index]),
            ),
          ),
          if (vm.isLoadingMore)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Center(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ),
            ),
          if (vm.loadMoreErrorMessage != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Center(
                child: TextButton.icon(
                  onPressed: vm.loadMore,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Daha cox yukle'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onClearTap,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClearTap;

  @override
  Widget build(BuildContext context) {
    final hasText = controller.text.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Axtar...',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: IconButton(
            onPressed:
                hasText ? onClearTap : () => onSubmitted(controller.text),
            icon: Icon(
              hasText ? Icons.close_rounded : Icons.arrow_forward_rounded,
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchDiscover extends StatelessWidget {
  const _SearchDiscover({
    required this.isLoadingRecommendations,
    required this.recommendations,
    required this.recommendationsError,
    required this.onRetryRecommendations,
    required this.onSuggestionTap,
  });

  final bool isLoadingRecommendations;
  final List<String> recommendations;
  final String? recommendationsError;
  final VoidCallback onRetryRecommendations;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const ValueKey('search-discover'),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
          child: Text(
            'Videolar arasında axtarış edin',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Başlamaq üçün film adı və ya açar söz daxil edin.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
        ),
        if (isLoadingRecommendations)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: LinearProgressIndicator(minHeight: 3),
          ),
        if (recommendations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: recommendations
                  .map(
                    (item) => ActionChip(
                      label: Text(item),
                      onPressed: () => onSuggestionTap(item),
                    ),
                  )
                  .toList(),
            ),
          ),
        if (!isLoadingRecommendations &&
            recommendations.isEmpty &&
            recommendationsError != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.black.withValues(alpha: 0.03),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  'Tövsiyələr yüklənmədi',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontSize: 15),
                ),
                subtitle: Text(
                  recommendationsError!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.black54,
                      ),
                ),
                trailing: IconButton(
                  onPressed: onRetryRecommendations,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
