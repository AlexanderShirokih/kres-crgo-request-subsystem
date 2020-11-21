/// Used to lazily build instance of specified object
typedef LazyInstanceBuilder<T> = T Function();

/// Used to lazily build future that creates instance of specified object
typedef AsyncLazyInstanceBuilder<T> = Future<T> Function();

/// Container for lazy field initialization
class Lazy<T> {
  final LazyInstanceBuilder<T> _instanceBuilder;
  T _instance;

  Lazy(this._instanceBuilder) : assert(_instanceBuilder != null);

  /// Returns previously created instance or creates new.
  T get instance {
    if (_instance == null) {
      _instance = _instanceBuilder();
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
