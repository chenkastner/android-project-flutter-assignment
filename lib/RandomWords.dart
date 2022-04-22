import 'package:english_words/english_words.dart';
import 'Repositories/auth_repository.dart';
import 'Repositories/firebase_repository.dart';
import './Screens/login.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RandomWords extends StatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  State<RandomWords> createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  Widget _buildRow(WordPair pair) {
    return Consumer<FirebaseRepository>(builder: (context, savedInst, _) {
      final alreadySaved = savedInst.saved.contains(pair);
      return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.star : Icons.star_border,
          color: alreadySaved ? Theme.of(context).colorScheme.primary : null,
          semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          if (alreadySaved) {
            savedInst.remove(pair);
          } else {
            savedInst.add(pair);
          }
        },
      );
    });
  }

  Widget _buildSuggestions() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, i) {
        if (i.isOdd) {
          return const Divider();
        }
        final index = i ~/ 2;
        if (index >= _suggestions.length) {
          _suggestions.addAll(generateWordPairs().take(10));
        }
        return _buildRow(_suggestions[index]);
      },
    );
  }

  Widget dismissibleBG(String direction) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Align(
        child: Row(
          mainAxisAlignment: direction == "right"
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: <Widget>[
            const SizedBox(
              width: 20,
            ),
            const Icon(
              Icons.delete,
              color: Colors.white,
            ),
            Text(
              "Delete Suggestion",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign:
                  direction == "right" ? TextAlign.left : TextAlign.right,
            ),
          ],
        ),
        alignment:
            direction == "right" ? Alignment.centerLeft : Alignment.centerRight,
      ),
    );
  }

  Widget myAlertDialog(String option) {
    return AlertDialog(
      title: const Text('Delete Suggestion'),
      content: Text('Are you sure you want to delete ' +
          option +
          ' from your saved suggestions?'),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'Cancel'),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }


  void _pushSaved() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Consumer<FirebaseRepository>(builder: (context, savedInst, _) {
            final tiles = savedInst.saved.map(
              (pair) {
                return Dismissible(
                  child: ListTile(
                    title: Text(
                      pair.asPascalCase,
                      style: _biggerFont,
                    ),
                  ),
                  background: dismissibleBG("right"),
                  secondaryBackground: dismissibleBG("left"),
                  key: ValueKey<String>(pair.asPascalCase),
                  confirmDismiss: (DismissDirection direction) async {
                    String? res = await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return myAlertDialog(pair.asPascalCase);
                        });
                    if (res == "OK") return true;
                    return false;
                  },
                  onDismissed: (DismissDirection direction) =>
                      savedInst.remove(pair),
                );
              },
            );
            final divided = tiles.isNotEmpty
                ? ListTile.divideTiles(
                    context: context,
                    tiles: tiles,
                  ).toList()
                : <Widget>[];

            return Scaffold(
              appBar: AppBar(
                title: const Text('Saved Suggestions'),
              ),
              body: ListView(children: divided),
            );
          });
        },
      ),
    );
  }

  void _loginScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          return Scaffold(
              appBar: AppBar(
                title: const Text('Login'),
                // backgroundColor: const Color(0xFFFFC857),
                // foregroundColor: Colors.black,
              ),
              body: const Login());
        },
      ),
    );
  }

  void loginOrLogOut(AuthRepository auth) {
    if (auth.status == Status.Authenticated) {
      auth.signOut();
      const snackBar = SnackBar(
        content: Text('Successfully logged out'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } else {
      _loginScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthRepository>(
        builder: (ctx, auth, child) => Scaffold(
              appBar: AppBar(
                title: const Text('Startup Name Generator'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: _pushSaved,
                    tooltip: 'Saved Suggestions',
                  ),
                  IconButton(
                    icon: (auth.status == Status.Authenticated)
                        ? const Icon(Icons.exit_to_app_outlined)
                        : const Icon(Icons.login_rounded),
                    onPressed: () => loginOrLogOut(auth),
                  ),
                ],
              ),
              body: _buildSuggestions(),
            ));
  }
}
