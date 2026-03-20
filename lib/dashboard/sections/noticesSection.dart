/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/NoticesScreen.dart';

class NoticesSection extends StatelessWidget {
  const NoticesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final NoticesController noticesController = Get.find<NoticesController>();

    // Icon/color mapping for visual variety
    final List<Map<String, dynamic>> iconStyles = [
      {'icon': LucideIcons.calendar, 'color': const Color(0xFFEF4444)},
      {'icon': LucideIcons.banknote, 'color': const Color(0xFFF59E0B)},
      {'icon': LucideIcons.award, 'color': const Color(0xFF3B82F6)},
      {'icon': LucideIcons.users, 'color': const Color(0xFF10B981)},
      {'icon': LucideIcons.bell, 'color': const Color(0xFF8B5CF6)},
      {'icon': LucideIcons.bookOpen, 'color': const Color(0xFFEC4899)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notices',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticesScreen()),
                );
              }, child: const Text('View All')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 90,
          child: Obx(() {
            if (noticesController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (noticesController.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  noticesController.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              );
            }

            if (noticesController.notices.isEmpty) {
              return Center(
                child: Text(
                  'No notices available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: noticesController.notices.length > 3
                  ? 3
                  : noticesController.notices.length,
              itemBuilder: (context, index) {
                final notice = noticesController.notices[index];
                final style = iconStyles[index % iconStyles.length];
                final dateStr =
                    '${_monthName(notice.date.month)} ${notice.date.day}';

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 260,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                // ignore: deprecated_member_use
                                color: (style['color'] as Color).withOpacity(
                                  0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                style['icon'] as IconData,
                                color: style['color'] as Color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    notice.title.isNotEmpty
                                        ? notice.title
                                        : notice.description,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dateStr,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m - 1];
  }
}*/ 

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:school_management_system/controllers/noticeController.dart';
import 'package:school_management_system/dashboard/Drawer_Screens/NoticesScreen.dart';
import 'package:school_management_system/models/noticesModel.dart';

class NoticesSection extends StatelessWidget {
  const NoticesSection({super.key});

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Highlights notices from today's date only.
  /// If no notices exist for today, nothing is highlighted.
  bool _shouldHighlight(NoticeModel notice) {
    final now = DateTime.now();
    return notice.date.year == now.year &&
        notice.date.month == now.month &&
        notice.date.day == now.day;
  }

  /// Opens a modal bottom-sheet / dialog with the full notice details.
  void _showNoticeDialog(BuildContext context, NoticeModel notice) {
    showDialog(
      context: context,
      barrierDismissible: true, // tap outside to close
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding:
            const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ───────────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title.isNotEmpty
                          ? notice.title
                          : 'Notice',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ── Date chip ────────────────────────────────────────────────
              Row(
                children: [
                  Icon(
                    LucideIcons.calendar,
                    size: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_monthName(notice.date.month)} ${notice.date.day}, ${notice.date.year}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.5),
                        ),
                  ),
                ],
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Divider(height: 1),
              ),

              // ── Description ──────────────────────────────────────────────
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    notice.description.isNotEmpty
                        ? notice.description
                        : 'No description available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.55,
                        ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Close button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final NoticesController noticesController = Get.find<NoticesController>();

    // Icon/color mapping for visual variety
    final List<Map<String, dynamic>> iconStyles = [
      {'icon': LucideIcons.calendar, 'color': const Color(0xFFEF4444)},
      {'icon': LucideIcons.banknote, 'color': const Color(0xFFF59E0B)},
      {'icon': LucideIcons.award, 'color': const Color(0xFF3B82F6)},
      {'icon': LucideIcons.users, 'color': const Color(0xFF10B981)},
      {'icon': LucideIcons.bell, 'color': const Color(0xFF8B5CF6)},
      {'icon': LucideIcons.bookOpen, 'color': const Color(0xFFEC4899)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notices',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NoticesScreen()),
                  );
                },
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100, // slightly taller to accommodate the highlight badge
          child: Obx(() {
            if (noticesController.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (noticesController.errorMessage.isNotEmpty) {
              return Center(
                child: Text(
                  noticesController.errorMessage.value,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              );
            }

            if (noticesController.notices.isEmpty) {
              return Center(
                child: Text(
                  'No notices available',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              );
            }

            final notices = noticesController.notices;
            final displayCount =
                notices.length > 3 ? 3 : notices.length;

            return ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: displayCount,
              itemBuilder: (context, index) {
                final notice = notices[index];
                final style = iconStyles[index % iconStyles.length];
                final dateStr =
                    '${_monthName(notice.date.month)} ${notice.date.day}';
                final highlight = _shouldHighlight(notice);
                final accentColor = style['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: SizedBox(
                    width: 270,
                    child: GestureDetector(
                      onTap: () => _showNoticeDialog(context, notice),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        decoration: BoxDecoration(
                          // Highlighted notices get a tinted background + border
                          color: highlight
                              ? accentColor.withOpacity(0.07)
                              : Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: highlight
                                ? accentColor.withOpacity(0.55)
                                : Theme.of(context)
                                    .dividerColor
                                    .withOpacity(0.3),
                            width: highlight ? 1.6 : 1,
                          ),
                          boxShadow: highlight
                              ? [
                                  BoxShadow(
                                    color: accentColor.withOpacity(0.15),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  )
                                ]
                              : [],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              // ── Icon bubble ──────────────────────────────
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  style['icon'] as IconData,
                                  color: accentColor,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),

                              // ── Text column ──────────────────────────────
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    // "NEW" badge only on highlighted notices
                                    if (highlight)
                                      Container(
                                        margin: const EdgeInsets.only(
                                            bottom: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: const Text(
                                          'NEW',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ),
                                    Text(
                                      notice.title.isNotEmpty
                                          ? notice.title
                                          : notice.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: highlight
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            color: highlight
                                                ? accentColor
                                                : null,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      dateStr,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: highlight
                                                ? accentColor
                                                    .withOpacity(0.75)
                                                : null,
                                            fontWeight: highlight
                                                ? FontWeight.w500
                                                : null,
                                          ),
                                    ),
                                  ],
                                ),
                              ),

                              // ── Tap hint chevron ─────────────────────────
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return names[m - 1];
  }
}
