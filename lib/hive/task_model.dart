import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String text;

  @HiveField(1)
  late DateTime date;

  @HiveField(2)
  late bool isDone;

}
