import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
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
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("KrakFlow"),
        ),
        body: Center(
          child: Column(
            children: [
              Text("Organizacja studiów"),
              SizedBox(height: 20),
              Text("Dzisiejsze zadania"),
              SizedBox(height: 10),
              TaskCard(
                icon: Icons.task,
                title: "Projekt Flutter",
                subtitle: "termin: jutro",
              ),
              TaskCard(
                icon: Icons.task,
                title: "Ćwiczenia z matematyki",
                subtitle: "termin: dzisiaj",
              ),
              TaskCard(
                icon: Icons.task,
                title: "Przeczytać o widgetach",
                subtitle: "termin: w tym tygodniu",
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}