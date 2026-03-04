/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';

/// Student Fee Screen — Student-facing view showing:
///   - Year filter
///   - Pending fee status
///   - Regular fee records table
///   - Additional fee records table
///   - Summary totals
///   - PDF export
class StudentFeeScreen extends StatelessWidget {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentFeeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fee'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllFeeData,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, controller),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.regularFees.isEmpty &&
            controller.additionalFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Year Filter
              _YearFilter(controller: controller),

              const SizedBox(height: 16),

              // Error message
              if (controller.errorMessage.value.isNotEmpty)
                _ErrorBanner(message: controller.errorMessage.value),

              // Pending Fee Status
              _PendingFeeCard(controller: controller),

              const SizedBox(height: 16),

              // Summary Cards
              _SummaryRow(controller: controller),

              const SizedBox(height: 24),

              // Regular Fees Table
              _FeeTable(
                title: 'Regular Fees',
                icon: Icons.receipt_long,
                records: controller.regularFees,
                emptyMessage: 'No regular fee records for this year.',
              ),

              const SizedBox(height: 24),

              // Additional Fees Table
              _FeeTable(
                title: 'Additional Fees',
                icon: Icons.add_card,
                records: controller.additionalFees,
                emptyMessage: 'No additional fee records for this year.',
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    StudentFeeController controller,
  ) async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Fee_Statement_${controller.selectedYear.value}.pdf',
      );
    }
  }
}

// ─── Year Filter ───────────────────────────────────────────

class _YearFilter extends StatelessWidget {
  final StudentFeeController controller;
  const _YearFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Year:',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                  initialValue: controller.selectedYear.value,
                  isExpanded: true,
                  items: StudentFeeController.yearOptions
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.onYearChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error Banner ──────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Pending Fee Card ──────────────────────────────────────

class _PendingFeeCard extends StatelessWidget {
  final StudentFeeController controller;
  const _PendingFeeCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.pendingFeeMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();

      final isNoPending = msg.toLowerCase().contains('no pending');

      return Card(
        color: isNoPending
            ? const Color(0xFF10B981).withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isNoPending
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                isNoPending ? Icons.check_circle : Icons.warning_amber_rounded,
                color: isNoPending
                    ? const Color(0xFF10B981)
                    : Theme.of(context).colorScheme.error,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pending Status',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(msg, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ─── Summary Cards ─────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final StudentFeeController controller;
  const _SummaryRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _SummaryCard(
              icon: Icons.receipt_long,
              label: 'Regular',
              amount: controller.totalRegularFees,
              count: controller.regularFees.length,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.add_card,
              label: 'Additional',
              amount: controller.totalAdditionalFees,
              count: controller.additionalFees.length,
              color: const Color(0xFF8B5CF6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              icon: Icons.account_balance_wallet,
              label: 'Total',
              amount: controller.grandTotal,
              count:
                  controller.regularFees.length +
                  controller.additionalFees.length,
              color: const Color(0xFF10B981),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final int count;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.amount,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              'Rs. ${amount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              '$count record${count == 1 ? '' : 's'}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Fee Table ─────────────────────────────────────────────

class _FeeTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FeeRecord> records;
  final String emptyMessage;

  const _FeeTable({
    required this.title,
    required this.icon,
    required this.records,
    required this.emptyMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${records.length} record${records.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 40,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      emptyMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                columns: const [
                  DataColumn(
                    label: Text(
                      'Month',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Amount',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    numeric: true,
                  ),
                  DataColumn(
                    label: Text(
                      'Fee Date',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Slip No',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: records.map((r) => _buildRow(context, r)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  DataRow _buildRow(BuildContext context, FeeRecord record) {
    return DataRow(
      cells: [
        DataCell(Text(record.month)),
        DataCell(Text(record.details)),
        DataCell(Text('Rs. ${record.fee.toStringAsFixed(0)}')),
        DataCell(Text(record.feeDate)),
        DataCell(Text(record.slipNo.toString())),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';

class StudentFeeScreen extends StatelessWidget {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentFeeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fee'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllFeeData,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, controller),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.regularFees.isEmpty &&
            controller.additionalFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _YearFilter(controller: controller),
              const SizedBox(height: 16),
              if (controller.errorMessage.value.isNotEmpty)
                _ErrorBanner(message: controller.errorMessage.value),
              _PendingFeeCard(controller: controller),
              const SizedBox(height: 16),
              _SummaryRow(controller: controller),
              const SizedBox(height: 24),
              _FeeTable(
                title: 'Regular Fees',
                icon: Icons.receipt_long,
                records: controller.regularFees,
                emptyMessage: 'No regular fee records for this year.',
              ),
              const SizedBox(height: 24),
              _FeeTable(
                title: 'Additional Fees',
                icon: Icons.add_card,
                records: controller.additionalFees,
                emptyMessage: 'No additional fee records for this year.',
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    StudentFeeController controller,
  ) async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: bytes,
        filename: 'Fee_Statement_${controller.studentName.value}_${controller.selectedYear.value}.pdf',
      );
    }
  }
}

// ─── Sub-Widgets (No logic changes, just layout support) ───

class _YearFilter extends StatelessWidget {
  final StudentFeeController controller;
  const _YearFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, size: 20),
            const SizedBox(width: 12),
            const Text('Year:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => DropdownButtonFormField<String>(
                  value: controller.selectedYear.value,
                  items: StudentFeeController.yearOptions
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.onYearChanged(v);
                  },
                  decoration: const InputDecoration(isDense: true),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(color: Colors.red.shade50, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(message, style: const TextStyle(color: Colors.red))));
  }
}

class _PendingFeeCard extends StatelessWidget {
  final StudentFeeController controller;
  const _PendingFeeCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.pendingFeeMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      final isNoPending = msg.toLowerCase().contains('no pending');
      return Card(
        color: isNoPending ? Colors.green.shade50 : Colors.red.shade50,
        child: ListTile(
          leading: Icon(isNoPending ? Icons.check_circle : Icons.warning, color: isNoPending ? Colors.green : Colors.red),
          title: const Text('Pending Status', style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(msg),
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final StudentFeeController controller;
  const _SummaryRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        _buildSummary('Regular', controller.totalRegularFees, Colors.blue),
        const SizedBox(width: 8),
        _buildSummary('Additional', controller.totalAdditionalFees, Colors.purple),
        const SizedBox(width: 8),
        _buildSummary('Total', controller.grandTotal, Colors.green),
      ],
    ));
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [Text(label, style: const TextStyle(fontSize: 12)), Text('Rs. ${amount.toStringAsFixed(0)}', style: TextStyle(fontWeight: FontWeight.bold, color: color))]),
        ),
      ),
    );
  }
}

class _FeeTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FeeRecord> records;
  final String emptyMessage;

  const _FeeTable({required this.title, required this.icon, required this.records, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(leading: Icon(icon), title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          if (records.isEmpty) Padding(padding: const EdgeInsets.all(20), child: Center(child: Text(emptyMessage)))
          else SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [DataColumn(label: Text('Month')), DataColumn(label: Text('Details')), DataColumn(label: Text('Amount')), DataColumn(label: Text('Date'))],
              rows: records.map((r) => DataRow(cells: [DataCell(Text(r.month)), DataCell(Text(r.details)), DataCell(Text('Rs. ${r.fee}')), DataCell(Text(r.feeDate))])).toList(),
            ),
          ),
        ],
      ),
    );
  }
} */
// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import 'package:school_management_system/controllers/student_fee_controller.dart';
import 'package:school_management_system/models/student_fee_models.dart';

class StudentFeeScreen extends StatelessWidget {
  const StudentFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StudentFeeController>();
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Fee'),
        centerTitle: true,
        actions: [
          Obx(
            () => IconButton(
              icon: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: controller.isLoading.value
                  ? null
                  : controller.fetchAllFeeData,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => _exportPdf(context, controller),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.regularFees.isEmpty &&
            controller.additionalFees.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Center(
          child: Container(
            // Limits width on large screens for better readability
            constraints: const BoxConstraints(maxWidth: 1200),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 24 : 16,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _YearFilter(controller: controller),
                  const SizedBox(height: 16),
                  if (controller.errorMessage.value.isNotEmpty)
                    _ErrorBanner(message: controller.errorMessage.value),
                  _PendingFeeCard(controller: controller),
                  const SizedBox(height: 16),
                  _SummaryRow(controller: controller),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Regular Fees',
                    icon: Icons.receipt_long,
                    records: controller.regularFees,
                    emptyMessage: 'No regular fee records for this year.',
                  ),
                  const SizedBox(height: 24),
                  _FeeTable(
                    title: 'Additional Fees',
                    icon: Icons.add_card,
                    records: controller.additionalFees,
                    emptyMessage: 'No additional fee records for this year.',
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Future<void> _exportPdf(
    BuildContext context,
    StudentFeeController controller,
  ) async {
    final bytes = await controller.generatePdf();
    if (bytes != null) {
      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'Fee_Statement_${controller.studentName.value}_${controller.selectedYear.value}.pdf',
      );
    }
  }
}

// ─── Sub-Widgets (Responsive Adjustments) ───

class _YearFilter extends StatelessWidget {
  final StudentFeeController controller;
  const _YearFilter({required this.controller});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(Icons.calendar_today, size: 20),
              const SizedBox(width: 12),
              const Text('Year:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              // Constraining the dropdown width on very wide screens
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: controller.selectedYear.value,
                        isExpanded: true,
                        items: StudentFeeController.yearOptions
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text(y)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) controller.onYearChanged(v);
                        },
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});
  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.red.shade50,
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(message, style: const TextStyle(color: Colors.red))));
  }
}

class _PendingFeeCard extends StatelessWidget {
  final StudentFeeController controller;
  const _PendingFeeCard({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final msg = controller.pendingFeeMessage.value;
      if (msg.isEmpty) return const SizedBox.shrink();
      final isNoPending = msg.toLowerCase().contains('no pending');
      return Card(
        color: isNoPending ? Colors.green.shade50 : Colors.red.shade50,
        child: ListTile(
          leading: Icon(isNoPending ? Icons.check_circle : Icons.warning,
              color: isNoPending ? Colors.green : Colors.red),
          title: const Text('Pending Status',
              style: TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(msg),
        ),
      );
    });
  }
}

class _SummaryRow extends StatelessWidget {
  final StudentFeeController controller;
  const _SummaryRow({required this.controller});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Determine if we should wrap or stay in a row based on width
      double spacing = constraints.maxWidth > 600 ? 16 : 8;

      return Obx(() => Row(
            children: [
              _buildSummary('Regular', controller.totalRegularFees, Colors.blue),
              SizedBox(width: spacing),
              _buildSummary(
                  'Additional', controller.totalAdditionalFees, Colors.purple),
              SizedBox(width: spacing),
              _buildSummary('Total', controller.grandTotal, Colors.green),
            ],
          ));
    });
  }

  Widget _buildSummary(String label, double amount, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Rs. ${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: color, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeeTable extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<FeeRecord> records;
  final String emptyMessage;

  const _FeeTable(
      {required this.title,
      required this.icon,
      required this.records,
      required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            tileColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.white10
                : Colors.grey.shade50,
          ),
          if (records.isEmpty)
            Padding(
                padding: const EdgeInsets.all(32),
                child: Center(child: Text(emptyMessage)))
          else
            LayoutBuilder(builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ConstrainedBox(
                  // Ensures table is at least the width of the card on large screens
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    columnSpacing: constraints.maxWidth > 600 ? 40 : 20,
                    headingTextStyle:
                        const TextStyle(fontWeight: FontWeight.bold),
                    columns: const [
                      DataColumn(label: Text('Month')),
                      DataColumn(label: Text('Details')),
                      DataColumn(label: Text('Amount')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: records
                        .map((r) => DataRow(cells: [
                              DataCell(Text(r.month)),
                              DataCell(Text(r.details)),
                              DataCell(Text('Rs. ${r.fee}')),
                              DataCell(Text(r.feeDate)),
                            ]))
                        .toList(),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}