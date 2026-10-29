/// The outcome of an operation: either a [Success] carrying a value of type
/// [T], or a [Failure] carrying an error message and an optional code.
///
/// Raw exceptions never cross layer boundaries — repositories and use cases
/// return a [Result] instead.
sealed class Result<T> {
  const Result();

  /// Whether this result is a [Success].
  bool get isSuccess => this is Success<T>;

  /// Whether this result is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// The success value, or `null` when this is a [Failure].
  T? get dataOrNull => switch (this) {
        Success<T>(:final data) => data,
        Failure<T>() => null,
      };

  /// The failure message, or `null` when this is a [Success].
  String? get errorMessageOrNull => switch (this) {
        Failure<T>(:final message) => message,
        Success<T>() => null,
      };

  /// The failure code, or `null` when this is a [Success].
  String? get errorCodeOrNull => switch (this) {
        Failure<T>(:final code) => code,
        Success<T>() => null,
      };

  /// Folds the result into a single value.
  R when<R>({
    required R Function(T data) onSuccess,
    required R Function(String message, String? code) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data) => onSuccess(data),
        Failure<T>(:final message, :final code) => onFailure(message, code),
      };

  /// Maps the success value to another type; failures pass through unchanged.
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success<T>(:final data) => Success(transform(data)),
        Failure<T>(:final message, :final code) =>
          Failure<R>(message, code: code),
      };
}

/// A successful [Result] wrapping [data].
final class Success<T> extends Result<T> {
  const Success(this.data);

  /// The value produced by the operation.
  final T data;
}

/// A failed [Result] wrapping an error [message] and an optional [code].
final class Failure<T> extends Result<T> {
  const Failure(this.message, {this.code});

  /// Human-readable error message.
  final String message;

  /// Machine-readable error code (e.g. `invalid_coupon`).
  final String? code;
}
