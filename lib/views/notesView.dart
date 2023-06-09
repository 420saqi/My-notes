import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as my_log show log;

import '../constants/routes.dart ';
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
                        loginRoute ,
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