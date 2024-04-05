import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CMARIX-Image-Editor-Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Uint8List> loadImageBytes() async {
    final ByteData data = await rootBundle.load('assets/demo_cmarix.jpg');
    return data.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CMARIX-Image-Editor-Demo'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 0, left: 0, right: 0, top: 60),
            ),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProImageEditor.asset(
                      'assets/demo_cmarix.jpg',
                      onImageEditingComplete: (bytes) async {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.folder_rounded),
              label: const Text('Edit from Asset file'),
            ),
            const SizedBox(height: 30),
            if (!kIsWeb) ...[
              OutlinedButton.icon(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(
                    type: FileType.image,
                  );

                  if (result != null && context.mounted) {
                    File file = File(result.files.single.path!);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ProImageEditor.file(
                          file,
                          onImageEditingComplete: (Uint8List bytes) async {
                            // print("path: ${getImageFile(bytes)}");
                            getImageFile(bytes);
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.sd_card_sharp),
                label: const Text('Edit from a File'),
              ),
              const SizedBox(height: 30),
            ],
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProImageEditor.network(
                      'https://picsum.photos/id/10/2500/1667',
                      onImageEditingComplete: (bytes) async {
                        getImageFile(bytes);
                        Navigator.pop(context);
                      },
                      configs: ProImageEditorConfigs(
                        stickerEditorConfigs: StickerEditorConfigs(
                          enabled: true,
                          buildStickers: (setLayer) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(20)),
                              child: Container(
                                color: const Color.fromARGB(255, 224, 239, 251),
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(16),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                  ),
                                  itemCount: 21,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    Widget widget = ClipRRect(
                                      borderRadius: BorderRadius.circular(7),
                                      child: Image.network(
                                        'https://picsum.photos/id/${(index + 3) * 3}/2000',
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          return AnimatedSwitcher(
                                            layoutBuilder: (currentChild,
                                                previousChildren) {
                                              return SizedBox(
                                                width: 120,
                                                height: 120,
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  alignment: Alignment.center,
                                                  children: <Widget>[
                                                    ...previousChildren,
                                                    if (currentChild != null)
                                                      currentChild,
                                                  ],
                                                ),
                                              );
                                            },
                                            duration: const Duration(
                                                milliseconds: 200),
                                            child: loadingProgress == null
                                                ? child
                                                : Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                    ),
                                                  ),
                                          );
                                        },
                                      ),
                                    );
                                    return GestureDetector(
                                      onTap: () => setLayer(widget),
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: widget,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.layers_sharp),
              label: const Text('Edit a file with Stickers'),
            ),
          ],
        ),
      ),
    );
  }

  Future<File> getImageFile(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${directory.path}/image_$timestamp.jpg';

    try {
      // Write bytes to file
      await File(filePath).writeAsBytes(bytes);
      print("filePath: ${filePath}");
      return File(filePath);
    } catch (e) {
      throw 'Error writing file: $e';
    }
  }
}
