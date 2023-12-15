import 'package:dartz/dartz.dart';

import '../../../model/video_model.dart';

abstract class VideoRepo {
  Future<Either<MoviesModel, Exception>> getMovies();
}
