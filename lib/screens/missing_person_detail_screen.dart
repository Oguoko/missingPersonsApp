import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/missing_person.dart';
import '../models/comment.dart';
import 'package:uuid/uuid.dart';

class MissingPersonDetailScreen extends StatefulWidget {
  final String personId;

  const MissingPersonDetailScreen({super.key, required this.personId});

  @override
  State<MissingPersonDetailScreen> createState() =>
      _MissingPersonDetailScreenState();
}

class _MissingPersonDetailScreenState extends State<MissingPersonDetailScreen> {
  final FirestoreService _service = FirestoreService();
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Missing Person Details")),
      body: FutureBuilder<MissingPerson?>(
        future: _service.getMissingPerson(widget.personId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final person = snapshot.data;
          if (person == null) {
            return const Center(child: Text("Person not found."));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Photos
                SizedBox(
                  height: 200,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: person.photos
                        .map((url) => Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(url),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  person.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),
                Text("Age: ${person.age}"),
                Text("Gender: ${person.gender}"),
                const SizedBox(height: 8),

                Text(
                  "Last Seen Location:",
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(person.lastSeenLocation),
                const SizedBox(height: 8),

                Text(
                  "Description:",
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(person.physicalDescription),
                const SizedBox(height: 20),

                Text(
                  "Status: ${person.status}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: person.status == "missing"
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                const SizedBox(height: 20),

                const Divider(),

                // COMMENTS SECTION
                const Text(
                  "Comments",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),

                StreamBuilder<List<Comment>>(
                  stream: _service.getComments(widget.personId),
                  builder: (context, commentSnapshot) {
                    if (!commentSnapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final comments = commentSnapshot.data!;

                    return Column(
                      children: comments
                          .map(
                            (c) => ListTile(
                              title: Text(c.comment),
                              subtitle: Text(
                                "By: ${c.userId} • ${c.createdAt.toString()}",
                                style:
                                    const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // ADD COMMENT
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    labelText: "Add a comment...",
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        if (_commentController.text.trim().isEmpty) return;

                        final newComment = Comment(
                          id: const Uuid().v4(),
                          comment: _commentController.text.trim(),
                          userId: _service.currentUserId ?? "anonymous",
                          createdAt: DateTime.now(),
                        );

                        await _service.addComment(
                            widget.personId, newComment);

                        _commentController.clear();
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
