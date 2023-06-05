import 'dart:io';

import 'package:database/hive/boxes.dart';
import 'package:database/hive/task_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';

class HiveView extends StatefulWidget {
  const HiveView({Key? key}) : super(key: key);

  @override
  State<HiveView> createState() => _HiveViewState();
}

class _HiveViewState extends State<HiveView> {
  final List<Task> tasks = [];
  @override
  void dispose() {
    Hive.box('tasks').close();

    super.dispose();
  }

  Future addTask({
    required String text,
  }) async {
    final task = Task()
      ..text = text
      ..date = DateTime.now()
      ..isDone = false;

    final box = Boxes.getTasks();
    box.add(task);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive Database Example"),
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Boxes.getTasks().listenable(),
        builder: (context, value, child) {
          final tasks = value.values.toList().cast<Task>();
          return tasks.isEmpty
              ? const Center(child: Text("No Task Found"))
              : ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    return TaskTile(task: tasks[index]);
                  },
                );
        },
      ),
      floatingActionButton: buildFAB(context),
    );
  }

  FloatingActionButton buildFAB(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () {
        var textController = TextEditingController();
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text("Add Task"),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(border: OutlineInputBorder()),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      if (textController.text.isNotEmpty) {
                        addTask(text: textController.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('ADD')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel')),
              ],
            );
          },
        );
      },
    );
  }
}

class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        onChanged: (value) {
          setState(() {
            widget.task.isDone = !widget.task.isDone;
          });
        },
        value: widget.task.isDone,
      ),
      title: Text(
        widget.task.text,
        style: widget.task.isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      subtitle: Text(
        widget.task.date.toString(),
        style: widget.task.isDone
            ? const TextStyle(decoration: TextDecoration.lineThrough)
            : null,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                var textController = TextEditingController();
                textController.text = widget.task.text;
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Update Task"),
                      content: TextField(
                        controller: textController,
                        decoration:
                            const InputDecoration(border: OutlineInputBorder()),
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                widget.task.text = textController.text;
                                widget.task.save();
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('update')),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancel')),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                widget.task.delete();
              },
              icon: const Icon(Icons.delete))
        ],
      ),
    );
  }
}
