import 'dart:math';

import 'package:flutter/material.dart';
import 'package:todo_app/screen/subtask_screen.dart';

import '../helper.dart';
import '../models/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({Key? key}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _taskTitle;
  late bool _isEditing;
  late int _editingTaskId;
  List<Task> _tasks = []; // Define list of tasks
  final TextEditingController _textEditingController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _isEditing = false;
    _editingTaskId = 0;
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_isEditing) {
        final updatedTask = Task(
          id: _editingTaskId,
          title: _taskTitle,
          isCompleted: false,
        );

        await DatabaseHelper.instance.updateTask(updatedTask);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task updated'),
          ),
        );

        setState(() {
          _isEditing = false;
          _editingTaskId = 0;
          _taskTitle = '';
        });
      } else {
        final newTask = Task(
          title: _taskTitle,
          isCompleted: false,
        );

        final dbHelper = DatabaseHelper.instance;
        final taskId = await dbHelper.insertTask(newTask);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Divider added'),
          ),
        );

        setState(() {
          newTask.id = taskId;
          _tasks.add(newTask); // Add the new task to the list of tasks
          _formKey.currentState!.reset();
        });
      }
    }
  }

  void _deleteTask(Task task) async {
    await DatabaseHelper.instance.deleteTask(task.id ?? 0);
    setState(() {
      _tasks.remove(task); // Remove the task from the list of tasks
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Divider Deleted'),
      ),
    );
  }

  void _editTask(Task task) {
    setState(() {
      _isEditing = true;
      _editingTaskId = task.id ?? 0;
      _taskTitle = task.title;
      _textEditingController.text = task.title; // update the text field's value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Add Divider'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _textEditingController,
                decoration: const InputDecoration(
                  labelText: 'Add Divider',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Divider';
                  }
                  return null;
                },
                onSaved: (value) {
                  _taskTitle = value!;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  await _submitForm();
                  _textEditingController.clear();
                },
                child: const Text(
                  'Add Divider',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 16.0),
              Expanded(
                child: FutureBuilder<List<Task>>(
                  future: DatabaseHelper.getTasks(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final tasks = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SubtaskScreen(
                                    taskId: task.id ?? 0,
                                    task: task.title,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(
                                top: 5,
                              ),
                              child: ListTile(
                                title: Text(task.title),
                                trailing: SizedBox(
                                  width: 60,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          _editTask(task);
                                        },
                                        child: const Icon(Icons.edit),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _deleteTask(task);
                                        },
                                        child: const Icon(Icons.delete),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
