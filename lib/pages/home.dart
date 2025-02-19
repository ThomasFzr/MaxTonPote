import 'package:flutter/material.dart';
import 'dart:math';

class Person {
  String name;
  String imageUrl;
  int distance;

  Person(this.name, this.imageUrl, this.distance);
}

class HomeApp extends StatelessWidget {
  const HomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final List<String> names = [
    'Alice', 'Bob', 'Charlie', 'David', 'Emma',
    'Frank', 'Grace', 'Henry', 'Isabella', 'Jack',
    'Katie', 'Leo', 'Mia', 'Nathan', 'Olivia',
    'Paul', 'Quincy', 'Rachel', 'Samuel', 'Tina'
  ];

  final Random random = Random();

  @override
  Widget build(BuildContext context) {
    List<Person> persons = List.generate(
      20,
      (index) => Person(
        names[index],
        'https://picsum.photos/seed/${random.nextInt(1000)}/100/100',
        random.nextInt(50) + 1,
      ),
    );

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(
                  persons[index].imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(
                persons[index].name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                '${persons[index].distance} km',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}