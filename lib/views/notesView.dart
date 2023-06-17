import 'package:flutter/material.dart';
import 'package:nots/services/auth/auth_service.dart';
import 'package:nots/services/auth/crud/notes_service.dart';
import 'dart:developer' as my_log show log;
import '../constants/routes.dart';
class NotesView extends StatefulWidget {
  const NotesView({super.key});
  @override
  State<NotesView> createState() => _NotesViewState();
}

enum MenuAction { logout }

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
final userEmail = AuthService.firebase().currentUser!.email!;
  @override
  void initState() {
    _notesService =NotesService();
    super.initState();
  }
  @override
  void dispose() {
  _notesService.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            onPressed :(){
              Navigator.of(context).pushNamed(NewNoteRoute);
            },
            icon:const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async{
              final isLogout = await logoutAction(context);
              switch(value)
              {
                case MenuAction.logout:
                  if(isLogout)
                  {
                    await AuthService.firebase().logout();
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
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
      body:FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch(snapshot.connectionState)
              {
            case ConnectionState.done :
              return StreamBuilder(
                stream: _notesService.ntoesStream,
                builder: (context, snapshot) {
                      switch(snapshot.connectionState)
                          {
                        case ConnectionState.waiting:
                        case ConnectionState.active :
                        return const Text('Loading All Notes');
                        default:
                        return const Text('waiting!');
                      }
              },
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
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