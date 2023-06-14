import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'crud_exception.dart';

class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNote({required String text ,required DatabaseNotes note,}) async {
    final db=_getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount =await db.update(noteTable, {
      textColum:text,
      userIdColum :note.id,
    });
    if(updateCount==0)
      {
        throw CouldNotUpdateNoteException();
      }
    else
      {
        return await getNote(id: note.id);
      }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes()async{
    final db=_getDatabaseOrThrow();
  final allnotes = await db.query(noteTable);
 return allnotes.map((note) => DatabaseNotes.fromRow(note));
  }

  Future<DatabaseNotes> getNote({required int id})async{
    final db=_getDatabaseOrThrow();
    final note= await db.query(noteTable, limit: 1, whereArgs: [id],where: 'id=?');
    if(note.isEmpty)
      {
        throw CouldNotGetNoteException();
      }
    else
      {
        return DatabaseNotes.fromRow(note.first);
      }
  }

  Future<int> deleteAllNotes()async {
    final db= _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id})async {
    final db=_getDatabaseOrThrow();
    final result = await db.delete(noteTable, where: 'id= ?', whereArgs: [id],);
    if(result ==0 )
      {
        throw CouldNotDeleteNoteException();
      }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner})async {
    final db =_getDatabaseOrThrow();
     final dbUser = await getUser(email: owner.email);
     if(dbUser != owner)
       {
         throw CouldNotFindUserException();
       }
   final noteId =  await db.insert(noteTable, {
       userIdColum : owner.id,
       textColum :'',
     });
     return DatabaseNotes(id: noteId, text: textColum, userId: owner.id,);
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ? ',
      whereArgs: [email.toLowerCase()],
    );

    if(result.isNotEmpty)
      {
        throw CouldNotGetUserException();
      }
    else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: 'email= ?',
      whereArgs: [email.toLowerCase()],
    );
    if (result.isNotEmpty) {
      throw EmailAlreadyExistException();
    }

    final userId = await db.insert(
      userTable,
      {
        emailColum: email.toLowerCase(),
      },
    );
    return DatabaseUser(id: userId, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDatabaseOrThrow();
    final deleteCount = await db.delete(
      userTable,
      where: 'email = ? ',
      whereArgs: [email.toLowerCase()],
    );
    if (deleteCount != 1) {
      throw CouldNotDeleteUserException();
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpenException();
    } else {
      await db.close();
      _db = null; // resetting our database to null
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      // getting document path
      final docxpath = await getApplicationDocumentsDirectory();
      // joining the path of document with dbName
      final dbpath = join(docxpath.path, dbName);
      // opening the database
      final db = await openDatabase(dbpath);
      _db = db;

      //creating databaseNotes
      await db.execute(createDatabaseNotes);
      // creating databaseUser
      await db.execute(createDatabaseUser);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentDirectoryException();
    }
  }
}

class DatabaseUser {
  final int id;
  final String email;

  DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColum] as int,
        email = map[emailColum] as String;

  @override
  String toString() => 'id = $id , email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;
  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final String text;
  final int userId;

  DatabaseNotes({
    required this.id,
    required this.text,
    required this.userId,
  });

  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColum] as int,
        text = map[textColum] as String,
        userId = map[userIdColum] as int;

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  String toString() => 'id= $id, text = $text , userId= $userId';

  @override
  int get hashCode => id.hashCode;
}

const userTable = 'user';
const noteTable = 'notes';
const textColum = 'text';
const userIdColum = 'user_id';
const dbName = 'notes.db';
const idColum = 'id';
const emailColum = 'email';
const createDatabaseUser = '''
      CREATE TABLE IF NOT EXIST "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';

const createDatabaseNotes = '''
      CREATE TABLE IF NOT EXIST "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';
