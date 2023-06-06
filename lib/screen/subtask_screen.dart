import 'package:flutter/material.dart';

import '../helper.dart';
import '../models/sub_task.dart';

class SubtaskScreen extends StatefulWidget {
  final int taskId;
  final String task;

  SubtaskScreen({required this.taskId, required this.task});

  @override
  _SubtaskScreenState createState() => _SubtaskScreenState();
}

class _SubtaskScreenState extends State<SubtaskScreen> {
  late Future<List<Subtask>> _subtaskListFuture;

  @override
  void initState() {
    super.initState();
    _subtaskListFuture = DatabaseHelper.instance.getSubtasks(widget.taskId);
  }

  void _deleteSubtask(Subtask subtask) async {
    await DatabaseHelper.instance.deleteSubtask(subtask.id!);
    setState(() {
      _subtaskListFuture = DatabaseHelper.instance.getSubtasks(widget.taskId);
    });
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Task Deleted'),
      ),
    );
  }

  // edite subtask
  void _showEditSubtaskDialog(Subtask subtask) {
    String _subtaskTitle = subtask.title;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController _textEditingController =
            TextEditingController(text: _subtaskTitle);
        return AlertDialog(
          title: const Text('Edit Task'),
          content: Form(
            key: _formKey,
            child: TextField(
              autofocus: true,
              controller: _textEditingController, // Use the controller here
              decoration: const InputDecoration(
                hintText: 'Enter Task title',
              ),
              onChanged: (value) {
                _subtaskTitle = value;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                subtask.title = _subtaskTitle;
                await DatabaseHelper.instance.updateSubtask(subtask);
                setState(() {
                  _subtaskListFuture =
                      DatabaseHelper.instance.getSubtasks(widget.taskId);
                });
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task Updated'),
                  ),
                );
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
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
        centerTitle: true,
        title: Text(widget.task),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Subtask>>(
          future: _subtaskListFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final subtasks = snapshot.data!;
              return ListView.builder(
                itemCount: subtasks.length,
                itemBuilder: (context, index) {
                  final subtask = subtasks[index];
                  return ListTile(
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: subtask.isCompleted,
                          onChanged: (value) {
                            subtask.isCompleted = value!;
                            DatabaseHelper.instance.updateSubtask(subtask);
                            setState(() {});
                          },
                        ),
                        Text(
                          subtask.title,
                          style: TextStyle(
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditSubtaskDialog(subtask);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteSubtask(subtask);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddSubtaskDialog();
        },
      ),
    );
  }

  void _showAddSubtaskDialog() {
    String _subtaskTitle = '';

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Subtask'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter subtask title',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter subtask title';
                }
                return null;
              },
              onChanged: (value) {
                _subtaskTitle = value;
              },
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final subtask = Subtask(
                    taskId: widget.taskId,
                    title: _subtaskTitle,
                    isCompleted: false,
                  );
                  await DatabaseHelper.instance.insertSubtask(subtask);
                  setState(() {
                    _subtaskListFuture =
                        DatabaseHelper.instance.getSubtasks(widget.taskId);
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task Added'),
                    ),
                  );
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
