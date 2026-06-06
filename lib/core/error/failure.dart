/// Base type for all expected, recoverable error conditions in Mindow.
///
/// Failures are returned (not thrown) across feature boundaries so that the
/// UI can pattern-match exhaustively. Unexpected programmer errors should
/// still throw.
sealed class Failure {
  const Failure(this.message);

  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No network connection']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Invalid input']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong']);
}
