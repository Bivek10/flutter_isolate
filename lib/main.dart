import 'package:flutter/material.dart';
import 'package:flutter_isolate/model/album_reponse_model.dart';

import 'core/services/app_repository/album_repo.dart';
import 'core/services/app_services/ablum_service.dart';

void main() {
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
  AlbumRepo? albumRepo;
  @override
  void initState() {
    albumRepo = LocalAlbum();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Isolate Testing"),
      ),
      body: FutureBuilder<List<AlbumResponse>>(
          future: albumRepo!.getAlbum(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    AlbumResponse item = snapshot.data![index];
                    return Column(
                      key: Key(item.id.toString()),
                      children: [
                        Image.network(item.thumbnailUrl!),
                        Text(item.title!),
                      ],
                    );
                  });
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }
}
