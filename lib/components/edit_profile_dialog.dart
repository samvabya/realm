import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:realm/model/user.dart';
import 'package:realm/services/supabase_service.dart';
import 'package:realm/util.dart';

class EditProfileDialog extends StatefulWidget {
  final UserModel user;
  const EditProfileDialog({super.key, required this.user});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  File? file;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    nameController.text = widget.user.name ?? '';
    super.initState();
  }

  Future<void> pickMedia() async {
    XFile? selectedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 10,
      maxWidth: 1000,
    );

    if (selectedFile == null) return;

    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: selectedFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
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

    if (mounted) {
      setState(() {
        file = File(croppedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  try {
                    await SupabaseService.updateProfile(
                      widget.user.id!,
                      nameController.text,
                      file,
                    );
                  } on Exception catch (e) {
                    showSnack(e.toString(), context);
                  } finally {
                    showSnack('Profile updated', context);
                    Navigator.pop(context);
                  }
                },
                label: const Text('Save'),
                icon: const Icon(Icons.done),
              ),
              SizedBox(width: 30),
            ],
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: pickMedia,
            child: CircleAvatar(
              radius: 70,
              backgroundImage: file != null
                  ? FileImage(file!)
                  : widget.user.image != null
                  ? NetworkImage(formattedUrl(widget.user.image!))
                  : null,
              child: file == null && widget.user.image == null
                  ? const Icon(Icons.person, size: 30)
                  : null,
            ),
          ),

          SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Material(
              color: Colors.transparent,
              child: TextField(
                textAlign: TextAlign.center,
                controller: nameController,
                decoration: InputDecoration(
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
