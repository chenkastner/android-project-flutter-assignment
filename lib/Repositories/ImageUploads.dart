import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hello_me/Repositories/auth_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'firebase_repository.dart';

class ImageUploads extends StatefulWidget {
  const ImageUploads({Key? key}) : super(key: key);

  @override
  _ImageUploadsState createState() => _ImageUploadsState();
}

class _ImageUploadsState extends State<ImageUploads> {
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  File? _photo;
  Image? _profilePhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    try {
      final user = AuthRepository.instance().user?.email;
      if (user != null) {
        _getImageUrl(user).then((value) {
          if (value != null) {
            setState(() {
              _profilePhoto = Image.network(
                value,
                width: 110,
                height: 110,
                fit: BoxFit.fill,
              );
            });
          }
        });
      }
    } catch (e) {
      return;
    }
  }

  Future<String?> _getImageUrl(String user) async {
    Reference reference = storage.ref('/$user/profile_picture').child('file/');
    try{
      String downloadUrl = await reference.getDownloadURL();
      return downloadUrl;
    }
    catch(_){
      return Future.delayed(Duration.zero);
    }


  }

  Future imgFromGallery(context) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _photo = File(pickedFile.path);
        uploadFile();
      } else {
        const snackBar = SnackBar(
          content: Text("No image selected."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
  }

  Future uploadFile() async {
    if (_photo == null) return;
    final user = AuthRepository.instance().user?.email;
    final destination = '/$user/profile_picture';

    try {
      final ref = firebase_storage.FirebaseStorage.instance
          .ref(destination)
          .child('file/');
      await ref.putFile(_photo!);
    } catch (e) {
      print('error occurred');
    }
  }

  Widget _displayEmail() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          '${FirebaseRepository.instance.auth.currentUser?.email}',
          style: const TextStyle(fontSize: 18),
        ));
  }

  Widget _changeAvatarButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          imgFromGallery(context);
        },
        child: const Text('Change Avatar'),
      ),
    );
  }

  Widget _displayImage() {
    if (_photo != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: Image.file(
          _photo!,
          width: 110,
          height: 110,
          fit: BoxFit.fill,
        ),
      );
    }
    if (_profilePhoto != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: _profilePhoto,
      );
    }
    return Container(
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(50)),
      width: 110,
      height: 110,
      child: Icon(
        Icons.person,
        color: Colors.grey[800],
      ),
    );
  }

  Widget _avatar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: CircleAvatar(
        radius: 55,
        backgroundColor: Colors.blueGrey,
        child: _displayImage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _avatar(),
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            _displayEmail(),
            _changeAvatarButton(context),
          ],
        ),
      ],
    ));
  }
}
