import 'package:flutter/material.dart';
import 'dart:math';
import '../models/task.dart';
import '../services/task_sync_service.dart';
import '../services/task_local_database.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KrakFlow',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Task> tasks = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      await TaskSyncService.loadInitialDataIfNeeded();

      final localTasks = TaskLocalDatabase.getTasks();

      setState(() {
        tasks = localTasks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Nie udało się załadować danych";
        isLoading = false;
      });
    }
  }

  Future<void> addTask(Task task) async {
    await TaskLocalDatabase.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(Task task) async {
    await TaskLocalDatabase.updateTask(task);
    await loadTasks();
  }

  void _goToAddTask() async {
    final Task? newTask = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTaskScreen(),
      ),
    );

    if (newTask != null) {
      await addTask(newTask);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("KrakFlow"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      )
          : Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Masz dziś ${tasks.length} zadań",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final item = tasks[index];

                return GestureDetector(
                  onTap: () async {
                    final Task? updatedTask = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddTaskScreen(editTask: item),
                      ),
                    );

                    if (updatedTask != null) {
                      await updateTask(updatedTask);
                    }
                  },
                  child: TaskCard(
                    title: item.title,
                    subtitle:
                    "termin: ${item.deadline} | priorytet: ${item.priority}",
                    icon: item.done
                        ? Icons.check_circle
                        : Icons.task,
                    onToggle: (value) async {
                      final updated = Task(
                        id: item.id,
                        title: item.title,
                        deadline: item.deadline,
                        priority: item.priority,
                        done: value ?? false,
                      );

                      await updateTask(updated);
                    },
                    done: item.done,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  AddTaskScreen({super.key, this.editTask});

  final Task? editTask;

  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (editTask != null) {
      titleController.text = editTask!.title;
      deadlineController.text = editTask!.deadline;
      priorityController.text = editTask!.priority;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(editTask == null ? "Nowe zadanie" : "Edytuj zadanie"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Tytuł",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: deadlineController,
              decoration: const InputDecoration(
                labelText: "Termin",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priorityController,
              decoration: const InputDecoration(
                labelText: "Priorytet",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleController.text.isEmpty) return;

                  final task = Task(
                    id: editTask?.id ?? Random().nextInt(1000000),
                    title: titleController.text,
                    deadline: deadlineController.text,
                    priority: priorityController.text,
                    done: editTask?.done ?? false,
                  );

                  Navigator.pop(context, task);
                },
                child: Text(editTask == null
                    ? "Dodaj zadanie"
                    : "Zapisz zmiany"),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool done;
  final Function(bool?) onToggle;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.done,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Checkbox(
          value: done,
          onChanged: onToggle,
        ),
      ),
    );
  }
}