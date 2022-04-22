import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseRepository with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  final Set<WordPair> _saved = <WordPair>{};

  FirebaseRepository._privateConstructor();

  static final FirebaseRepository instance =
      FirebaseRepository._privateConstructor();

  Set<WordPair> get saved => _saved;

  Future createUserDoc() async {
    String? userId = auth.currentUser?.uid;
    await _firestore
        .collection('users')
        .doc(userId)
        .get()
        .then((snapshot) async {
      if (snapshot.exists == false) {
        await _firestore.collection('users').doc(userId).set({'saved': []});
      }
    });
  }

  Future add(WordPair pair) async {
    if (auth.currentUser != null) {
      String? userId = auth.currentUser?.uid;
      _firestore.collection('users').doc(userId).update({
        'saved': FieldValue.arrayUnion([
          {'first': pair.first, 'second': pair.second}
        ])
      });
    }
    _saved.add(pair);
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future remove(WordPair pair) async {
    if (auth.currentUser != null) {
      String? userId = auth.currentUser?.uid;
      _firestore.collection('users').doc(userId).update({
        'saved': FieldValue.arrayRemove([
          {'first': pair.first, 'second': pair.second}
        ])
      });
    }
    _saved.remove(pair);
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future addLocalsToCloud() async {
    String? userId = auth.currentUser?.uid;
    var arr = _saved
        .toList()
        .map((wp) => {'first': wp.first, 'second': wp.second})
        .toList();
    _firestore
        .collection('users')
        .doc(userId)
        .update({'saved': FieldValue.arrayUnion(arr)});
    notifyListeners();
  }

  Future uploadSavedFromCloud() async {
    if (auth.currentUser != null) {
      String? userId = auth.currentUser?.uid;
      _saved.clear();
      var data = await _firestore
          .collection('users')
          .doc(userId)
          .get()
          .then((data) => data);
      for (var s in data['saved']) {
        _saved.add(WordPair(s['first'], s['second']));
      }
      notifyListeners();
    }
  }

  Future clearSaved() async {
    _saved.clear();
    notifyListeners();
  }
}
