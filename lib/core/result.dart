
sealed class Result<T, F> {
  const Result();

  factory Result.success(T value) = Success<T, F>;
  factory Result.failure(F error) = Failure<T, F>;

  bool get isSuccess => this is Success<T, F>;
  bool get isFailure => this is Failure<T, F>;

  T? get valueOrNull => switch (this) {
        Success(value: final v) => v,
        Failure() => null,
      };

  F? get errorOrNull => switch (this) {
        Success() => null,
        Failure(error: final e) => e,
      };

  R fold<R>(
    R Function(T value) onSuccess,
    R Function(F error) onFailure,
  ) {
    return switch (this) {
      Success(value: final v) => onSuccess(v),
      Failure(error: final e) => onFailure(e),
    };
  }
}

class Success<T, F> extends Result<T, F> {
  final T value;
  const Success(this.value);
}

class Failure<T, F> extends Result<T, F> {
  final F error;
  const Failure(this.error);
}

/// 공통 에러 객체
class AppFailure {
  final String message;
  final dynamic originalError;

  const AppFailure(this.message, {this.originalError});

  @override
  String toString() => 'AppFailure: $message';
}
