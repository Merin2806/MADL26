import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Database App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final nameController = TextEditingController();
  final emailController = TextEditingController();

  final DatabaseReference databaseRef =
      FirebaseDatabase.instance.ref("users");

  // Write data to Firebase
  Future<void> saveData() async {

    String name = nameController.text.trim();
    String email = emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter name and email"),
        ),
      );
      return;
    }

    DatabaseReference newUserRef = databaseRef.push();

    await newUserRef.set({
      "name": name,
      "email": email,
    });

    nameController.clear();
    emailController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Data saved successfully!"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Firebase Database"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            const Text(
              "Enter User Details",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveData,
              child: const Text("Save Data"),
            ),

            const SizedBox(height: 30),

            const Text(
              "Saved Users",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: UserList(
                databaseRef: databaseRef,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UserList extends StatelessWidget {

  final DatabaseReference databaseRef;

  const UserList({
    super.key,
    required this.databaseRef,
  });

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<DatabaseEvent>(
      stream: databaseRef.onValue,

      builder: (context, snapshot) {

        if (snapshot.hasError) {
          return const Center(
            child: Text("Error loading data"),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final data = snapshot.data?.snapshot.value;

        if (data == null) {
          return const Center(
            child: Text("No users found"),
          );
        }

        final users = Map<dynamic, dynamic>.from(data as Map);

        return ListView(
          children: users.entries.map((entry) {

            final user = Map<dynamic, dynamic>.from(entry.value);

            return Card(
              child: ListTile(
                leading: const Icon(Icons.person),

                title: Text(
                  user["name"] ?? "",
                ),

                subtitle: Text(
                  user["email"] ?? "",
                ),
              ),
            );

          }).toList(),
        );
      },
    );
  }
}