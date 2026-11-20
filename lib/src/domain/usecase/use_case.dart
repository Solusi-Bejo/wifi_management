/// One application action. [T] is the full return type (`Future<X>` or
/// `Stream<X>`); [P] is [NoParams] when the action takes no input.
abstract class UseCase<T, P> {
  const UseCase();

  T call(P params);
}

final class NoParams {
  const NoParams();
}
