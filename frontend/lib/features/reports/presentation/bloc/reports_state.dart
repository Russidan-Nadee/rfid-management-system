import 'package:equatable/equatable.dart';

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final List<dynamic> reports;

  const ReportsLoaded({required this.reports});

  @override
  List<Object> get props => [reports];
}

class ReportsError extends ReportsState {
  final String message;

  const ReportsError({required this.message});

  @override
  List<Object> get props => [message];
}