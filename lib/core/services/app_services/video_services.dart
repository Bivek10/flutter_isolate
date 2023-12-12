import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/core/services/app_repository/video_repo.dart';
import 'package:flutter_isolate/model/video_model.dart';

class VideoServices extends VideoRepo {
  @override
  Future<Either<MoviesModel, Exception>> getMovies() async {
    MoviesModel? moviesModel;
    try {
      final videoStringData =
          await rootBundle.loadString("assets/video_data.json");
      final parsedData = json.decode(videoStringData);
      moviesModel = MoviesModel.fromJson(parsedData);

      return left(moviesModel);
    } catch (e) {
      if (e is VideoParseException) {
        return Right(VideoParseException("VideoParseException: ${e.message}"));
      } else {
        return Right(
          Exception(e),
        );
      }
    }
  }
}

class VideoParseException implements Exception {
  final String message;

  VideoParseException(this.message);

  @override
  String toString() {
    return "VideoParseException: $message";
  }
}
