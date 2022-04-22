import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Repositories/auth_repository.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _confirmFormKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  // TextEditingController passwordController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    AuthRepository auth = Provider.of<AuthRepository>(context);
    Future<void> doLogin() async {
      bool response =
          await auth.signIn(emailController.text, passwordController.text);
      if (response) {
        Navigator.pop(context);
      } else {
        const snackBar = SnackBar(
          content: Text("There was an error logging into the app."),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }

    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(),
                child: TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  textAlign: TextAlign.start,
                ),
              ),
            ),
            Padding(
                padding:
                    const EdgeInsets.only(top: 16.0, right: 16.0, left: 16.0),
                child: Consumer<AuthRepository>(
                  builder: (context, auth, child) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed:
                        (auth.status == Status.Authenticating) ? null : doLogin,
                    child: const Text('Log In'),
                  ),
                )),
            Padding(
                padding: const EdgeInsets.only(top: 5.0, right: 16.0, left: 16.0),
                child: Consumer<AuthRepository>(
                  builder: (context, auth, child) => ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                        primary: Colors.lightBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20))),
                    onPressed: (auth.status == Status.Authenticating) ? null : () => _showPicker(context),
                    child: const Text('New user? Click to sign up'),
                  ),
                )),
          ],
        ));
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Form(
              key: _confirmFormKey,
              child: Column(
                children: <Widget>[
                  const ListTile(
                      title: Text(
                        'Please confirm your password below:',
                        textAlign: TextAlign.center,
                      )),
                  ListTile(
                      title: TextFormField(
                        // controller: passwordController2,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                        ),
                        obscureText: true,
                        textAlign: TextAlign.start,
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Passwords must match';
                          }
                          return null;
                        },
                      )),
                  ListTile(
                    title: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.lightBlue,
                      ),
                      onPressed: () {
                        if (_confirmFormKey.currentState!.validate()) {
                          AuthRepository.instance().signUp(emailController.text, passwordController.text);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Confirm'),
                    ),
                  ),
                ],
              )
            ),
          );
        });
  }
}
