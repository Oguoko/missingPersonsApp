import 'package:flutter/material.dart';

import '../models/missing_person.dart';
import '../services/firestore_service.dart';
import '../ui/app_theme.dart';
import '../ui/app_widgets.dart';

class MissingPersonDetailScreen extends StatelessWidget {
  final String personId;
  final FirestoreService _service = FirestoreService();

  MissingPersonDetailScreen({super.key, required this.personId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Case Details')),
      body: FutureBuilder<MissingPerson?>(
        future: _service.getMissingPerson(personId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Case not found.'));
          }

          final p = snapshot.data!;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.section),
                children: [
                  if (p.photos.isNotEmpty)
                    SizedBox(
                      height: 280,
                      child: PageView(
                        children: p.photos
                            .map(
                              (url) => ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.large),
                                child: Image.network(url, fit: BoxFit.cover),
                              ),
                            )
                            .toList(),
                      ),
                    )
                  else
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(AppRadius.large),
                      ),
                      child: const Icon(Icons.person_outline, size: 72),
                    ),
                  const SizedBox(height: AppSpacing.section),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                p.name,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            StatusBadge(status: p.status),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Age: ${p.age} • Gender: ${p.gender}',
                          style: const TextStyle(color: AppColors.textSecondary),
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
                          title: 'Physical Description',
                          icon: Icons.badge_outlined,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        Text(p.physicalDescription),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.standard),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Last Seen',
                          icon: Icons.place_outlined,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        Text(p.lastSeenLocation),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionTitle(
                          title: 'Share Case',
                          icon: Icons.campaign_outlined,
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        const Text(
                          'Help spread awareness by sharing this case with your community.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.standard),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.share),
                          label: const Text('Share Case'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
