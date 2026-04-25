
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/academicProgressController.dart';
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'academic_progress_card.dart';
import 'attendance_pie_chart_card.dart';
import 'next_fee_due_card.dart';


class DashboardCardsRow extends StatelessWidget {
  final List<String> permissions;
  const DashboardCardsRow({super.key, required this.permissions});

  @override
  Widget build(BuildContext context) {
    // 1. Inject Controllers
    final AcademicProgressController academicController = Get.put(
      AcademicProgressController(),
    );
    final AttendanceController attendanceController = Get.put(
      AttendanceController(),
    );
    final StudentFeeController feeController = Get.put(StudentFeeController());

    final bool hasAttendance =
        permissions.contains('HRMS.SelfViewAttendance') ||
        permissions.contains('HRMS.ViewAttendance');
    final bool hasFees = permissions.any(
      (p) => p.startsWith('Student.Fee') || p.startsWith('Finance'),
    );
    final bool hasAcademic = permissions.any(
      (p) => p.startsWith('Report') || p.startsWith('Student'),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;

        // --- Mobile Layout (< 600px): Stacked Vertically ---
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              if (hasAcademic) ...[
                const AcademicProgressCard(),
                if (hasAttendance || hasFees) const SizedBox(height: spacing),
              ],
              if (hasAttendance) ...[
                _buildAttendanceCard(attendanceController),
                if (hasFees) const SizedBox(height: spacing),
              ],
              if (hasFees) _buildNextFeeDueCard(feeController),
            ],
          );
        }

        // --- Tablet Layout (600px - 900px): Grid/Wrap ---
        if (constraints.maxWidth < 900) {
          final double cardWidth = (constraints.maxWidth - spacing) / 2;
          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              if (hasAcademic)
                SizedBox(width: cardWidth, child: const AcademicProgressCard()),
              if (hasAttendance)
                SizedBox(
                  width: cardWidth,
                  child: _buildAttendanceCard(attendanceController),
                ),
              if (hasFees)
                SizedBox(
                  width: cardWidth,
                  child: _buildNextFeeDueCard(feeController),
                ),
            ],
          );
        }

        // --- Desktop Layout (> 900px): Side-by-Side Row ---
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasAcademic) const Expanded(child: AcademicProgressCard()),
              if (hasAcademic && (hasAttendance || hasFees))
                const SizedBox(width: spacing),
              if (hasAttendance)
                Expanded(child: _buildAttendanceCard(attendanceController)),
              if (hasAttendance && hasFees) const SizedBox(width: spacing),
              if (hasFees) Expanded(child: _buildNextFeeDueCard(feeController)),
            ],
          ),
        );
      },
    );
  }

  // --- Helper: Reactive Attendance Card ---
  Widget _buildAttendanceCard(AttendanceController controller) {
    return Obx(() {
      final summary = controller.dashboardSummary.value;
      return AttendancePieChartCard(
        isLoading: controller.isDashboardLoading.value,
        present: summary?.present ?? 0,
        absent: summary?.absent ?? 0,
        leave:
            summary?.late ?? 0, // Mapping 'late' to leave/other as per your UI
        total: summary?.total ?? 0,
      );
    });
  }

  // --- Helper: Reactive Fee Due Card ---
  Widget _buildNextFeeDueCard(StudentFeeController controller) {
    return Obx(() {
      // Show loading state if the fee controller is working
      if (controller.isLoading.value) {
        return const NextFeeDueCard(dueDate: 'Loading...', feeAmount: '...');
      }

      final currentFee = controller.getCurrentMonthFee();

      if (currentFee == null) {
        return const NextFeeDueCard(dueDate: 'No Record', feeAmount: 'N/A');
      }

      return NextFeeDueCard(
        dueDate: currentFee.feeDate,
        feeAmount: currentFee.fee.toStringAsFixed(0),
      );
    });
  }
}
