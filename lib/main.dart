import 'package:english_words/english_words.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Repositories/auth_repository.dart';
import 'Repositories/firebase_repository.dart';
import 'RandomWords.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Screens/user_profile.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider<AuthRepository>(
        create: (_) => AuthRepository.instance()),
    ChangeNotifierProvider<FirebaseRepository>(
        create: (_) => FirebaseRepository.instance)
  ], child: App()));
}

class App extends StatelessWidget {
  Future _initialization() async {
    await Firebase.initializeApp();
    await FirebaseRepository.instance.uploadSavedFromCloud();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
              body: Center(
                  child: Text(snapshot.error.toString(),
                      textDirection: TextDirection.ltr)));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return const MyApp();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Welcome to Flutter',
        home: const Scaffold(
          body: Center(
            child: UserProfile(),
          ),
        ),
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.deepPurple,
          ),
        ));
  }
}
