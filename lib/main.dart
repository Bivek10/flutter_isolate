import 'package:dartz/dartz.dart' show Either;
import 'package:flutter/material.dart';
import 'package:flutter_isolate/core/services/app_services/video_services.dart';
import 'package:flutter_isolate/core/utils/movie_downloader.dart';
import 'package:flutter_isolate/model/video_model.dart';
import 'package:permission_handler/permission_handler.dart';

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
                                  top: 10,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () async {
                                      Permission permission =
                                          Permission.manageExternalStorage;
                                      PermissionStatus permissionStatus =
                                          await permission.request();
                                      if (permissionStatus.isGranted) {
                                        MovieDownloaderIsolate
                                            movieDownloaderIsolate =
                                            MovieDownloaderIsolate();
                                        movieDownloaderIsolate.downloadFile(
                                            fileUrl:
                                                videos[index].sources!.first);
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.download,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
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
