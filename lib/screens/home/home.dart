import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todolist/data/data.dart';
import 'package:todolist/data/repo/repository.dart';
import 'package:todolist/screens/edit/edit.dart';
import 'package:todolist/main.dart';
import 'package:todolist/screens/home/bloc/task_list_bloc.dart';
import 'package:todolist/widgets.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Task>(taskBoxName);
    final themeData = Theme.of(context);
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditTaskScreen(
                      task: Task(),
                    )));
          },
          label: const Row(
            children: [Text('Add New Task'), Icon(CupertinoIcons.add)],
          )),
      body: BlocProvider<TaskListBloc>(
        create: (context) => TaskListBloc(context.read<Repository<Task>>()),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                height: 110,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  themeData.colorScheme.primary,
                  Colors.black,
                ])),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'To Do List',
                            style: themeData.textTheme.headline6!
                                .apply(color: themeData.colorScheme.onPrimary),
                          ),
                          Icon(
                            CupertinoIcons.share,
                            color: themeData.colorScheme.onPrimary,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Container(
                        height: 38,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(19),
                          color: themeData.colorScheme.onPrimary,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) {
                            context
                                .read<TaskListBloc>()
                                .add(TaskListSearch(value));
                          },
                          controller: controller,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(CupertinoIcons.search),
                            label: Text('Search tasks...'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(child: Consumer<Repository<Task>>(
                builder: (context, value, child) {
                  context.read<TaskListBloc>().add(TaskListStarted());
                  return BlocBuilder<TaskListBloc, TaskListState>(
                    builder: (context, state) {
                      if (state is TaskListSuccess) {
                        return TaskList(
                            items: state.items, themeData: themeData);
                      } else if (state is TaskListEmpty) {
                        return const EmptyState();
                      } else if (state is TaskListLoading ||
                          state is TaskListInitial) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is TaskListError) {
                        return Center(child: Text(state.errorMessage));
                      } else {
                        throw Exception('State is not valid.');
                      }
                    },
                  );
                },
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  const TaskList({
    super.key,
    required this.items,
    required this.themeData,
  });

  final List<Task> items;
  final ThemeData themeData;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today',
                      style: themeData.textTheme.headline6!
                          .apply(fontSizeFactor: 0.9),
                    ),
                    Container(
                      width: 70,
                      height: 3,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(1.5)),
                    )
                  ],
                ),
                MaterialButton(
                  color: const Color(0xffEAEFF5),
                  textColor: secondaryTextColor,
                  elevation: 0,
                  onPressed: () {
                    context.read<TaskListBloc>().add(TaskListDeleteAll());
                  },
                  child: const Row(
                    children: [
                      Text('Delete All'),
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        CupertinoIcons.delete_solid,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            final Task task = items[index - 1];
            return TaskItem(task: task);
          }
        });
  }
}

class TaskItem extends StatefulWidget {
  static const double height = 84;
  const TaskItem({
    super.key,
    required this.task,
  });

  final Task task;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    ThemeData themData = Theme.of(context);
    final Color priorityColor;

    switch (widget.task.priority) {
      case Priority.low:
        priorityColor = lowpriority;
        break;
      case Priority.normal:
        priorityColor = normalPriority;
        break;
      case Priority.high:
        priorityColor = primaryColor;
        break;
    }
    return InkWell(
      onLongPress: () {
        widget.task.delete();
      },
      onTap: () {
        setState(() {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => EditTaskScreen(task: widget.task)));
          // widget.task.isCompleted = !widget.task.isCompleted;
        });
      },
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 0),
        margin: EdgeInsets.only(top: 8),
        height: TaskItem.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: themData.colorScheme.surface,
        ),
        child: Row(
          children: [
            InkWell(
                onTap: () {
                  setState(() {
                    widget.task.isCompleted = !widget.task.isCompleted;
                  });
                },
                child: MyCheckBox(value: widget.task.isCompleted)),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.task.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 14,
                    decoration: widget.task.isCompleted
                        ? TextDecoration.lineThrough
                        : null),
              ),
            ),
            Container(
              width: 5,
              color: priorityColor,
            ),
          ],
        ),
      ),
    );
  }
}
