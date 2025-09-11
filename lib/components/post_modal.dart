import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realm/main.dart';
import 'package:realm/services/supabase_service.dart';

class PostModal extends StatefulWidget {
  const PostModal({super.key});

  @override
  State<PostModal> createState() => _PostModalState();
}

class _PostModalState extends State<PostModal> {
  bool isLoading = false;
  TextEditingController textController = TextEditingController();
  File? file;

  Future<void> pickMedia() async {
    XFile? selectedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (selectedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              spacing: 16,
              children: [
                TextField(
                  controller: textController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    hintText: 'What\'s on your mind?',
                  ),
                ),
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: InkWell(
                    onTap: pickMedia,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      clipBehavior: Clip.antiAlias,
                      color: Theme.of(context).colorScheme.surfaceBright,
                      child: file != null
                          ? Image.file(file!, fit: BoxFit.cover)
                          : Center(
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  Icon(Icons.image),
                                  Text(
                                    'Upload a photo',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.tonal(
                onPressed: isLoading
                    ? null
                    : () async {
                        setState(() => isLoading = true);

                        await SupabaseService.createPost(
                          supabase.auth.currentUser!.id,
                          textController.text,
                          file,
                        );

                        setState(() => isLoading = false);
                        Navigator.pop(context);
                      },
                child: const Text('Share'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
