import 'package:get_it/get_it.dart';
import '../features/reports/presentation/bloc/reports_bloc.dart';
import '../core/services/notification_service.dart';

final getIt = GetIt.instance;

void configureReportsDependencies() {
  // Reports BLoC
  getIt.registerFactory<ReportsBloc>(
    () => ReportsBloc(getIt<NotificationService>()),
  );
}