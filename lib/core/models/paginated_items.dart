class PaginatedItems<T> {
  const PaginatedItems({
    required this.items,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasMore,
  });

  final List<T> items;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasMore;
}
