import 'package:flutter/material.dart';
import 'package:mynotes/services/auth/auth_service.dart';
import 'package:mynotes/services/crud/entities/note_database.dart';
import 'package:mynotes/services/crud/entities/user_database.dart';
import 'package:mynotes/services/crud/notes_service.dart';
import 'package:mynotes/services/crud/users_service.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> {
  DatabaseNote? _note;
  late final NotesService _notesService;
  late final UsersService _usersService;
  late final TextEditingController _textController;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _notesService = NotesService();
    _usersService = UsersService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<DatabaseNote> createNewNote() async {
    final existingNote = _note;

    if (existingNote != null) {
      return existingNote;
    }
    final owner = await _getUserLoggedIn();

    return await _notesService.createNote(owner: owner);
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    await _notesService.updateNote(
      note: note,
      text: _textController.text,
    );
  }

  void _setepTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteNoteIfTextIsEmpty() {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      _notesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      _notesService.updateNote(
        note: note,
        text: _textController.text,
      );
    }
  }

  Future<DatabaseUser> _getUserLoggedIn() async {
    return await _usersService.getUser(email: userEmail);
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Note'),
      ),
      body: FutureBuilder(
        future: createNewNote(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              _note = snapshot.data as DatabaseNote;
              _setepTextControllerListener();
              return TextField(
                controller: _textController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
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
