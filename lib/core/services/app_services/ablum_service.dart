import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/core/services/app_repository/album_repo.dart';
import 'package:flutter_isolate/model/album_reponse_model.dart';

class LocalAlbum implements AlbumRepo {
  @override
  Future<List<AlbumResponse>> getAlbum() async {
    String albumData = await rootBundle.loadString('assets/tempdata.json');
    final List<dynamic> albumJson = jsonDecode(albumData);
    return albumJson.map((e) => AlbumResponse.fromJson(e)).toList();
  }

  List<AlbumResponse> parseAlbum(String data) {
    final List<dynamic> jsonData = jsonDecode(data);
    return jsonData.map((e) => AlbumResponse.fromJson(e)).toList();
  }

  @override
  Future<List<AlbumResponse>> runIsolate() async {
    String albumData = await rootBundle.loadString('assets/tempdata.json');
    return await compute(parseAlbum, albumData);
  }
}

class LocalAlbumService implements AlbumRepo {
  @override
  Future<List<AlbumResponse>> getAlbum() async {
    String albumData = await rootBundle.loadString('assets/tempdata.json');
    final List<dynamic> albumJson = jsonDecode(albumData);
    return albumJson.map((e) => AlbumResponse.fromJson(e)).toList();
  }

  @override
  Future<List<AlbumResponse>> runIsolate() async {
    WidgetsFlutterBinding.ensureInitialized();
    return await Isolate.run(getAlbum);
    // IsolateManager isolateManager = IsolateManager();
    // IsolateRepository isolate =
    //     isolateManager.getIsolate(isolateType: "custom");
    // return await isolate.initIsolate(getAlbum);
  }
}

class CustomIsolate {
  parsedAlbum(SendPort sendPort) async {
    WidgetsFlutterBinding.ensureInitialized();
    String albumData = await rootBundle.loadString('assets/tempdata.json');
    final List<dynamic> albumJson = jsonDecode(albumData);
    sendPort.send(albumJson.map((e) => AlbumResponse.fromJson(e)).toList());
  }

  getAlbum() async {
    ReceivePort receivePort = ReceivePort();
    Isolate isolate = await Isolate.spawn(parsedAlbum, receivePort.sendPort);
    receivePort.listen((message) {
      if (message is List<AlbumResponse>) {
        print("album data::: ${message[0].albumId}");
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      isolate.kill();
      receivePort.close();
    });
  }
}
