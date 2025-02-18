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
            Person('Person $index', 'https://picsum.photos/seed/$index/100/100', index));

    return ListView.builder(
      itemCount: persons.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
          child: ListTile(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: Colors.black)),
            tileColor: const Color.fromARGB(159, 255, 240, 240),
            leading: Image.network(persons[index].imageUrl, width: 50),
            title: Text(persons[index].name),
            trailing: Text('${persons[index].distance} km'),
          ),
        );
      },
    );
  }
}
