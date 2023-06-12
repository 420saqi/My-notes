import 'package:flutter/material.dart';
import 'package:nots/constants/routes.dart';
import 'package:nots/services/auth/auth_service.dart';
import '../services/auth/auth_exceptions.dart';
import '../utilities/show_error_dialog.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
        title: const Text('Login'),
      ),
      body: Column(
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
                  final user = await AuthService.firebase().login(
                    email: email,
                    password: password,
                  );
                  if (user.isEmailVerified) {
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          notesRoute, (route) => false);
                    });
                  } else {
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          verifyEmailRoute, (route) => false);
                    });
                  }
                } on InvalidEmailAuthException {
                  showErrorDialog(context, 'Invalid Email');
                } on WrongPasswordAuthException {
                  showErrorDialog(context, 'Wrong Password');
                } on UserNotFoundAuthException {
                  showErrorDialog(context, 'User Not Found');
                } on GenericException {
                  showErrorDialog(context, 'Authentication Error ');
                }
              },
              child: const Text(
                'Login',
                style: TextStyle(fontSize: 20),
              )),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text(
                'Not Registered Yet!. Register Here',
                style: TextStyle(fontSize: 20),
              ))
        ],
      ), //
    );
  }
}
