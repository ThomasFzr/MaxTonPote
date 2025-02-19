import 'package:flutter/material.dart';

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
    return HomePage();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    List<Person> persons = List.generate(
        20,
        (index) =>
            Person('Toto', 'https://picsum.photos/seed/$index/100/100', index));

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 18, 18, 18),
      body: ListView.builder(
        itemCount: persons.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
            child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: Image.network(persons[index].imageUrl,
                    width: 50, height: 50, fit: BoxFit.cover),
              ),
              title: Text(
                persons[index].name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text('${persons[index].distance} km',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),),
            ),
          );
        },
      ),
    );
  }
}
