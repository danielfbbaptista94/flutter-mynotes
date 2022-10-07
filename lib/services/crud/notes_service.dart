import 'dart:async';

import 'package:mynotes/services/crud/constants/db_constants.dart';
import 'package:mynotes/services/crud/entities/note_database.dart';
import 'package:mynotes/services/crud/entities/user_database.dart';
import 'package:mynotes/services/crud/exceptions/note_exceptions.dart';
import 'package:mynotes/services/crud/exceptions/user_exceptions.dart';
import 'package:mynotes/services/crud/users_service.dart';
import 'package:mynotes/services/database/db_connection.dart';

class NotesService {
  final DatabaseConnection connection = DatabaseConnection();
  final UsersService usersService = UsersService();
  List<DatabaseNote> _notes = [];
  DatabaseUser? _user;

  late final StreamController<List<DatabaseNote>> _notesStreamController;
  Stream<List<DatabaseNote>> get allNotes => _notesStreamController.stream;

  static final NotesService _shared = NotesService._sharedInstance();
  NotesService._sharedInstance() {
    _notesStreamController = StreamController<List<DatabaseNote>>.broadcast(
      onListen: () {
        _notesStreamController.sink.add(_notes);
      },
    );
  }

  factory NotesService() => _shared;

  Future<void> cacheNotes({required String email}) async {
    _user = await usersService.getUser(email: email);
    // final allNotes = await getNotes();
    final allNotes = await getNotesByUser(userId: _user!.id);

    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();
    await getNote(id: note.id);

    final updateCounts = await db.update(
      noteTable,
      {
        textColumn: text,
        isSyncWithCloundColumn: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updateCounts == 0) {
      throw CouldNotUpdateNote();
    } else {
      final updatedNote = await getNote(id: note.id);
      _notes.removeWhere((element) => element.id == updatedNote.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);

      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getNotesByUser({required int userId}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final notes = await db.query(
      noteTable,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<Iterable<DatabaseNote>> getNotes() async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final result = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) {
      throw NoteDoNotExists();
    } else {
      final note = DatabaseNote.fromRow(result.first);
      _notes.removeWhere((element) => element.id == id);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    _notes = [];
    _notesStreamController.add(_notes);

    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    final db = connection.getDatabaseOrThrow();

    final deleteCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deleteCount == 0) {
      throw CouldNotDeleteNote();
    } else {
      _notes.removeWhere((note) => note.id == id);
      _notesStreamController.add(_notes);
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await connection.ensureDbIsOpen();
    final db = connection.getDatabaseOrThrow();

    final dbUser = await usersService.getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserDoNotExists();
    }

    const text = '';
    final noteId = await db.insert(noteTable, {
      userIdColumn: owner.id,
      textColumn: text,
      isCompletedColumn: 0,
      isSyncWithCloundColumn: 1
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isCompleted: false,
      isSyncWithClound: true,
    );

    _notes.add(note);
    _notesStreamController.add(_notes);

    return note;
  }
}
