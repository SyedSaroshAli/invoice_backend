import 'package:flutter/material.dart';
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
}
