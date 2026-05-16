import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_api_service.dart';

void main() {
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

  void loadTasks() async {
    try {
      final fetchedTasks = await TaskApiService.fetchTasks();

      setState(() {
        tasks = fetchedTasks;
        isLoading = false;
      });

    } catch (e) {

      setState(() {
        errorMessage = "Nie udało się pobrać danych";
        isLoading = false;
      });
    }
  }

  void _goToAddTask() async {

    final Task? newTask = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTaskScreen(),

        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {

          final offsetAnimation = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );

    if (newTask != null) {

      setState(() {
        tasks.add(newTask);
      });
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

          ? const Center(
        child: CircularProgressIndicator(),
      )

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

                return TaskCard(
                  title: item.title,

                  subtitle:
                  "termin: ${item.deadline} | priorytet: ${item.priority}",

                  icon: item.done
                      ? Icons.check_circle
                      : Icons.task,
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddTask,
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {

  AddTaskScreen({super.key});

  final titleController = TextEditingController();
  final deadlineController = TextEditingController();
  final priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nowe zadanie"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            TextField(
              controller: titleController,

              decoration: const InputDecoration(
                labelText: "Tytuł zadania",
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
                labelText: "Priorytet (wysoki/średni/niski)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {

                  if (titleController.text.isNotEmpty) {

                    final newTask = Task(
                      title: titleController.text,
                      deadline: deadlineController.text,
                      priority: priorityController.text,
                      done: false,
                    );

                    Navigator.pop(context, newTask);
                  }
                },

                child: const Text("Zapisz zadanie"),
              ),
            ),
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

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 5,
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.blue,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Text(subtitle),
      ),
    );
  }
}