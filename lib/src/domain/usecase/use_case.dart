/// Internal base of the use cases; not exported.
///
/// [T] is the full return type (`Future<X>` or `Stream<X>`). An action without
/// input uses `void` for [P] and overrides with `call([void _])`, so callers
/// write `useCase()`.
abstract class UseCase<T, P> {
  const UseCase();

  T call(P params);
}
