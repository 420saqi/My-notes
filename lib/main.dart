import 'package:flutter/material.dart';
import 'package:nots/services/auth/auth_service.dart';
import 'package:nots/views/login.dart';
import 'package:nots/views/notes/new_notes_view.dart';
import 'package:nots/views/notesView.dart';
import 'package:nots/views/register.dart';
import 'package:nots/views/verifyEmail.dart';
import 'package:nots/constants/routes.dart';


void main() async{
  // const firebaseOption =FirebaseOptions(
  //         apiKey: 'AIzaSyDT8DyNShKWDdYq37A6DvJ2oW9tPoeRO38',
  //         appId: '1:58316628830:android:f80ef5f9ecc1ccf26c65cf',
  //         messagingSenderId: '58316628830',
  //         projectId: 'nots-60f4c');

  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(options: firebaseOption);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  const HomePage(),
      routes: {
        registerRoute : (context) =>   const Register(),
        loginRoute : (context) =>      const Login(),
        notesRoute : (context)  =>     const NotesView(),
        verifyEmailRoute : (context) => const VerifyEmail(),
        NewNoteRoute : (context) => const NewNotesView(),
      },
    );
  }
}
class HomePage extends StatelessWidget {
   const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder(
        // future: Firebase.initializeApp(
        //     options: const FirebaseOptions(
        //         apiKey: 'AIzaSyDT8DyNShKWDdYq37A6DvJ2oW9tPoeRO38',
        //         appId: '1:58316628830:android:f80ef5f9ecc1ccf26c65cf',
        //         messagingSenderId: '58316628830',
        //         projectId: 'nots-60f4c'
        //     )
        // ),
        future: AuthService.firebase().initializeFirebase() ,
        builder: (context,AsyncSnapshot<void> snapshot)
        {

          switch(snapshot.connectionState){
            case ConnectionState.done:
              // final user= FirebaseAuth.instance.currentUser;
            final user = AuthService.firebase().currentUser ;
              if(user!=null)
              {
                if(user.isEmailVerified)
                {
                  return const NotesView();
                }
                else
                {
                  return const VerifyEmail();
                }
              }
              else
              {
                return const Login();
              }
            default :
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

