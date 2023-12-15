import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class MovieDownloaderIsolate {
  StreamController<double> downloadPercentageController =
      StreamController<double>.broadcast();

  //  downloadPercentageController.sink
  //                 .add((cumulative / event["total"]) * 100);

  ReceivePort rp = ReceivePort();

  Future<void> downloadFile({required String fileUrl}) async {
    try {
      //get app directory to saved video.
      final Directory? directory = await getExternalStorageDirectory();
      var videoSaveDir = await Directory(directory!.path).create();

      final downloaderIsolate =
          await Isolate.spawn(transferFileDownloadRate, rp.sendPort);

      final boardCastRp = rp.asBroadcastStream();
      // received the send port.
      final SendPort transferFileSendPort = await boardCastRp.first;
      //send the download url to transferFileDownload
      transferFileSendPort.send(fileUrl);
      int currentPosition = 0;
      double cumulative = 0;
      double total = 0;
      RandomAccessFile file =
          await File(path.join(videoSaveDir.path, path.basename(fileUrl)))
              .open(mode: FileMode.write);

      boardCastRp.listen((event) async {
        if (event is Map) {
          if (event.containsKey("total")) {
            total = event["total"];
          }

          if (event.keys.contains("byte_in_chunck") && event.keys.isNotEmpty) {
            try {
              List<int> chunckBytes = event["byte_in_chunck"];
              int startByte = currentPosition;
              int endByte = currentPosition + chunckBytes.length;
              currentPosition = endByte;
              cumulative += event["byte_in_chunck"].length / (1024 * 1024);

              file.setPositionSync(startByte);
              file.writeFromSync(event["byte_in_chunck"]);
              downloadPercentageController.sink.add((cumulative / total));
            } catch (e) {
              print("error =======$e");
            }
          } else {
            if (event["download_status"] == "completed") {
              await file.close();

              downloadPercentageController.close();
              // killing the isolate once file is downloaded.
              downloaderIsolate.kill();
            }
          }
        }
      });
    } catch (e, s) {
      print("stack trace===> $s");
      print("error trace===> $e");
    }
  }
}

Future<void> transferFileDownloadRate(SendPort sp) async {
  HttpClient httpClient = HttpClient();
  ReceivePort rp = ReceivePort();
  // sending the sendport from downloadFile receiveport to receiver the video download url.
  sp.send(rp.sendPort);

  final videoUrls = rp.takeWhile((element) => element is String).cast<String>();

  await for (final videoUrl in videoUrls) {
    var request = await httpClient.getUrl(Uri.parse(videoUrl));
    var response = await request.close();
    if (response.statusCode == 200) {
      final double fileSizeInMB = response.contentLength / (1024 * 1024);

      sp.send({"total": fileSizeInMB});

      double totalChuckDownload = 0;
      response.listen(
        (List<int> fileChunck) {
          totalChuckDownload += fileChunck.length / (1024 * 1024);
          sp.send({"cumulative": totalChuckDownload});
          sp.send({"byte_in_chunck": fileChunck});
        },
        onDone: () {
          sp.send({"download_status": "completed"});
        },
      );
    }
  }
}
