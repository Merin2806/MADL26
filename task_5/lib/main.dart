import 'package:flutter/material.dart';

void main() {
  runApp(const StudentDashboardApp());
}

class ClassSession {
  final String time;
  final String subject;
  final IconData icon;

  ClassSession(this.time, this.subject, this.icon);
}

class ActionItem {
  final String title;
  final IconData icon;

  ActionItem(this.title, this.icon);
}

class DashboardData {
  final List<ClassSession> classes = [
    ClassSession('10:00 AM', 'Data Structures', Icons.code),
    ClassSession('12:00 PM', 'Web Development', Icons.web),
    ClassSession('02:00 PM', 'Cyber Security', Icons.security),
  ];

  final List<ActionItem> actions = [
    ActionItem('Study Materials', Icons.menu_book),
    ActionItem('Assignments', Icons.assignment),
    ActionItem('Attendance', Icons.bar_chart),
    ActionItem('Notices', Icons.campaign),
  ];
}

class StudentDashboardApp extends StatelessWidget {
  const StudentDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Campus Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: DashboardPage(data: DashboardData()),
    );
  }
}

class DashboardPage extends StatelessWidget {
  final DashboardData data;

  const DashboardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        title: const Text('Student Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined)),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.person, color: Colors.indigo)),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final double maxWidth = constraints.maxWidth;
        final int crossAxisCount = maxWidth > 900 ? 4 : (maxWidth > 600 ? 2 : 1);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeSection(),
              const SizedBox(height: 25),
              const Text("Today's Classes", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.classes.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) => _ClassRow(session: data.classes[index]),
                ),
              ),
              const SizedBox(height: 25),
              const Text('Quick Actions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                itemCount: data.actions.length,
                itemBuilder: (context, index) => _ActionCard(item: data.actions[index]),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _WelcomeSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(20)),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, Student! 👋', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('Here is your campus update for today.', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}

class _ClassRow extends StatelessWidget {
  final ClassSession session;
  const _ClassRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(session.icon, color: Theme.of(context).primaryColor, size: 28),
          const SizedBox(width: 15),
          SizedBox(width: 80, child: Text(session.time, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(session.subject, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final ActionItem item;
  const _ActionCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(item.title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}