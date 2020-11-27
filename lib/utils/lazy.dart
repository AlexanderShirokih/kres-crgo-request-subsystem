/// Used to lazily build instance of specified object
typedef LazyInstanceBuilder<T> = T Function();

/// Used to lazily build future that creates instance of specified object
typedef AsyncLazyInstanceBuilder<T> = Future<T> Function();

/// Container for lazy field initialization
class Lazy<T> {
  T _instance;

  /// Returns once created previous field value or creates new of not created yet.
  T getValue(LazyInstanceBuilder<T> instanceBuilder) {
    if (_instance == null) {
      _instance = instanceBuilder();
    }
    return _instance;
  }
}

/// Container for asynchronous lazy field initialization
class AsyncLazy<T> {
  final AsyncLazyInstanceBuilder<T> _asyncLazyInstanceBuilder;
  T _instance;

  AsyncLazy(this._asyncLazyInstanceBuilder)
      : assert(_asyncLazyInstanceBuilder != null);

  /// Returns previously created instance or creates new.
  Future<T> get instance async {
    if (_instance == null) {
      _instance = await _asyncLazyInstanceBuilder();
    }
    return _instance;
  }
}
