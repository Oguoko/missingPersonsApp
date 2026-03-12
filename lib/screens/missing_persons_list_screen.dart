import 'package:flutter/material.dart';

import '../models/missing_person.dart';
import '../services/firestore_service.dart';
import '../ui/app_theme.dart';
import '../ui/app_widgets.dart';
import 'missing_person_detail_screen.dart';

class MissingPersonsListScreen extends StatefulWidget {
  MissingPersonsListScreen({super.key});

  @override
  State<MissingPersonsListScreen> createState() =>
      _MissingPersonsListScreenState();
}

class _MissingPersonsListScreenState extends State<MissingPersonsListScreen> {
  final FirestoreService _service = FirestoreService();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Missing Persons TZ'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Report Missing Person'),
      ),
      body: StreamBuilder<List<MissingPerson>>(
        stream: _service.getMissingPersons(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final persons = snapshot.data ?? [];
          final filtered = persons.where((p) {
            final q = _searchQuery.trim().toLowerCase();
            if (q.isEmpty) return true;
            return p.name.toLowerCase().contains(q) ||
                p.lastSeenLocation.toLowerCase().contains(q) ||
                p.status.toLowerCase().contains(q);
          }).toList();

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.section),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ScreenHeader(
                      title: 'Active Missing Cases',
                      subtitle: 'Help reunite families by sharing verified leads.',
                    ),
                    const SizedBox(height: AppSpacing.section),
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search by name, status, or last seen location',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    if (persons.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No missing persons reported yet.'),
                        ),
                      )
                    else if (filtered.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text('No results match your search.'),
                        ),
                      )
                    else
                      Expanded(
                        child: isWide
                            ? GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: AppSpacing.standard,
                                  crossAxisSpacing: AppSpacing.standard,
                                  childAspectRatio: 2.5,
                                ),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) =>
                                    _PersonCard(person: filtered[index]),
                              )
                            : ListView.separated(
                                itemBuilder: (context, index) =>
                                    _PersonCard(person: filtered[index]),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: AppSpacing.standard),
                                itemCount: filtered.length,
                              ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PersonCard extends StatelessWidget {
  final MissingPerson person;

  const _PersonCard({required this.person});

  @override
  Widget build(BuildContext context) {
    final photo = person.photos.isNotEmpty ? person.photos.first : null;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.standard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MissingPersonDetailScreen(personId: person.id),
            ),
          );
        },
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.standard),
              child: photo != null
                  ? Image.network(photo, width: 82, height: 82, fit: BoxFit.cover)
                  : Container(
                      width: 82,
                      height: 82,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.person_outline, size: 36),
                    ),
            ),
            const SizedBox(width: AppSpacing.standard),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    person.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    person.lastSeenLocation,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  StatusBadge(status: person.status),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.tight),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
