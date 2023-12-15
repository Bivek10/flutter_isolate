import 'dart:async';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../../model/album_reponse_model.dart';

class IsolateWorker {
  static const _baseUrl = 'https://jsonplaceholder.typicode.com/albums';
  late SendPort _sendPort;

  late Isolate _isolate;

  Completer<List<AlbumResponse>>? _ids;

  final _isolateReady = Completer<void>();

  Worker() {
    init();
  }

  Future<void> get isReady => _isolateReady.future;

  void dispose() {
    _isolate.kill();
  }

  Future<void> init() async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();
    errorPort.listen(print);

    receivePort.listen(_handleMessage);
    _isolate = await Isolate.spawn(
      _isolateEntry,
      receivePort.sendPort,
      onError: errorPort.sendPort,
    );
  }

  void _handleMessage(dynamic message) {
    if (message is SendPort) {
      _sendPort = message;
      _isolateReady.complete();
      return;
    }

    if (message is List<AlbumResponse>) {
      _ids?.complete(message);
      _ids = null;
      return;
    }

    throw UnimplementedError("Undefined behavior for message: $message");
  }

  static void _isolateEntry(dynamic message) {
    late SendPort sendPort;
    final receivePort = ReceivePort();

    receivePort.listen((dynamic message) async {
      assert(message is String);
      final client = http.Client();
      try {
        final ids = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        final articles = await _getAlbums(client, ids);
        sendPort.send(articles);
      } finally {
        client.close();
      }
    });

    if (message is SendPort) {
      sendPort = message;
      sendPort.send(receivePort.sendPort);
      return;
    }
  }

  static Future<List<AlbumResponse>> _getAlbums(
      http.Client client, List<int> albumIds) async {
    final results = <AlbumResponse>[];

    var futureAlbums = albumIds.map<Future<void>>((id) async {
      try {
        var article = await _getAlbum(client, id);
        results.add(article);
      } catch (e) {
        print(e);
      }
    });
    await Future.wait(futureAlbums);
    var filtered = results.where((a) => a.title != null).toList();

    return filtered;
  }

  static Future<AlbumResponse> _getAlbum(http.Client client, int id) async {
    var storyUrl = '$_baseUrl/$id/photos';
    AlbumResponse? results;
    try {
      var storyRes = await client.get(Uri.parse(storyUrl));
      if (storyRes.statusCode == 200) {
        results = AlbumResponse.fromJson(storyRes.body as Map<String, dynamic>);
      } else {
        throw "error on fetching album";
      }
    } catch (e) {
      print(e);
    }
    return results!;
  }
}
