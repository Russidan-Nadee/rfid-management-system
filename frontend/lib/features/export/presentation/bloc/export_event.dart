// Path: frontend/lib/features/export/presentation/bloc/export_event.dart
import 'package:equatable/equatable.dart';

abstract class ExportEvent extends Equatable {
  const ExportEvent();

  @override
  List<Object?> get props => [];
}

class CreateAssetExport extends ExportEvent {
  final String format;

  const CreateAssetExport(this.format);

  @override
  List<Object?> get props => [format];
}

class CheckExportStatus extends ExportEvent {
  final int exportId;

  const CheckExportStatus(this.exportId);

  @override
  List<Object?> get props => [exportId];
}

class DownloadExport extends ExportEvent {
  final int exportId;

  const DownloadExport(this.exportId);

  @override
  List<Object?> get props => [exportId];
}

// เพิ่ม event ใหม่สำหรับ History
class DownloadHistoryExport extends ExportEvent {
  final int exportId;

  const DownloadHistoryExport(this.exportId);

  @override
  List<Object?> get props => [exportId];
}

class LoadExportHistory extends ExportEvent {
  const LoadExportHistory();
}