// Path: frontend/lib/core/utils/either.dart
abstract class Either<L, R> {
  const Either();

  bool get isLeft;
  bool get isRight;

  L? get left;
  R? get right;

  T fold<T>(T Function(L) leftFunction, T Function(R) rightFunction);

  Either<L, T> map<T>(T Function(R) rightFunction);
  Either<T, R> mapLeft<T>(T Function(L) leftFunction);

  Either<L, T> flatMap<T>(Either<L, T> Function(R) rightFunction);
}

class Left<L, R> extends Either<L, R> {
  final L _value;

  const Left(this._value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  L get left => _value;

  @override
  R? get right => null;

  @override
  T fold<T>(T Function(L) leftFunction, T Function(R) rightFunction) {
    return leftFunction(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R) rightFunction) {
    return Left(_value);
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L) leftFunction) {
    return Left(leftFunction(_value));
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) rightFunction) {
    return Left(_value);
  }

  @override
  bool operator ==(Object other) {
    return other is Left && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Left($_value)';
}

class Right<L, R> extends Either<L, R> {
  final R _value;

  const Right(this._value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  L? get left => null;

  @override
  R get right => _value;

  @override
  T fold<T>(T Function(L) leftFunction, T Function(R) rightFunction) {
    return rightFunction(_value);
  }

  @override
  Either<L, T> map<T>(T Function(R) rightFunction) {
    return Right(rightFunction(_value));
  }

  @override
  Either<T, R> mapLeft<T>(T Function(L) leftFunction) {
    return Right(_value);
  }

  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R) rightFunction) {
    return rightFunction(_value);
  }

  @override
  bool operator ==(Object other) {
    return other is Right && other._value == _value;
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() => 'Right($_value)';
}

// Unit type for operations that don't return meaningful data
class Unit {
  const Unit();

  @override
  bool operator ==(Object other) => other is Unit;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'Unit()';
}

const unit = Unit();
