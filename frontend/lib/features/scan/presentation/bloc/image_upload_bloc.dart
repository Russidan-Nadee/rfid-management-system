// Path: frontend/lib/features/scan/presentation/bloc/image_upload_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:io';
import '../../domain/usecases/upload_image_usecase.dart';

// Events
abstract class ImageUploadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadImageEvent extends ImageUploadEvent {
  final String assetNo;
  final File imageFile;

  UploadImageEvent({required this.assetNo, required this.imageFile});

  @override
  List<Object?> get props => [assetNo, imageFile];
}

// States
abstract class ImageUploadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ImageUploadInitial extends ImageUploadState {}

class ImageUploadLoading extends ImageUploadState {}

class ImageUploadSuccess extends ImageUploadState {
  final String assetNo;

  ImageUploadSuccess({required this.assetNo});

  @override
  List<Object?> get props => [assetNo];
}

class ImageUploadError extends ImageUploadState {
  final String message;

  ImageUploadError({required this.message});

  @override
  List<Object?> get props => [message];
}

// BLoC
class ImageUploadBloc extends Bloc<ImageUploadEvent, ImageUploadState> {
  final UploadImageUseCase uploadImageUseCase;

  ImageUploadBloc({required this.uploadImageUseCase})
    : super(ImageUploadInitial()) {
    on<UploadImageEvent>(_onUploadImage);
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<ImageUploadState> emit,
  ) async {
    emit(ImageUploadLoading());

    try {
      final success = await uploadImageUseCase.execute(
        event.assetNo,
        event.imageFile,
      );

      if (success) {
        emit(ImageUploadSuccess(assetNo: event.assetNo));
      } else {
        emit(ImageUploadError(message: 'Upload failed'));
      }
    } catch (error) {
      emit(ImageUploadError(message: error.toString()));
    }
  }
}
