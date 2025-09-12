import 'dart:io';

import 'package:color_filter_extension/color_filter_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/main.dart';
import 'package:realm/services/supabase_service.dart';
import 'package:realm/util.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

class StoryCreate extends StatefulWidget {
  const StoryCreate({super.key});

  @override
  State<StoryCreate> createState() => _StoryCreateState();
}

class _StoryCreateState extends State<StoryCreate> {
  File? file;
  final TextEditingController _textController = TextEditingController();
  final WidgetsToImageController _widgetsToImageController =
      WidgetsToImageController();
  Color _textColor = Colors.white;
  int _fontIndex = 0;
  final List<String> _fonts = [
    'Poppins',
    'Permanent Marker',
    'Comic Neue',
    'Nothing You Could Do',
    'Oswald',
    'Roboto Mono',
    'Merriweather',
  ];
  int _selectedFilter = 0;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> pickMedia() async {
    XFile? selectedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (selectedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 9, ratioY: 16),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Colors.black,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    setState(() {
      file = File(croppedFile.path);
    });
  }

  void openTextEditor() => showDialog(
    context: context,
    builder: (context) => Material(
      color: Colors.black26,
      child: Center(
        child: Expanded(
          child: TextField(
            maxLines: 2,
            controller: _textController,
            onChanged: (value) {
              setState(() {
                _textController;
              });
            },
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textAlign: TextAlign.center,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Caption',
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              suffix: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.done),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  void openFilter() => showModalBottomSheet(
    context: context,
    barrierColor: Colors.transparent,
    backgroundColor: Colors.black,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    builder: (context) => Container(
      height: 100,
      child: ListView.builder(
        itemCount: presetFiltersList.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => setState(() => _selectedFilter = index),
            child: AspectRatio(
              aspectRatio: 1,
              child: ColorFiltered(
                colorFilter: ColorFilterExt.preset(presetFiltersList[index]),
                child: Image.file(file!, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  @override
  void initState() {
    super.initState();
    pickMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FilledButton.tonal(
                  onPressed: file == null
                      ? null
                      : () async {
                          try {
                            showDialog(
                              context: context,
                              builder: (context) => Center(
                                child: SizedBox(
                                  width: 200,
                                  height: 1,
                                  child: LinearProgressIndicator(),
                                ),
                              ),
                            );
                            final image = await _widgetsToImageController
                                .capture();
                            if (image == null) return;

                            final tempDir = await getTemporaryDirectory();
                            File _file = await File(
                              '${tempDir.path}/image.png',
                            ).create();
                            _file.writeAsBytesSync(image);

                            await SupabaseService.createStory(
                              supabase.auth.currentUser!.id,
                              _file,
                            );

                            Navigator.pop(context);
                            Navigator.pop(context);
                          } on Exception catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                  child: Text('Share'),
                ),
                IconButton(
                  onPressed: file == null ? null : openFilter,
                  icon: Icon(Icons.auto_awesome),
                  color: Colors.white,
                  disabledColor: Colors.grey,
                ),
                IconButton(
                  onPressed: file == null ? null : openTextEditor,
                  icon: Icon(Icons.text_fields),
                  color: Colors.white,
                  disabledColor: Colors.grey,
                ),
              ],
            ),
            WidgetsToImage(
              controller: _widgetsToImageController,
              child: AspectRatio(
                aspectRatio: 9 / 16,
                child: Container(
                  child: file == null
                      ? Center(
                          child: Text(
                            'Select photo',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            ColorFiltered(
                              colorFilter: ColorFilterExt.preset(
                                presetFiltersList[_selectedFilter],
                              ),
                              child: Image.file(file!),
                            ),
                            MatrixGD(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _textColor = _textColor == Colors.white
                                        ? Colors.black
                                        : Colors.white;
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    _fontIndex =
                                        (_fontIndex + 1) % _fonts.length;
                                  });
                                  HapticFeedback.vibrate();
                                },
                                child: Text(
                                  textAlign: TextAlign.center,
                                  _textController.text.trim(),
                                  style: GoogleFonts.getFont(
                                    _fonts[_fontIndex],
                                    color: _textColor,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
