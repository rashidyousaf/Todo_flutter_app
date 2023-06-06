import 'package:flutter/material.dart';

import 'package:todo_app/screen/task_screen.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Flip the Switch'),
      ),
      body: Center(
        child: SizedBox(
          width: 100,
          child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const TaskScreen()));
              },
              child: const Text(
                'Enter',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              )),
        ),
      ),
    );
  }
}
