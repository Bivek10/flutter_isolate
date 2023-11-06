import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/core/services/app_repository/album_repo.dart';
import 'package:flutter_isolate/model/album_reponse_model.dart';

class LocalAlbum implements AlbumRepo {
  @override
  Future<List<AlbumResponse>> getAlbum() async {
    String albumData = await rootBundle.loadString('assets/tempdata.json');

    return await compute(parseAlbum, albumData);
    // return await compute(AlbumResponse.fromJson, albumJson);
    // IsolateManager isolate = IsolateManager();
    // IsolateRepository isolateInstance =
    //     isolate.getIsolate(isolateType: "inbuilt");

    //return await isolateInstance.initIsolate(AlbumResponse.fromJson, albumJson);
  }

  List<AlbumResponse> parseAlbum(String ablumData) {
    final List<dynamic> ablumJson = jsonDecode(ablumData);
    return ablumJson.map((e) => AlbumResponse.fromJson(e)).toList();
  }
}
