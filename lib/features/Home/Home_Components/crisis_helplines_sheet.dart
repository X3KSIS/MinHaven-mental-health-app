import 'package:flutter/material.dart';
import 'bottom_sheet_handle.dart';
import 'helpline_item.dart';


class CrisisHelplinesSheet extends StatelessWidget {
  final Color primaryColor;

  const CrisisHelplinesSheet({
    super.key,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
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
              'Crisis Helplines',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Available 24/7 for immediate support',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                controller: scrollController,
                children: const [
                  HelplineItem(
                    name: 'Zambia National Counseling Centre',
                    number: '+260 971 000 000',
                    icon: Icons.phone,
                  ),
                  HelplineItem(
                    name: 'Chainama Hills Hospital',
                    number: '+260 211 228 344',
                    icon: Icons.local_hospital,
                  ),
                  HelplineItem(
                    name: 'Mental Health Foundation of Zambia',
                    number: '+260 977 777 777',
                    icon: Icons.healing,
                  ),
                  HelplineItem(
                    name: 'ZAMCOM Crisis Line',
                    number: '+260 979 123 456',
                    icon: Icons.support_agent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}