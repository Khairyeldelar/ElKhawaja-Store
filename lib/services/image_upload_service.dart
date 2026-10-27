import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  final ImagePicker picker = ImagePicker();
  Future<String?> pickAndUpload() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('يجب تسجيل الدخول');
    final selected = await picker.pickImage(source: ImageSource.gallery,
      imageQuality: 80, maxWidth: 1600);
    if (selected == null) return null;
    final ref = FirebaseStorage.instance.ref().child(
      'products/${user.uid}/${DateTime.now().microsecondsSinceEpoch}.jpg');
    await ref.putFile(File(selected.path), SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }
}
