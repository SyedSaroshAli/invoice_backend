import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NextFeeDueCard extends StatelessWidget {
  final String dueDate;     // Fee date for the month
  final String feeAmount;   // Fee amount for the month

  const NextFeeDueCard({
    super.key,
    required this.dueDate,
    required this.feeAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with calendar icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEDD5), // Pastel Orange
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    LucideIcons.calendar,
                    color: Color(0xFFF59E0B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Current Month Fee',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Fee Date
            Text(
              dueDate,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 16),

            // Fee Amount
            Text(
              'Rs. $feeAmount',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}