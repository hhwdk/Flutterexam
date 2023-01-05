// main.dart
import 'package:flutter/material.dart';
import 'sql_helper.dart';

void main() {
  runApp(const MyApp());
}

//MyApp, er root elementet i min app og extender statelesswidget classen. Med andre ord,

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'To-do List ',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: const HomePage());
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // All todoitems
  List<Map<String, dynamic>> todoitems = [];
  bool _isLoading = true;
  // This function is used to fetch all data from the database
  void _refreshtodoitems() async {
    final data = await SQLHelper.getItems();
    setState(() {
      todoitems = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshtodoitems(); // Loading the diary when the app starts
  }

  final TextEditingController _titleController = TextEditingController();

  // This function will be triggered when the floating button is pressed
  // It will also be triggered when you want to update an item
  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> create new item
      // id != null -> update an existing item
      final existingtodoitem =
          todoitems.firstWhere((element) => element['id'] == id);
      _titleController.text = existingtodoitem['title'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: false,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                /* bottom: MediaQuery.of(context).viewInsets.bottom , */
                bottom: 275,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _titleController,
                    minLines: 1,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Titel'),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new todoitem

                      await _addItem();

                      // Clear the text fields
                      _titleController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: const Text('Create New'),
                  )
                ],
              ),
            ));
  }

// Tilføj ny opgave
  Future<void> _addItem() async {
    await SQLHelper.createItem(
      _titleController.text,
    );
    _refreshtodoitems();
    // refreshtodoitems er den funktion der indlæser fra databasen. Her køres den efter at createItem har kørt, således at opdateringen reflekteres i appen.
  }

  // opdater en eksisterende opgave

  // Slet en opgave
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Opgave slettet'),
    ));
    // Snackbar = den lille grå box i bunden der popper op, og fortæller status på en handling.
    _refreshtodoitems();
    // refreshtodoitems er den funktion der indlæser fra databasen. Her køres den efter at deleteItem har kørt, således at opdateringen reflekteres i appen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-do List - HHW 2023'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: todoitems.length,
              itemBuilder: (context, index) => Card(
                color: Colors.orange[200],
                margin: const EdgeInsets.all(15),
                child: ListTile(
                    title: Text(todoitems[index]['title']),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(todoitems[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
