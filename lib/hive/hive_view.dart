import 'dart:developer';
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
      ..date = DateTime.now();

    final box = Boxes.getTasks();
    box.add(task);
  }

  void saveTxt() async {
    String tasksString = "";
    final box = Boxes.getTasks();
    for (var element in box.values) {
      var str = "${element.text},${element.date.toString()};";
      tasksString += str;
    }

    final Directory directory = await getApplicationDocumentsDirectory();

    File txtFile = await File("${directory.path}/tasks.txt").create();

    txtFile.writeAsString(tasksString);
    print(tasksString);
  }

  void getTxt() async {
    final Directory directory = await getApplicationDocumentsDirectory();
    File txtFile = File("${directory.path}/tasks.txt");
    String tasksString = await txtFile.readAsString();

    final box = Boxes.getTasks();
    await box.clear();

    List<String> tasksStrings = tasksString.split(";");
    tasksStrings.removeLast();

    for (var element in tasksStrings) {
      List<String> taskElements = element.split(",");
      print(taskElements);
      Task temp = Task()
        ..text = taskElements[0]
        ..date = DateTime.parse(taskElements[1]);

      box.add(temp);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hive Database"),
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Boxes.getTasks().listenable(),
        builder: (context, value, child) {
          final tasks = value.values.toList().cast<Task>();
          return Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton.icon(
                      onPressed: saveTxt,
                      icon: const Icon(Icons.save),
                      label: const Text("Save as Txt to AppDocument")),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ElevatedButton.icon(
                      onPressed: getTxt,
                      icon: const Icon(Icons.save),
                      label: const Text("Get from Txt in AppDocument")),
                ),
                const SizedBox(width: 24),
              ]),
              Expanded(
                  child: tasks.isEmpty
                      ? const Center(child: Text("No Task Found"))
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(tasks[index].text),
                              subtitle: Text(tasks[index].date.toString()),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        var textController =
                                            TextEditingController();
                                        textController.text = tasks[index].text;
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text("Update Task"),
                                              content: TextField(
                                                controller: textController,
                                                decoration: const InputDecoration(
                                                    border:
                                                        OutlineInputBorder()),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                    onPressed: () {
                                                      if (textController
                                                          .text.isNotEmpty) {
                                                        tasks[index].text =
                                                            textController.text;
                                                        tasks[index].save();
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                    child:
                                                        const Text('update')),
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.edit)),
                                  IconButton(
                                      onPressed: () {
                                        tasks[index].delete();
                                      },
                                      icon: const Icon(Icons.delete))
                                ],
                              ),
                            );
                          },
                        ))
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
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
                  decoration:
                      const InputDecoration(border: OutlineInputBorder()),
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
      ),
    );
  }
}
