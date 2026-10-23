
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'database/database_helper.dart';
import 'repositories/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Chrome.
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const TaskManagerApp());
}

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const TaskManagerPage(),
    );
  }
}

class TaskManagerPage extends StatefulWidget {
  const TaskManagerPage({super.key});

  @override
  State<TaskManagerPage> createState() =>
      _TaskManagerPageState();
}

class _TaskManagerPageState extends State<TaskManagerPage> {
  final TextEditingController _taskController =
      TextEditingController();

  late final TaskRepository _repository;

  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _repository = TaskRepository(DatabaseHelper.instance);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final tasks = await _repository.getTasks();

      if (!mounted) return;

      setState(() {
        _tasks = tasks;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a task.'),
        ),
      );
      return;
    }

    try {
      await _repository.addTask(title);

      _taskController.clear();

      await _loadTasks();
    } catch (error) {
      _showError('Could not add task: $error');
    }
  }

  Future<void> _toggleCompleted(
    Map<String, dynamic> task,
    bool? checked,
  ) async {
    try {
      await _repository.updateCompleted(
        task['id'] as int,
        checked ?? false,
      );

      await _loadTasks();
    } catch (error) {
      _showError('Could not update task: $error');
    }
  }

  Future<void> _deleteTask(int id) async {
    try {
      await _repository.deleteTask(id);

      await _loadTasks();
    } catch (error) {
      _showError('Could not delete task: $error');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Task Manager',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter task',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _addTask(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add Task'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            'Unable to load tasks.\n'
                            '$_errorMessage',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : _tasks.isEmpty
                          ? const Center(
                              child: Text('No tasks yet.'),
                            )
                          : ListView.builder(
                              itemCount: _tasks.length,
                              itemBuilder: (context, index) {
                                final task = _tasks[index];

                                final bool isCompleted =
                                    task['completed'] == 1;

                                return Card(
                                  child: ListTile(
                                    leading: Checkbox(
                                      value: isCompleted,
                                      onChanged: (value) {
                                        _toggleCompleted(
                                          task,
                                          value,
                                        );
                                      },
                                    ),
                                    title: Text(
                                      task['title'] as String,
                                      style: TextStyle(
                                        decoration: isCompleted
                                            ? TextDecoration
                                                .lineThrough
                                            : TextDecoration
                                                .none,
                                        color: isCompleted
                                            ? Colors.grey
                                            : null,
                                      ),
                                    ),
                                    trailing: IconButton(
                                      tooltip: 'Delete task',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _deleteTask(
                                          task['id'] as int,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
