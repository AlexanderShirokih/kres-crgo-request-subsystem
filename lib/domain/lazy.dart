typedef LazyBuilder<T> = T Function();
typedef AsyncLazyBuilder<T> = Future<T> Function();

/// Container that lazily creates singleton instances of classes
class LazyInitializer<T> {
  final LazyBuilder<T> builder;

  T? _instance;

  LazyInitializer(this.builder);

  T call() {
    return _instance ??= builder();
  }
}

class Lazy<T> {
  T? _instance;

  T call(LazyBuilder<T> builder) {
    return _instance ??= builder();
  }
}

class AsyncLazy<T> {
  T? _instance;

  Future<T> call(AsyncLazyBuilder<T> builder) async {
    return _instance ??= await builder();
  }
}
