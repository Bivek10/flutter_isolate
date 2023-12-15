import 'package:flutter_isolate/model/album_reponse_model.dart';

abstract class AlbumRepo {
  Future<List<AlbumResponse>> getAlbum();
  Future<List<AlbumResponse>> runIsolate();
}
