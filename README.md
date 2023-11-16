# flutter_isolate

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


import 'package:flutter/material.dart';
import 'dart:isolate';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Isolate Example'),
        ),
        body: Center(
          child: DownloadButton(),
        ),
      ),
    );
  }
}

class DownloadButton extends StatefulWidget {
  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool _downloading = false;

  void _startDownload() async {
    setState(() {
      _downloading = true;
    });

    final receivePort = ReceivePort();

    // Create an isolate to perform the download and file I/O
    Isolate.spawn(downloadFile, receivePort.sendPort);

    receivePort.listen((message) {
      if (message is String) {
        // Handle the download result
        print('Downloaded file path: $message');
      } else {
        // Handle errors
        print('Error: $message');
      }
      receivePort.close();
      setState(() {
        _downloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_downloading)
          CircularProgressIndicator()
        else
          ElevatedButton(
            onPressed: _startDownload,
            child: Text('Start Download'),
          ),
      ],
    );
  }
}

void downloadFile(SendPort sendPort) async {
  final url = 'https://example.com/samplefile.txt';
  final directory = await getApplicationDocumentsDirectory();
  final filePath = '${directory.path}/samplefile.txt';

  try {
    final response = await HttpClient().getUrl(Uri.parse(url));
    final request = await response.close();
    final file = File(filePath);
    await file.create(recursive: true);

    await request.pipe(file.openWrite());

    sendPort.send(filePath); // Send the downloaded file path to the main isolate
  } catch (e) {
    sendPort.send('Error: $e'); // Send any errors back to the main isolate
  }
}
