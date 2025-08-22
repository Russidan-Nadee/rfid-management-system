import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/notification_service.dart';
import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final NotificationService _notificationService;

  ReportsBloc(this._notificationService) : super(const ReportsInitial()) {
    on<LoadMyReports>(_onLoadMyReports);
    on<RefreshMyReports>(_onRefreshMyReports);
  }

  Future<void> _onLoadMyReports(
    LoadMyReports event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    await _loadReports(emit);
  }

  Future<void> _onRefreshMyReports(
    RefreshMyReports event,
    Emitter<ReportsState> emit,
  ) async {
    await _loadReports(emit);
  }

  Future<void> _loadReports(Emitter<ReportsState> emit) async {
    try {
      final result = await _notificationService.getMyReports();

      if (result.success && result.data != null) {
        emit(ReportsLoaded(reports: result.data!));
      } else {
        emit(ReportsError(message: result.message));
      }
    } catch (e) {
      emit(ReportsError(message: 'Error loading reports: ${e.toString()}'));
    }
  }
}
