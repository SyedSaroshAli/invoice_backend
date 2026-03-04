/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/authentication_screens/changePasswordScreen.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _loadProfileData() async {
    final auth = AuthService();
    final userData = await auth.getUserData();
    final name = await auth.getStudentName() ?? 'Student';
    final id = await auth.getStudentId() ?? '';
    final admitCardController = Get.put(AdmitCardController());
    
    // 2. Load the data (if not already loaded by onInit)
    await admitCardController.loadAdmitCard();
    
    // 3. Extract the model
    final studentData = admitCardController.admitCard.value;

    return {
      'name': name,
      'id': id,
      // Priority: AdmitCard API -> UserData (Backup) -> Empty String
      'class': studentData?.className ?? userData?['classDesc']?.toString() ?? '',
      'section': studentData?.section ?? userData?['section']?.toString() ?? '',
      'fatherName': studentData?.fatherName ?? userData?['father_Name']?.toString() ?? '',
      'rollNo': studentData?.rollNo != null 
          ? studentData!.rollNo.toString() 
          : (userData?['rollNo']?.toString() ?? id),
  
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: _loadProfileData(),
      builder: (context, snapshot) {
        final data = snapshot.data ??
            {
              'name': 'Student',
          'id': '',
          'class': '',
          'section': '',
          'fatherName': '',
          'rollNo': '',
            };

        final studentName = data['name']!;
        final rollNumber = data['rollNo']!;
        final fatherName = data['fatherName']!;
        final className = data['class']!;
        final sectionName = data['section']!;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                       /* Hero(
                          tag: 'profile_pic',
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 4,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              child: Text(
                                studentName.isNotEmpty
                                    ? studentName[0].toUpperCase()
                                    : "S",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            Text(
                              studentName,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            if (data['id']!.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Student ID: ${data['id']}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // First Row: Roll No & Father Name
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.assignment_ind_outlined,
                              label: 'Roll Number',
                              value: rollNumber.isNotEmpty ? rollNumber : '—',
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.person_outline,
                              label: 'Father Name',
                              value: fatherName.isNotEmpty ? fatherName : '—',
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Second Row: Class & Section (Updated to match alignment)
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.class_outlined,
                              label: 'Class',
                              value: className.isNotEmpty ? className : '—',
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              icon: Icons.layers_outlined,
                              label: 'Section',
                              value: sectionName.isNotEmpty ? sectionName : '—',
                              color: Colors.purple,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>  ChangePasswordScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.lock_reset, size: 22),
                          label: const Text(
                            'Change Password',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await AuthService().logout();
                            if (context.mounted) {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const SigninScreen(),
                                ),
                                (route) => false,
                              );
                            }
                          },
                          icon: const Icon(Icons.logout, size: 22),
                          label: const Text(
                            'Sign Out',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            foregroundColor: Theme.of(context).colorScheme.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .error
                                  .withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/authentication_screens/changePasswordScreen.dart';
import 'package:school_management_system/authentication_screens/signin.dart';
import 'package:school_management_system/controllers/admit_card_controller.dart';
import 'package:school_management_system/services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<Map<String, String>> _loadProfileData() async {
    final auth = AuthService();
    final userData = await auth.getUserData();
    final name = await auth.getStudentName() ?? 'Student';
    final id = await auth.getStudentId() ?? '';
    final admitCardController = Get.put(AdmitCardController());
    
    // Load the data from API
    await admitCardController.loadAdmitCard();
    
    final studentData = admitCardController.admitCard.value;

    return {
      'name': name,
      'id': id,
      'class': studentData?.className ?? userData?['classDesc']?.toString() ?? '',
      'section': studentData?.section ?? userData?['section']?.toString() ?? '',
      'fatherName': studentData?.fatherName ?? userData?['father_Name']?.toString() ?? '',
      'rollNo': studentData?.rollNo != null 
          ? studentData!.rollNo.toString() 
          : (userData?['rollNo']?.toString() ?? id),
    };
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<Map<String, String>>(
      future: _loadProfileData(),
      builder: (context, snapshot) {
        // 1. Handle Loading State (Prevents showing "Student" while fetching)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Handle Error State
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        }

        // 3. Data is ready
        final data = snapshot.data ?? {};
        final studentName = data['name'] ?? 'Student';
        final rollNumber = data['rollNo'] ?? '';
        final fatherName = data['fatherName'] ?? '';
        final className = data['class'] ?? '';
        final sectionName = data['section'] ?? '';

        return Scaffold(
          body: LayoutBuilder(
            builder: (context, constraints) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: (screenHeight * 0.22).clamp(160.0, 220.0),
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Padding(
                          padding: EdgeInsets.all(screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      studentName,
                                      style: TextStyle(
                                        fontSize: (screenWidth * 0.07).clamp(22.0, 30.0),
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    if (data['id'] != null && data['id']!.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Student ID: ${data['id']}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              
                              // Responsive Info Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.assignment_ind_outlined,
                                      label: 'Roll Number',
                                      value: rollNumber.isNotEmpty ? rollNumber : '—',
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.person_outline,
                                      label: 'Father Name',
                                      value: fatherName.isNotEmpty ? fatherName : '—',
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.class_outlined,
                                      label: 'Class',
                                      value: className.isNotEmpty ? className : '—',
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _InfoCard(
                                      icon: Icons.layers_outlined,
                                      label: 'Section',
                                      value: sectionName.isNotEmpty ? sectionName : '—',
                                      color: Colors.purple,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                              
                              // Action Buttons
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.lock_reset, size: 22),
                                  label: const Text('Change Password'),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await AuthService().logout();
                                    if (context.mounted) {
                                      Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(builder: (context) => const SigninScreen()),
                                        (route) => false,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.logout, size: 22),
                                  label: const Text('Sign Out'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 18),
                                    foregroundColor: Theme.of(context).colorScheme.error,
                                    side: BorderSide(color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}