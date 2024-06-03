import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sql_project/db_handler.dart';
import 'package:sql_project/models/notes.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final DbHelper dbHelper;
  late Future<List<NotesModel>> notesList;

  @override
  void initState() {
    super.initState();
    dbHelper = DbHelper();
    loadData();
  }

  void loadData() {
    setState(() {
      notesList = dbHelper.getNotesList();
    });
  }

  Future<void> _showAddNoteDialog() async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Center(child: Text('Add a note')),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  final newNote = NotesModel(
                    title: titleController.text,
                    description: descriptionController.text,
                    date: DateTime.now().toString(),
                  );

                  await dbHelper.insert(newNote);
                  loadData();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditNoteDialog(NotesModel note) async {
    final titleController = TextEditingController(text: note.title);
    final descriptionController = TextEditingController(text: note.description);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Note'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty) {
                  final editedNote = NotesModel(
                    id: note.id,
                    title: titleController.text,
                    description: descriptionController.text,
                    date: DateTime.now().toString(),
                  );

                  await dbHelper.update(editedNote);
                  loadData();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notes App',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<NotesModel>>(
              future: notesList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No notes available'));
                } else {
                  List<NotesModel> notes = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView.builder(
                      itemCount: notes.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return InkWell(
                          onLongPress: () async {
                            _showEditNoteDialog(note);
                          },
                          child: Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            key: ValueKey<int>(note.id!),
                            onDismissed: (direction) async {
                              await dbHelper.delete(note.id!);
                              loadData();
                            },
                            child: Card(
                              color: Colors.black,
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(10),
                                title: Text(
                                  note.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 20,
                                  ),
                                ),
                                subtitle: Text(
                                  note.description,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                trailing: Text(
                                  DateFormat.yMMMd().format(DateTime.parse(note.date)),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        backgroundColor: Colors.black,
        onPressed: _showAddNoteDialog,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
