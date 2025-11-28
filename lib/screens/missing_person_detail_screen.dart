import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/missing_person.dart';

class MissingPersonDetailScreen extends StatelessWidget {
  final String personId;
  final FirestoreService _service = FirestoreService();

  MissingPersonDetailScreen({required this.personId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Case Details"),
      ),
      body: FutureBuilder<MissingPerson?>(
        future: _service.getMissingPerson(personId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final p = snapshot.data!;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // IMAGES CAROUSEL
                if (p.photos.isNotEmpty)
                  SizedBox(
                    height: 260,
                    child: PageView(
                      children: p.photos.map((url) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(url, fit: BoxFit.cover),
                        );
                      }).toList(),
                    ),
                  ),

                SizedBox(height: 20),

                // NAME + STATUS BADGE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      p.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: p.status == "missing"
                            ? Colors.red.shade200
                            : Colors.green.shade200,
                      ),
                      child: Text(
                        p.status.toUpperCase(),
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),

                Text("Age: ${p.age}   |   Gender: ${p.gender}",
                    style: TextStyle(fontSize: 16)),

                SizedBox(height: 20),

                // PHYSICAL DESCRIPTION
                Text(
                  "Physical Description",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(p.physicalDescription),

                SizedBox(height: 20),

                // LAST SEEN LOCATION
                Text(
                  "Last Seen Location",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 6),
                Text(p.lastSeenLocation),

                SizedBox(height: 30),

                Divider(),

                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    label: Text("Share Case"),
                  ),
                ),

                SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
