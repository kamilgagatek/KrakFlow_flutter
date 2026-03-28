import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;

  const Task({
    required this.title,
    required this.deadline,
    required this.done,
    required this.priority,
  });
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
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
      ),
    );
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  final List<Task> tasks = const [
    Task(title: "Projekt Flutter", deadline: "jutro", done: false, priority: "wysoki"),
    Task(title: "Ćwiczenia z matematyki", deadline: "dzisiaj", done: false, priority: "wysoki"),
    Task(title: "Przeczytać o widgetach", deadline: "w piątek", done: false, priority: "średni"),
    Task(title: "Napisać notatki", deadline: "weekend", done: false, priority: "niski"),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("KrakFlow"),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Text("Masz dziś ${tasks.length} zadania",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Dzisiejsze zadania"),
            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final item = tasks[index];
                  return TaskCard(
                    icon: Icons.task,
                    title: item.title,
                    subtitle: "termin: ${item.deadline} | priorytet: ${item.priority}",
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.blue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}