// Path: frontend/lib/features/export/presentation/bloc/export_state.dart
import 'package:equatable/equatable.dart';
import '../../domain/entities/export_job_entity.dart';

abstract class ExportState extends Equatable {
  const ExportState();

  @override
  List<Object?> get props => [];
}

class ExportInitial extends ExportState {
  const ExportInitial();
}

class ExportLoading extends ExportState {
  final String message;

  const ExportLoading({this.message = 'Processing...'});

  @override
  List<Object?> get props => [message];
}

class ExportJobCreated extends ExportState {
  final ExportJobEntity exportJob;

  const ExportJobCreated(this.exportJob);

  @override
  List<Object?> get props => [exportJob];
}

class ExportCompleted extends ExportState {
  final String filePath;
  final String fileName;

  const ExportCompleted(this.filePath, this.fileName);

  @override
  List<Object?> get props => [filePath, fileName];
}

class ExportHistoryLoaded extends ExportState {
  final List<ExportJobEntity> exports;

  const ExportHistoryLoaded(this.exports);

  @override
  List<Object?> get props => [exports];
}

// เพิ่ม state ใหม่สำหรับ History download พร้อม export list
class ExportHistoryDownloadSuccess extends ExportState {
  final String fileName;
  final List<ExportJobEntity> exports;

  const ExportHistoryDownloadSuccess(this.fileName, this.exports);

  @override
  List<Object?> get props => [fileName, exports];
}

class ExportError extends ExportState {
  final String message;

  const ExportError(this.message);

  @override
  List<Object?> get props => [message];
}
