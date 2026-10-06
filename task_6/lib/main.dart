import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Multimedia App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icons, Images & Charts'),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // -------------------------
            // 1. BUILT-IN ICONS
            // -------------------------

            const Text(
              '1. Built-in Flutter Icons',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    Icon(
                      Icons.home,
                      size: 45,
                      color: Colors.blue,
                    ),
                    Icon(
                      Icons.person,
                      size: 45,
                      color: Colors.green,
                    ),
                    Icon(
                      Icons.favorite,
                      size: 45,
                      color: Colors.red,
                    ),
                    Icon(
                      Icons.settings,
                      size: 45,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // 2. LOCAL IMAGE
            // -------------------------

            const Text(
              '2. Local Image',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/image.png',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // NETWORK IMAGE
            // -------------------------

            const Text(
              'Network Image',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                'https://picsum.photos/600/300',
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // 3. CHART
            // -------------------------

            const Text(
              '3. Sales Chart',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(15),

                child: SizedBox(
                  height: 300,

                  child: BarChart(
                    BarChartData(
                      maxY: 12,

                      barGroups: [
                        BarChartGroupData(
                          x: 0,
                          barRods: [
                            BarChartRodData(toY: 5),
                          ],
                        ),

                        BarChartGroupData(
                          x: 1,
                          barRods: [
                            BarChartRodData(toY: 8),
                          ],
                        ),

                        BarChartGroupData(
                          x: 2,
                          barRods: [
                            BarChartRodData(toY: 6),
                          ],
                        ),

                        BarChartGroupData(
                          x: 3,
                          barRods: [
                            BarChartRodData(toY: 10),
                          ],
                        ),

                        BarChartGroupData(
                          x: 4,
                          barRods: [
                            BarChartRodData(toY: 7),
                          ],
                        ),
                      ],

                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,

                            getTitlesWidget: (value, meta) {
                              const months = [
                                'Jan',
                                'Feb',
                                'Mar',
                                'Apr',
                                'May',
                              ];

                              return Text(
                                months[value.toInt()],
                              );
                            },
                          ),
                        ),

                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),

                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // -------------------------
            // 4. COMBINED LAYOUT
            // -------------------------

            Card(
              elevation: 5,

              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  children: const [
                    Icon(
                      Icons.dashboard,
                      size: 60,
                      color: Colors.blue,
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Complete Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      'Icons, images and charts '
                      'combined in a single Flutter layout.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}