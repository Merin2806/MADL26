import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// --------------------------------------------------
// MAIN APP
// --------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'Navigation and Gestures',

      // 2. NAMED ROUTES
      initialRoute: '/',

      routes: {
        '/': (context) => const HomeScreen(),
        '/details': (context) => const DetailsScreen(),
        '/about': (context) => const AboutScreen(),
      },
    );
  }
}

// --------------------------------------------------
// 1. HOME SCREEN
// --------------------------------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.navigation,
              size: 80,
              color: Colors.blue,
            ),

            const SizedBox(height: 20),

            const Text(
              'Navigation & Gestures',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------------------
            // 3. GESTURE DETECTOR - TAP
            // ---------------------------------------

            GestureDetector(
              onTap: () {

                // Navigate using named route
                Navigator.pushNamed(
                  context,
                  '/details',
                );
              },

              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 15,
                ),

                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),

                child: const Text(
                  'Tap to Open Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------------------
            // ABOUT BUTTON
            // ---------------------------------------

            ElevatedButton(
              onPressed: () {

                Navigator.pushNamed(
                  context,
                  '/about',
                );
              },

              child: const Text(
                'Go to About',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// DETAILS SCREEN
// --------------------------------------------------

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details Screen'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.touch_app,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            const Text(
              'You are on the Details Screen',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            // ---------------------------------------
            // 3. GESTURE DETECTOR - LONG PRESS
            // ---------------------------------------

            GestureDetector(
              onLongPress: () {

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Long press detected!',
                    ),
                  ),
                );
              },

              child: Container(
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Text(
                  'Long Press Me',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ---------------------------------------
            // BACK NAVIGATION
            // ---------------------------------------

            ElevatedButton(
              onPressed: () {

                Navigator.pop(context);
              },

              child: const Text(
                'Go Back',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --------------------------------------------------
// ABOUT SCREEN
// --------------------------------------------------

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            const Icon(
              Icons.info,
              size: 80,
              color: Colors.orange,
            ),

            const SizedBox(height: 20),

            const Text(
              'About This App',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'This app demonstrates navigation, '
              'named routes and gestures.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 30),

            // ---------------------------------------
            // SWIPE GESTURE
            // ---------------------------------------

            GestureDetector(
              onHorizontalDragEnd: (details) {

                Navigator.pop(context);
              },

              child: Container(
                padding: const EdgeInsets.all(25),

                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(15),
                ),

                child: const Text(
                  'Swipe left or right to go back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}