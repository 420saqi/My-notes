import 'package:flutter/material.dart';
import 'package:nots/constants/routes.dart';
import 'package:nots/services/auth/auth_service.dart';
import 'package:nots/utilities/show_error_dialog.dart';

import '../services/auth/auth_exceptions.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text('Register'),
      ),
      body: FutureBuilder(
        future: AuthService.firebase().initializeFirebase(),
        builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Column(
                children: [
                  TextField(
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    decoration: const InputDecoration(
                      label: Text('Enter Email'),
                    ),
                  ),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      label: Text('Enter Password'),
                    ),
                  ),
                  TextButton(
                      onPressed: () async {
                        final email = _emailController.text;
                        final password = _passwordController.text;

                        try {
                          await AuthService.firebase()
                              .createUser(email: email, password: password);
                          await AuthService.firebase().sendEmailVerification();
                        Future.delayed(Duration.zero, (){
                           Navigator.of(context)
                              .pushNamed(verifyEmailRoute);
                        });

                        } on EmailALreadyInUseAuthException {
                          showErrorDialog(context, 'Email Already in Use');
                        } on InvalidEmailAuthException {
                          showErrorDialog(context, 'Invalid Email');
                        } on WeakPasswordAuthException {
                          showErrorDialog(context, 'Weak Password');
                        } on GenericException {
                          showErrorDialog(context, 'Authentication Error');
                        }
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontSize: 20),
                      )),
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute,
                          (route) => false,
                        );
                      },
                      child: const Text(
                        'Already a user!. Login Here',
                        style: TextStyle(fontSize: 20),
                      ))
                ],
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ), //
    );
  }
}
