import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../services/firestore_service.dart';
import '../models/missing_person.dart';
import '../models/comment.dart';

class AddMissingPersonScreen extends StatefulWidget {
  const AddMissingPersonScreen({super.key});

  @override
  _AddMissingPersonScreenState createState() => _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final FirestoreService _service = FirestoreService();

  List<File> _images = [];

  // Form fields
  String _name = "";
  int _age = 0;
  String _gender = "Male";
  String _description = "";
  String _lastSeenLocation = "";

  bool _loading = false;

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    setState(() {
      _images = picked.map((file) => File(file.path)).toList();
    });
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please upload at least 1 image.")),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      String id = const Uuid().v4();

      // Upload images
      List<String> downloadUrls = [];
      for (var file in _images) {
        String url = await _service.uploadImage(file, id);
        downloadUrls.add(url);
      }

      // Build the person model
      final person = MissingPerson(
        id: id,
        name: _name,
        age: _age,
        gender: _gender,
        physicalDescription: _description,
        lastSeenLocation: _lastSeenLocation,
        photos: downloadUrls,
        status: "missing",
        submittedBy: _service.currentUserId ?? "anonymous",
        createdAt: DateTime.now(),
      );

      await _service.addMissingPerson(person);

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Missing person submitted successfully.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Report Missing Person")),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                decoration: InputDecoration(labelText: "Full Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
                onSaved: (v) => _name = v!,
              ),

              // AGE
              TextFormField(
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
                onSaved: (v) => _age = int.parse(v!),
              ),

              // GENDER
              DropdownButtonFormField(
                decoration: InputDecoration(labelText: "Gender"),
                initialValue: _gender,
                items: ["Male", "Female", "Other"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v!),
              ),

              // DESCRIPTION
              TextFormField(
                decoration: InputDecoration(labelText: "Physical Description"),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? "Required" : null,
                onSaved: (v) => _description = v!,
              ),

              // LAST SEEN
              TextFormField(
                decoration: InputDecoration(labelText: "Last Seen Location"),
                validator: (v) => v!.isEmpty ? "Required" : null,
                onSaved: (v) => _lastSeenLocation = v!,
              ),

              SizedBox(height: 20),

              // IMAGES
              Text("Photos", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 10),

              Wrap(
                spacing: 10,
                children: [
                  ..._images.map((img) => Image.file(img, height: 80)),
                  InkWell(
                    onTap: pickImages,
                    child: Container(
                      height: 80,
                      width: 80,
                      color: Colors.grey[300],
                      child: Icon(Icons.add),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // SUBMIT
              ElevatedButton(
                onPressed: _loading ? null : submitForm,
                child: _loading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
