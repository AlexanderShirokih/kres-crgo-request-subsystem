typedef LazyBuilder<T> = T Function();
typedef AsyncLazyBuilder<T> = Future<T> Function();

/// Container that lazily creates singleton instances of classes
class LazyInitializer<T> {
  final LazyBuilder<T> builder;

  T /*?*/ _instance;

  LazyInitializer(this.builder);

  T call() {
    _instance ??= builder();
    return _instance;
  }
}

class Lazy<T> {
  T /*?*/ _instance;

  T call(LazyBuilder<T> builder) {
    _instance ??= builder();
    return _instance;
  }
}

class AsyncLazy<T> {
  T /*?*/ _instance;

  Future<T> call(AsyncLazyBuilder<T> builder) async {
    _instance ??= await builder();
    return _instance;
  }
}
