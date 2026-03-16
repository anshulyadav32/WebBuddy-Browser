/// Application error types following a consistent pattern.
sealed class AppError implements Exception {
  final String message;
  final Object? cause;

  const AppError(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message${cause != null ? ' (cause: $cause)' : ''}';
}

class NetworkError extends AppError {
  const NetworkError(super.message, [super.cause]);
}

class StorageError extends AppError {
  const StorageError(super.message, [super.cause]);
}

class NavigationError extends AppError {
  const NavigationError(super.message, [super.cause]);
}

class PermissionError extends AppError {
  const PermissionError(super.message, [super.cause]);
}

class FilterParseError extends AppError {
  const FilterParseError(super.message, [super.cause]);
}
