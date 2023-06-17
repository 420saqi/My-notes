import 'package:flutter/material.dart' ;
import 'package:nots/services/auth/auth_service.dart';
import 'package:nots/services/auth/crud/notes_service.dart';

class NewNotesView extends StatefulWidget {
  const NewNotesView({super.key});

  @override
  State<NewNotesView> createState() => _NewNotesViewState();
}

class _NewNotesViewState extends State<NewNotesView> {

  DatabaseNotes? _note;
  late final TextEditingController _textEditingController;
  late final NotesService _notesService;
// creating new note when tap on + button
  Future<DatabaseNotes> createNewNote()async{
    final existingNote =_note;
    if(existingNote!=null){
      return existingNote;
    }
    final userEmail =AuthService.firebase().currentUser!;
    // ! expects a current User and if its not available app gonna crash
    final getOwner = await _notesService.getUser(email: userEmail.toString());
    return await _notesService.createNote(owner: getOwner);
  }

  void _deleteNoteIfTextIsEmpty()async {
    final note = _note;
    if (note != null && _textEditingController.text.isEmpty) {
      await _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty()async{
      final note=_note;
      if(note!=null && _textEditingController.text.isNotEmpty)
        {
          await _notesService.updateNote(text: _textEditingController.text, note: note);
        }
    }

  void updateNoteAsUserIsTyping()async{
    final note=_note;
    if(note!= null)
      {
        await _notesService.updateNote(text: _textEditingController.text, note: note);
      }
    else
      {
        return ;
      }
  }

  void setupControllerListner(){
    _textEditingController.removeListener(updateNoteAsUserIsTyping);
    _textEditingController.addListener(updateNoteAsUserIsTyping);
  }
    @override
  void initState() {
      _notesService =NotesService();
      _textEditingController =TextEditingController();
    super.initState();
  }
  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBar(
        title: const Text('New Note'),
        backgroundColor:Colors.blue,
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          _note = snapshot.data;
          setupControllerListner();
          switch(snapshot.connectionState)
              {
            case ConnectionState.done:
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration:const InputDecoration(
                  hintText: 'Write Your NoteS Here',
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
