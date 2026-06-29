import 'package:fpdart/fpdart.dart';
import '../errors/failures.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureEitherVoid = Future<Either<Failure, Unit>>;
