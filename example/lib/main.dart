import 'dart:io';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:saf/saf.dart';

/// Edit the Directory Programmatically Here
const directory = "Android/media/matrix/.neo";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Saf saf;
  var _paths = [];
  @override
  void initState() {
    Permission.storage.request();
    saf = Saf(directory);
    super.initState();
  }

  loadImage(paths, {String k = ""}) {
    var tempPaths = [];
    for (String path in paths) {
      if (path.endsWith(".jpg")) {
        tempPaths.add(path);
      }
    }
    if (k.isNotEmpty) tempPaths.add(k);
    _paths = tempPaths;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Saf example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (_paths.isNotEmpty)
                  ..._paths.map(
                    (path) => Card(
                      child: Image.file(
                        File(path),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.deepPurpleAccent),
              ),
              onPressed: () async {
                Saf.releasePersistedPermissions();
              },
              child: const Text("Release*"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Colors.blueGrey.shade700),
              ),
              onPressed: () async {
                var cachedFilesPath = await saf.cache();
                if (cachedFilesPath != null) {
                  loadImage(cachedFilesPath);
                }
              },
              child: const Text("Cache"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
              ),
              onPressed: () async {
                var isSync = await saf.sync();
                if (isSync as bool) {
                  var _paths = await saf.getCachedFilesPath();
                  loadImage(_paths);
                }
              },
              child: const Text("Sync"),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.orange),
              ),
              onPressed: () async {
                var isClear = await saf.clearCache();
                if (isClear != null && isClear) {
                  loadImage([]);
                }
              },
              child: const Text("Clear"),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: FloatingActionButton(
          elevation: 30.0,
          backgroundColor: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text(
                "GRANT",
                style: TextStyle(fontSize: 13, color: Colors.red),
              ),
              Text(
                "Permission",
                style: TextStyle(fontSize: 7.8, color: Colors.red),
              )
            ],
          ),
          onPressed: () async {
            await saf.getDirectoryPermission(isDynamic: true);
          },
        ),
      ),
    );
  }
}
