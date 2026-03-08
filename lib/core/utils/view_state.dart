enum ViewStateStatus {
  loading,
  success,
  error,
}

class ViewState<T> {
  const ViewState._(this.status, [this._data, this._message]);

  factory ViewState.loading() => ViewState._(ViewStateStatus.loading);
  factory ViewState.success(T data) =>
      ViewState._(ViewStateStatus.success, data);
  factory ViewState.error(String message) =>
      ViewState._(ViewStateStatus.error, null, message);

  final ViewStateStatus status;
  final T? _data;
  final String? _message;

  bool get isLoading => status == ViewStateStatus.loading;
  T? get valueOrNull => _data;
  String? get errorOrNull => _message;

  R when<R>({
    required R Function() loading,
    required R Function(T data) success,
    required R Function(String message) error,
  }) {
    return switch (status) {
      ViewStateStatus.loading => loading(),
      ViewStateStatus.success => success(_data as T),
      ViewStateStatus.error => error(_message!),
    };
  }
}
