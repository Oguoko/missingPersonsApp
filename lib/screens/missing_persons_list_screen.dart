import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/missing_person.dart';
import 'missing_person_detail_screen.dart';

class MissingPersonsListScreen extends StatelessWidget {
  final FirestoreService _service = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Missing Persons TZ"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/add');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<MissingPerson>>(
        stream: _service.getMissingPersons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No missing persons reported yet.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }
          print("Snapshot: ${snapshot.data}");


          print("STREAM DATA: ${snapshot.data}");
          print("SNAPSHOT HAS DATA: ${snapshot.hasData}");
          print("SNAPSHOT LENGTH: ${snapshot.data?.length}");


          final persons = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: persons.length,
            itemBuilder: (context, index) {
              final p = persons[index];
              final photo = p.photos.isNotEmpty ? p.photos.first : null;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: photo != null
                        ? Image.network(photo, width: 60, height: 60, fit: BoxFit.cover)
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey.shade300,
                            child: Icon(Icons.person, size: 32),
                          ),
                  ),
                  title: Text(
                    p.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Last seen: ${p.lastSeenLocation}"),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MissingPersonDetailScreen(personId: p.id),
                      ),
                    );
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
