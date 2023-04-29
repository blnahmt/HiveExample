import 'package:database/hive/task_model.dart';
import 'package:hive/hive.dart';

class Boxes {
  static Box<Task> getTasks() => Hive.box<Task>('tasks');
}
