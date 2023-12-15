import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoDownloadService {
  Future<String> downloadFile(String url) async {
    HttpClient httpClient = HttpClient();
    File file;
    String fileName = '';
    String filePath = '';
    try {
      var request = await httpClient.getUrl(Uri.parse(url));
      var response = await request.close();
      if (response.statusCode == 200) {
        print("length ${response.contentLength}");
        final double fileSizeInMB = response.contentLength / (1024 * 1024);
        print("file length ${fileSizeInMB}");
        var bytes = await consolidateHttpClientResponseBytes(
          response,
          onBytesReceived: (cumulative, total) {
            print("cumulative $cumulative");
            print("total $total");
          },
        );
        print("bytes $bytes");
        fileName = getFileNameFromUrl(url);
        final Directory? directory = await getExternalStorageDirectory();
        var knockDir = await Directory('${directory!.path}').create();
        int rand = new math.Random().nextInt(100000);

        print("path exist:: ${await knockDir.exists()}");

        filePath = path.join(knockDir.path, path.basename(url));

        file = File(filePath);

        final x = await file.writeAsBytes(bytes);

        print("file length after writting :: ${await x.length()}");
      } else {
        filePath = 'Error code: ' + response.statusCode.toString();
      }
    } catch (ex) {
      filePath = 'Can not fetch url, ${ex}';
    }

    return filePath;
  }
}

String getFileNameFromUrl(String url) {
  Uri uri = Uri.parse(url);
  return uri.pathSegments.last;
}

String getFileNameWithoutExtension(String url) {
  // Find the last '/' in the URL
  int lastSlashIndex = url.lastIndexOf('/');

  // Extract the substring after the last '/'
  String fileNameWithExtension = url.substring(lastSlashIndex + 1);

  // Find the last '.' in the file name
  int lastDotIndex = fileNameWithExtension.lastIndexOf('.');

  // Extract the substring before the last '.'
  String fileNameWithoutExtension =
      fileNameWithExtension.substring(0, lastDotIndex);

  return fileNameWithoutExtension;
}
