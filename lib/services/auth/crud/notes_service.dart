import 'dart:async';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'crud_exception.dart';

class NotesService {
  List<DatabaseNotes> _notes = [];
  final _notesStreamController =
      StreamController<List<DatabaseNotes>>.broadcast();
  Database? _db;
  // static final NotesService _shared = NotesService.sharedInstance();
  // NotesService.sharedInstance();
  // factory NotesService() => _shared;

  Future<void> _cacheNotes() async {
    await ensureDBIsOpen();
    final notes = await getAllNotes();
    _notes = notes.toList();
    _notesStreamController.add(_notes);
  }

  Stream<List<DatabaseNotes>> get ntoesStream => _notesStreamController.stream;

  Future<void> ensureDBIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // Do nothing if database is already open
    }
  }

  Future<DatabaseUser> getOrCreateUser({required String email}) async {
    await ensureDBIsOpen();
    try {
      final user = await getUser(email: email);
      return user;
    } on CouldNotGetUserException {
      return await createUser(email: email);
    }
  }

  Future<DatabaseNotes> updateNote({
    required String text,
    required DatabaseNotes note,
  }) async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updateCount = await db.update(noteTable, {
      textColum: text,
      userIdColum: note.id,
    });
    if (updateCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((note) => note.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final allnotes = await db.query(noteTable);
    return allnotes.map((note) => DatabaseNotes.fromRow(note));
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final note =
        await db.query(noteTable, limit: 1, whereArgs: [id], where: 'id=?');
    if (note.isEmpty) {
      throw CouldNotGetNoteException();
    } else {
      final Note = DatabaseNotes.fromRow(note.first);
      _notes.removeWhere(
          (note) => note.id == id); // removing old note if its in cache
      _notes.add(Note); // adding the fetched updated note to array
      _notesStreamController.add(_notes); // adding the array to Stream ..
      return Note;
    }
  }

  Future<int> deleteAllNotes() async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return deletedCount;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.delete(
      noteTable,
      where: 'id= ?',
      whereArgs: [id],
    );
    if (result == 0) {
      throw CouldNotDeleteNoteException();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    await ensureDBIsOpen();
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if (dbUser != owner) {
      throw CouldNotFindUserException();
    }
    final noteId = await db.insert(noteTable, {
      userIdColum: owner.id,
      textColum: '',
    });
    final createdNote = DatabaseNotes(
      id: noteId,
      text: textColum,
      userId: owner.id,
    );
    _notes.add(createdNote);
    _notesStreamController.add(_notes);
    return createdNote;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    await ensureDBIsOpen();

    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      limit: 1,
      where: 'email = ? ',
      whereArgs: [email.toLowerCase()],
    );

    if (result.isNotEmpty) {
      throw CouldNotGetUserException();
    } else {
      return DatabaseUser.fromRow(result.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    await ensureDBIsOpen();
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
    await ensureDBIsOpen();

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
      // caching notes upon creating the above two tables
      _cacheNotes();
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
      CREATE TABLE IF NOT EXISTS "user" (
	"id"	INTEGER NOT NULL,
	"email"	TEXT NOT NULL UNIQUE,
	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';

const createDatabaseNotes = '''
      CREATE TABLE IF NOT EXISTS "notes" (
	"id"	INTEGER NOT NULL,
	"user_id"	INTEGER NOT NULL,
	"text"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
      ''';
