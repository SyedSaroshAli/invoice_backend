import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/services/auth_service.dart';

class UserIDSection extends StatelessWidget {
  const UserIDSection({super.key});

  Future<Map<String, String>> _loadUserData() async {
    final auth = AuthService();
    final name = await auth.getStudentName() ?? 'Student';
    final id = await auth.getStudentId() ?? '';
    return {'name': name, 'id': id};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadUserData(),
      builder: (context, snapshot) {
        final studentName = snapshot.data?['name'] ?? 'Student';
        final userID = snapshot.data?['id'] ?? '';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Profile Avatar
               /* Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE0F2FE),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFE0F2FE),
                    child: Text(
                      studentName.isNotEmpty
                          ? studentName[0].toUpperCase()
                          : "S",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),*/

                const SizedBox(width: 24),

                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /*
                      Text(
                        "Welcome Back 👋",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),*/
                      const SizedBox(height: 4),
                      Text(
                        studentName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // User ID Strip
                      if (userID.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.hash,
                                size: 14,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'ID: $userID',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
