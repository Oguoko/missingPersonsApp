import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/missing_person.dart';

class MissingPersonsListScreen extends StatelessWidget {
  final FirestoreService _service = FirestoreService();

  MissingPersonsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Missing Persons"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, "/add");
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MissingPerson>>(
        stream: _service.getMissingPersons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("No missing persons reported yet."),
            );
          }

          final people = snapshot.data!;

          return ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              final p = people[index];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  leading: p.photos.isNotEmpty
                      ? Image.network(
                          p.photos.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.person, size: 40),
                  title: Text(
                    p.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text("Last seen: ${p.lastSeenLocation}"),

                  trailing: Text(
                    p.status.toUpperCase(),
                    style: TextStyle(
                      color: p.status == "missing" ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, "/details", arguments: p.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
