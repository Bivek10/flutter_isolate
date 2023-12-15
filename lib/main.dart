import 'dart:io';
import 'dart:isolate';

import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_isolate/core/services/app_services/video_services.dart';
import 'package:flutter_isolate/core/utils/movie_downloader.dart';
import 'package:flutter_isolate/model/video_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  VideoServices videoServices = VideoServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Downloder App"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FutureBuilder<Either<MoviesModel, Exception>>(
          future: videoServices.getMovies(),
          builder: (context, state) {
            if (state.hasError) {
              return const Text("Error");
            } else if (state.hasData) {
              return state.data!.fold(
                (movieData) {
                  List<Videos> videos = movieData.categories![0].videos!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 2.1 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: videos.length,
                    itemBuilder: (BuildContext ctx, index) {
                      MovieDownloaderIsolate movieDownloaderIsolate =
                          MovieDownloaderIsolate();
                      return Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Image.network(
                                  videos[index].thumb!,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: StreamBuilder<double>(
                                      stream: movieDownloaderIsolate
                                          .downloadPercentageController.stream,
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Stack(
                                              children: [
                                                CircleAvatar(
                                                  radius: 15,
                                                  backgroundColor: Colors.white,
                                                  child:
                                                      CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.white,
                                                    strokeWidth: 5,
                                                    value: snapshot.data,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 5,
                                                  left: 5,
                                                  child: snapshot.data == 1
                                                      ? const Icon(
                                                          Icons.check,
                                                          size: 20,
                                                        )
                                                      : const Icon(
                                                          Icons.pause,
                                                          size: 20,
                                                        ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }

                                        return IconButton(
                                          onPressed: () async {
                                            // Permission permission =
                                            //     Permission.manageExternalStorage;
                                            // PermissionStatus permissionStatus =
                                            //     await permission.request();
                                            // print(
                                            //     "permission ${permissionStatus.isGranted}");

                                            movieDownloaderIsolate.downloadFile(
                                              fileUrl:
                                                  videos[index].sources!.first,
                                            );
                                          },
                                          icon: StreamBuilder<double>(
                                              stream: movieDownloaderIsolate
                                                  .downloadPercentageController
                                                  .stream,
                                              builder: (context, snapshot) {
                                                return const CircleAvatar(
                                                  backgroundColor: Colors.white,
                                                  radius: 20,
                                                  child: Icon(
                                                    Icons.download,
                                                    size: 20,
                                                    color: Colors.blue,
                                                  ),
                                                );
                                              }),
                                        );
                                      }),
                                ),
                              ],
                            ),
                            Text(
                              videos[index].title!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
                (exception) {
                  return Text("Error====>, $exception");
                },
              );
            }
            return const Text("Loading");
          },
        ),
      ),
    );
  }
}

// Future<void> downloadFile(
//     {required String fileUrl,
//     required MovieDownloaderIsolate movieDownloaderIsolate}) async {
//   //get app directory to saved video.

//   final Directory? directory = await getExternalStorageDirectory();
//   var videoSaveDir = await Directory(directory!.path).create();
//   ReceivePort rp = ReceivePort();
//   final downloaderIsolate = await Isolate.spawn(
//       movieDownloaderIsolate.transferFileDownloadRate, rp.sendPort);

//   final boardCastRp = rp.asBroadcastStream();
//   // received the send port.
//   final SendPort transferFileSendPort = await boardCastRp.first;
//   //send the download url to transferFileDownload
//   transferFileSendPort.send(fileUrl);
//   int currentPosition = 0;
//   num cumulative = 0;

//   RandomAccessFile file =
//       await File(path.join(videoSaveDir.path, path.basename(fileUrl)))
//           .open(mode: FileMode.write);

//   boardCastRp.listen((event) async {
//     if (event is Map) {
//       if (event.keys.contains("byte_in_chunck") && event.keys.isNotEmpty) {
//         try {
//           List<int> chunckBytes = event["byte_in_chunck"];
//           int startByte = currentPosition;
//           int endByte = currentPosition + chunckBytes.length;
//           currentPosition = endByte;
//           cumulative += event["cumulative"];

//           movieDownloaderIsolate.downloadPercentageController.sink
//               .add((cumulative / event["total"]) * 100);

//           file.setPositionSync(startByte);
//           file.writeFromSync(event["byte_in_chunck"]);
//         } catch (e) {
//           print("error $e");
//         }
//       } else {
//         if (event["download_status"] == "completed") {
//           await file.close();
//           movieDownloaderIsolate.downloadPercentageController.close();
//           rp.close();
//           // killing the isolate once file is downloaded.
//           downloaderIsolate.kill();
//         }
//       }
//     }
//   });
// }
