import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Person {
  final String name;
  final String imageUrl;
  final int distance;

  Person(this.name, this.imageUrl, this.distance);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    List<Person> persons = List.generate(
        20,
        (index) =>
            Person('Person $index', 'https://picsum.photos/20$index', index));

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'MAX TON POTE',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 138, 0, 41),
        ),
        body: ListView.builder(
            itemCount: persons.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 6.0),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: const Color.fromARGB(255, 0, 0, 0),
                      )),
                  tileColor: const Color.fromARGB(159, 255, 240, 240),
                  leading: Image.network(persons[index].imageUrl, width: 50),
                  title: Text(persons[index].name),
                  trailing: Text('${persons[index].distance} km'),
                ),
              );
            }),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Recherche',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
          selectedItemColor: const Color.fromARGB(255, 138, 0, 41),
        ),
      ),
    );
  }
}
