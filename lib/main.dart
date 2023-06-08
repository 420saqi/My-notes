
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nots/views/login.dart';
import 'package:nots/views/register.dart';
import 'package:nots/views/verifyEmail.dart';
import 'dart:developer' as my_log show log;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      home: const HomePage(),
      routes: {
        '/register/' : (context)=>const Register(),
        '/login/' : (context)=>const Login(),
        '/notesView/' : (context) => const NotesView(),
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
        future: Firebase.initializeApp(
            options: const FirebaseOptions(
                apiKey: 'AIzaSyDT8DyNShKWDdYq37A6DvJ2oW9tPoeRO38',
                appId: '1:58316628830:android:f80ef5f9ecc1ccf26c65cf',
                messagingSenderId: '58316628830',
                projectId: 'nots-60f4c'
            )
        ),

        builder: (context,AsyncSnapshot<FirebaseApp> snapshot)
        {

          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user= FirebaseAuth.instance.currentUser;
              if(user!=null)
              {
                if(user.emailVerified)
                {
                  my_log.log('user verified');
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
              return const Text('Loading',style: TextStyle(fontSize: 30),);
          }
        },
      ),
    );
  }
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction { logout }

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes View'),
        backgroundColor: Colors.blue,
        actions: [
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              final isLogout = await logoutAction(context);
              switch(value)
                  {
                case MenuAction.logout:
                  if(isLogout)
                    {
                      await FirebaseAuth.instance.signOut();
                      // Navigator.of(context).pushNamedAndRemoveUntil(
                      //     '/login/',
                      //         (route) => false
       // ); this code is casing a warning that Don't use BuildContext across async gaps
                      final currentContext = context;
                      Future.delayed(Duration.zero, () {
                        Navigator.of(currentContext).pushNamedAndRemoveUntil(
                          '/login/',
                              (route) => false,
                        );
                      });
                    }
              }
            },
              itemBuilder: (context) {
              return [
              const PopupMenuItem<MenuAction>(
                value : MenuAction.logout ,
                  child: Text('Log Out')
              )
                ];
              },
          )
        ],
      ),
      body:const Text('This is my Notes View'),
    );
  }
}

Future<bool> logoutAction(BuildContext context){
  return showDialog<bool>(context: context,
    builder: (BuildContext context) {
    return  AlertDialog(
      title: const Text('Logging Out'),
      content: const Text('Are you sure you want to LogOut'),
      actions: [
        TextButton(onPressed: () {
          my_log.log('Logging Out');
          Navigator.of(context).pop(true);
        }, child:const Text('Logout')),
        TextButton(onPressed: (){
          my_log.log('Logging Out Canceled');
          Navigator.of(context).pop(false);
        }, child:const Text('Cancel'))
      ],
    );
  },).then<bool>((value) => value?? false);
}
