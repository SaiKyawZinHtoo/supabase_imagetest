import 'package:flutter/material.dart';
import 'package:image_test/note.dart';
import 'package:image_test/note_database.dart';

class NotePage extends StatefulWidget {
  const NotePage({super.key});

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  final notesDatabase = NoteDatabase();
  final textController = TextEditingController();

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  void addNewNote() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text("New Note"),
              content: TextField(
                controller: textController,
                autofocus: true,
                onChanged: (value) {
                  setState(() {});
                },
                decoration: InputDecoration(
                  labelText: "Note Content",
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  hintText: "Enter your note here...",
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        BorderSide(color: Colors.grey.shade300, width: 1.5),
                  ),
                  prefixIcon: Icon(Icons.note, color: Colors.blueAccent),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                ),
                style: TextStyle(fontSize: 16, color: Colors.black87),
                maxLines: null,
                textInputAction: TextInputAction.done,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    textController.clear();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: textController.text.trim().isEmpty
                      ? null
                      : () async {
                          try {
                            final newNote = Note(
                              content: textController.text.trim(),
                            );
                            await notesDatabase.createNote(newNote);
                            Navigator.pop(context);
                            textController.clear();
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Note added successfully!")),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to add note: $e")),
                            );
                          }
                        },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void updateNote(Note note) {
    textController.text = note.content;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Update Note"),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: "Note Content",
            labelStyle: TextStyle(color: Colors.blueAccent),
            hintText: "Edit your note...",
            hintStyle: TextStyle(color: Colors.grey.shade400),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blueAccent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue, width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
            ),
            prefixIcon: Icon(Icons.edit, color: Colors.blueAccent),
            contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          ),
          style: TextStyle(fontSize: 16, color: Colors.black87),
          maxLines: null,
          textInputAction: TextInputAction.done,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              textController.clear();
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: textController.text.trim().isEmpty
                ? null
                : () async {
                    try {
                      await notesDatabase.updateNote(
                          note, textController.text.trim());
                      Navigator.pop(context);
                      textController.clear();
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Note updated successfully!")),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Failed to update note: $e")),
                      );
                    }
                  },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void confirmDelete(Note note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text("Delete Note"),
        content: const Text("Are you sure you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await notesDatabase.delete(note);
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Note deleted successfully!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to delete note: $e")),
                );
              }
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notes",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.lightBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.lightBlue.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<List<Note>>(
          stream: notesDatabase.stream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final notes = snapshot.data!;
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.note_alt, size: 100, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      "No notes yet.\nTap + to add a new note.",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      note.content,
                      style: const TextStyle(fontSize: 18),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => updateNote(note),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => confirmDelete(note),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addNewNote,
        tooltip: "Add Note",
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
