import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


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
      body:FutureBuilder(
        future: Firebase.initializeApp(options: const FirebaseOptions(
            apiKey: 'AIzaSyDT8DyNShKWDdYq37A6DvJ2oW9tPoeRO38',
            appId: '1:58316628830:android:f80ef5f9ecc1ccf26c65cf',
            messagingSenderId: '58316628830',
            projectId: 'nots-60f4c'
        ),),
        builder: (BuildContext context, AsyncSnapshot<FirebaseApp> snapshot)
        {
          switch(snapshot.connectionState){
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
                        try{
                          UserCredential userCredential =  await FirebaseAuth.instance
                              .signInWithEmailAndPassword(
                                  email: email, password: password);
                          print(userCredential.user);
                        }on FirebaseAuthException catch (e)
                        {
                          if(e.code=='invalid-email')
                            {
                              print('Invalid email');
                            }
                          else if(e.code=='wrong-password')
                            {
                              print('wrong password');
                            }
                          else if(e.code=='user-not-found')
                            {
                              print('user not found');
                            }
                          else
                            {
                              print(e.code);
                            }
                        }
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 20),
                      )),
                  TextButton(onPressed: (){
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/register/',
                            (route) => false
                    );
                  },
                      child: const Text('Not Registered Yet!. Register Here',
                        style: TextStyle(fontSize: 20),))
                ],
              );
            default :
              return const Text('Loading');
          }

        },
      ) ,//
    );
  }
}
