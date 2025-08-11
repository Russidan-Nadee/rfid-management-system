import 'package:equatable/equatable.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object> get props => [];
}

class LoadMyReports extends ReportsEvent {
  const LoadMyReports();
}

class RefreshMyReports extends ReportsEvent {
  const RefreshMyReports();
}