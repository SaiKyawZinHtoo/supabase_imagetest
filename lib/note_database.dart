import 'package:image_test/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteDatabase {
  //Databse -> notes
  final database = Supabase.instance.client.from('notes');

  //Create a new note
  Future createNote(Note newNote) async {
    await database.insert(newNote.toMap());
  }

  //Read all notes
  final stream = Supabase.instance.client.from('notes').stream(
    primaryKey: ['id'],
  ).map((data) => data.map((noteMap) => Note.fromMap(noteMap)).toList());
  //Update a note
  Future updateNote(Note oldNote, String newContent) async {
    await database.update({'content': newContent}).eq('id', oldNote.id!);
  }

  //Delete a note
  Future delete(Note note) async {
    await database.delete().eq('id', note.id!);
  }
}
