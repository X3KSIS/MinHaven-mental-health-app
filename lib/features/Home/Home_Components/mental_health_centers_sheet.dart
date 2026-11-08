// lib/components/bottom_sheets/mental_health_centers_sheet.dart
import 'package:flutter/material.dart';

import 'bottom_sheet_handle.dart';

class MentalHealthCentersSheet extends StatelessWidget {
  final Color primaryColor;

  const MentalHealthCentersSheet({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final centers = [
      {
        'name': 'Chainama Hills Hospital',
        'location': 'Lusaka',
        'phone': '+260 211 228 344',
        'services': 'Psychiatric services, counseling'
      },
      {
        'name': 'University Teaching Hospital',
        'location': 'Lusaka',
        'phone': '+260 211 253 891',
        'services': 'Mental health unit, emergency care'
      },
      {
        'name': 'Kabwe General Hospital',
        'location': 'Kabwe',
        'phone': '+260 215 222 511',
        'services': 'Mental health services'
      },
      {
        'name': 'Mental Health Foundation of Zambia',
        'location': 'Nationwide',
        'phone': '+260 977 777 777',
        'services': 'Counseling, support groups'
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BottomSheetHandle(),
            const SizedBox(height: 20),
            Text(
              'Mental Health Centers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Professional help in Zambia',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: centers.length,
                itemBuilder: (context, index) {
                  final center = centers[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center['name'] as String,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              center['location'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              center['phone'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            center['services'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}