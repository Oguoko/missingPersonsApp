import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../models/missing_person.dart';
import '../services/firestore_service.dart';
import '../ui/app_theme.dart';
import '../ui/app_widgets.dart';

class AddMissingPersonScreen extends StatefulWidget {
  const AddMissingPersonScreen({super.key});

  @override
  State<AddMissingPersonScreen> createState() => _AddMissingPersonScreenState();
}

class _AddMissingPersonScreenState extends State<AddMissingPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final FirestoreService _service = FirestoreService();

  List<File> _images = [];
  List<Uint8List> _webImages = [];

  String _name = '';
  int _age = 0;
  String _gender = 'Male';
  String _description = '';
  String _lastSeenLocation = '';

  bool _loading = false;

  Future<void> pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;

    if (kIsWeb) {
      _webImages = [];
      for (var xfile in picked) {
        final bytes = await xfile.readAsBytes();
        _webImages.add(bytes);
      }
    } else {
      _images = picked.map((file) => File(file.path)).toList();
    }

    setState(() {});
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty && _webImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload at least 1 image.')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => _loading = true);

    try {
      String id = const Uuid().v4();

      List<String> downloadUrls = [];

      if (kIsWeb) {
        for (var bytes in _webImages) {
          final url = await _service.uploadImageUnified(
            personId: id,
            bytes: bytes,
          );
          downloadUrls.add(url);
        }
      } else {
        for (var file in _images) {
          final url = await _service.uploadImageUnified(
            personId: id,
            file: file,
          );
          downloadUrls.add(url);
        }
      }

      final person = MissingPerson(
        id: id,
        name: _name,
        age: _age,
        gender: _gender,
        physicalDescription: _description,
        lastSeenLocation: _lastSeenLocation,
        photos: downloadUrls,
        status: 'missing',
        submittedBy: _service.currentUserId ?? 'anonymous',
        createdAt: DateTime.now(),
      );

      await _service.addMissingPerson(person);

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing person submitted successfully.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Missing Person')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.section),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ScreenHeader(
                    title: 'Submit a Missing Person Report',
                    subtitle:
                        'Provide clear details to help responders and the community.',
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppCard(
                    child: Column(
                      children: [
                        TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Full Name'),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _name = v!,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Age'),
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _age = int.parse(v!),
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Gender'),
                          initialValue: _gender,
                          items: ['Male', 'Female', 'Other']
                              .map(
                                (g) => DropdownMenuItem(value: g, child: Text(g)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _gender = v!),
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Physical Description',
                          ),
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _description = v!,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Last Seen Location',
                          ),
                          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                          onSaved: (v) => _lastSeenLocation = v!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Photos',
                          icon: Icons.photo_library_outlined,
                        ),
                        const SizedBox(height: AppSpacing.tight),
                        const Text(
                          'Add clear recent photos to improve identification.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            if (kIsWeb)
                              ..._webImages.map(
                                (bytes) => ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.standard),
                                  child: Image.memory(
                                    bytes,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              ..._images.map(
                                (file) => ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.standard),
                                  child: Image.file(
                                    file,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            InkWell(
                              onTap: pickImages,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.standard),
                              child: Container(
                                height: 90,
                                width: 90,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.standard),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: const Icon(Icons.add_a_photo_outlined),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : submitForm,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Submit Report'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
