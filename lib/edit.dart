import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todolist/data.dart';
import 'package:todolist/main.dart';

class EditTaskScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();
  final Task task;

  EditTaskScreen({super.key, required this.task});
  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: themeData.colorScheme.surface,
        foregroundColor: themeData.colorScheme.onSurface,
        title: Text('Edit Task'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final task = Task();
            task.name = _controller.text;
            task.priority = Priority.low;
            if (task.isInBox) {
              task.save();
            } else {
              final Box<Task> box = Hive.box(taskBoxName);
              box.add(task);
            }
            Navigator.pop(context);
          },
          label: const Row(
            children: [
              Icon(
                CupertinoIcons.check_mark,
                size: 18,
              ),
              SizedBox(
                width: 4,
              ),
              Text('Save Cahnges'),
            ],
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Flex(
              direction: Axis.horizontal,
              children: [
                Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                      label: 'High',
                      color: primaryColor,
                      isSelected: task.priority == Priority.high,
                    )),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                      label: 'Normal',
                      color: Color(0xffF09819),
                      isSelected: task.priority == Priority.normal,
                    )),
                SizedBox(
                  width: 8,
                ),
                Flexible(
                    flex: 1,
                    child: PriorityCheckBox(
                      label: 'Low',
                      color: Color(0xff3BE1F1),
                      isSelected: task.priority == Priority.low,
                    ))
              ],
            ),
            TextField(
              controller: _controller,
              decoration:
                  InputDecoration(label: Text('Add Task For Today ...')),
            )
          ],
        ),
      ),
    );
  }
}

class PriorityCheckBox extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;

  const PriorityCheckBox(
      {super.key,
      required this.label,
      required this.color,
      required this.isSelected});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(width: 1, color: Colors.grey),
          color: secondaryTextColor.withOpacity(.2)),
      child: Stack(
        children: [
          Center(
            child: text(label),
          ),
          MyCheckBox(value: isSelected),
        ],
      ),
    );
  }

  text(String label) {}
}
