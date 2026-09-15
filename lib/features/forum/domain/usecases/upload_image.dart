import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failure.dart';
import '../repositories/media_repository.dart';

class UploadImage {
  const UploadImage(this.repository);

  final MediaRepository repository;

  Future<Either<Failure, String>> call(File file) {
    return repository.uploadImage(file);
  }
}
