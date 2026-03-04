/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'academic_progress_card.dart';
import 'attendance_pie_chart_card.dart';
import 'next_fee_due_card.dart';

class DashboardCardsRow extends StatelessWidget {
  const DashboardCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure the controller is available
    final AttendanceController controller = Get.put(AttendanceController());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile Layout (< 600px)
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              const AcademicProgressCard(
                percentage: 82,
                examName: 'Midterm Exams',
                subtitle: 'Overall Performance',
              ),
              const SizedBox(height: 16),
              _buildAttendanceCard(controller),
              const SizedBox(height: 16),
              const NextFeeDueCard(
                dueDate: '15 March 2026',
                feeType: 'Monthly Fee',
                status: 'Due Soon',
              ),
            ],
          );
        }

        // Tablet Layout (< 900px)
        if (constraints.maxWidth < 900) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: const AcademicProgressCard(
                  percentage: 82,
                  examName: 'Midterm Exams',
                  subtitle: 'Overall Performance',
                ),
              ),
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: _buildAttendanceCard(controller),
              ),
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: const NextFeeDueCard(
                  dueDate: '15 March 2026',
                  feeType: 'Monthly Fee',
                  status: 'Due Soon',
                ),
              ),
            ],
          );
        }

        // Desktop Layout (Row)
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: AcademicProgressCard(
                  percentage: 82,
                  examName: 'Midterm Exams',
                  subtitle: 'Overall Performance',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceCard(controller),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: NextFeeDueCard(
                  dueDate: '15 March 2026',
                  feeType: 'Monthly Fee',
                  status: 'Due Soon',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Reusable Reactive Card
  Widget _buildAttendanceCard(AttendanceController controller) {
    return Obx(() {
      final summary = controller.dashboardSummary.value;
      return AttendancePieChartCard(
        isLoading: controller.isDashboardLoading.value,
        present: summary?.present ?? 0,
        absent: summary?.absent ?? 0,
        leave: summary?.late ?? 0,
        total: summary?.total ?? 0,
      );
    });
  }
}  */
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/academicCardController.dart';
import 'package:school_management_system/controllers/attendance_controller.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/services/auth_service.dart';
import 'academic_progress_card.dart';
import 'attendance_pie_chart_card.dart';
import 'next_fee_due_card.dart';
/*
class DashboardCardsRow extends StatelessWidget {
  const DashboardCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    
    // Ensure the AttendanceController is available
    final AttendanceController controller = Get.put(AttendanceController());
    Get.put(AcademicProgressController(studentId: 792, classId:1
    ));
    final StudentFeeController feeController = Get.put(StudentFeeController());

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile Layout (< 600px)
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              const AcademicProgressCard(), // No parameters needed now
              const SizedBox(height: 16),
              _buildAttendanceCard(controller),
              const SizedBox(height: 16),
              const NextFeeDueCard(
                dueDate: '15 March 2026',
                feeType: 'Monthly Fee',
                status: 'Due Soon',
              ),
            ],
          );
        }

        // Tablet Layout (< 900px)
        if (constraints.maxWidth < 900) {
          return Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: const AcademicProgressCard(),
              ),
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: _buildAttendanceCard(controller),
              ),
              SizedBox(
                width: (constraints.maxWidth - 16) / 2,
                child: const NextFeeDueCard(
                  dueDate: '15 March 2026',
                  feeType: 'Monthly Fee',
                  status: 'Due Soon',
                ),
              ),
            ],
          );
        }

        // Desktop Layout (Row)
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: AcademicProgressCard(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAttendanceCard(controller),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: NextFeeDueCard(
                  dueDate: '15 March 2026',
                  feeType: 'Monthly Fee',
                  status: 'Due Soon',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Reusable Reactive Attendance Card
  Widget _buildAttendanceCard(AttendanceController controller) {
    return Obx(() {
      final summary = controller.dashboardSummary.value;
      return AttendancePieChartCard(
        isLoading: controller.isDashboardLoading.value,
        present: summary?.present ?? 0,
        absent: summary?.absent ?? 0,
        leave: summary?.late ?? 0,
        total: summary?.total ?? 0,
      );
    });
  }
}  */


class DashboardCardsRow extends StatelessWidget {
  const DashboardCardsRow({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Inject Controllers
    // We use Get.put so they are initialized as soon as the Dashboard builds.
    // The AcademicProgressController now fetches the StudentID internally.
    final AcademicProgressController academicController = Get.put(AcademicProgressController());
    final AttendanceController attendanceController = Get.put(AttendanceController());
    final StudentFeeController feeController = Get.put(StudentFeeController());

    return LayoutBuilder(
      builder: (context, constraints) {
        const double spacing = 16.0;

        // --- Mobile Layout (< 600px): Stacked Vertically ---
        if (constraints.maxWidth < 600) {
          return Column(
            children: [
              const AcademicProgressCard(),
              const SizedBox(height: spacing),
              _buildAttendanceCard(attendanceController),
              const SizedBox(height: spacing),
              _buildNextFeeDueCard(feeController),
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
              SizedBox(
                width: cardWidth,
                child: const AcademicProgressCard(),
              ),
              SizedBox(
                width: cardWidth,
                child: _buildAttendanceCard(attendanceController),
              ),
              SizedBox(
                width: cardWidth,
                child: _buildNextFeeDueCard(feeController),
              ),
            ],
          );
        }

        // --- Desktop Layout (> 900px): Side-by-Side Row ---
        // IntrinsicHeight ensures all cards stretch to the height of the tallest card.
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Expanded(
                child: AcademicProgressCard(),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _buildAttendanceCard(attendanceController),
              ),
              const SizedBox(width: spacing),
              Expanded(
                child: _buildNextFeeDueCard(feeController),
              ),
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
        leave: summary?.late ?? 0, // Mapping 'late' to leave/other as per your UI
        total: summary?.total ?? 0,
      );
    });
  }

  // --- Helper: Reactive Fee Due Card ---
  Widget _buildNextFeeDueCard(StudentFeeController controller) {
    return Obx(() {
      // Show loading state if the fee controller is working
      if (controller.isLoading.value) {
        return const NextFeeDueCard(
          dueDate: 'Loading...',
          feeAmount: '...',
        );
      }

      final currentFee = controller.getCurrentMonthFee();

      if (currentFee == null) {
        return const NextFeeDueCard(
          dueDate: 'No Record',
          feeAmount: 'N/A',
        );
      }

      return NextFeeDueCard(
        dueDate: currentFee.feeDate,
        feeAmount: currentFee.fee.toStringAsFixed(0),
      );
    });
  }
}