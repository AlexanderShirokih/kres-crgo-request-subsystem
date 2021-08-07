/// Base asyncronous use case without input parameters
abstract class AsyncUseCase<O> {
  Future<O> call();
}
