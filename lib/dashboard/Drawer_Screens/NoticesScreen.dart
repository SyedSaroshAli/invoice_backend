/* import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final noticeController = Get.find<NoticesController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notices"), centerTitle: true),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return Center(
            child: Text(
              "No notices yet",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: noticeController.refreshNotices,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: noticeController.notices.length,
            itemBuilder: (context, index) {
              final notice = noticeController.notices[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notice.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (notice.isNew == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                "NEW",
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        notice.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          "${notice.date.day.toString().padLeft(2, '0')}-"
                          "${notice.date.month.toString().padLeft(2, '0')}-"
                          "${notice.date.year}",
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withOpacity(0.5),
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_management_system/controllers/noticeController.dart';

class NoticesScreen extends StatelessWidget {
  NoticesScreen({super.key});

  final noticeController = Get.find<NoticesController>();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notices"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (noticeController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (noticeController.notices.isEmpty) {
          return Center(
            child: Text(
              "No notices yet",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
            ),
          );
        }

        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: RefreshIndicator(
              onRefresh: noticeController.refreshNotices,
              child: isTablet
                  ? _buildGridView(context, noticeController, screenWidth)
                  : _buildListView(context, noticeController),
            ),
          ),
        );
      }),
    );
  }

  // Mobile Layout
  Widget _buildListView(BuildContext context, NoticesController controller) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(16),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        // No fixed height here, Column will wrap content
        return _NoticeCard(notice: controller.notices[index], isGrid: false);
      },
    );
  }

  // Tablet/Web Layout
  Widget _buildGridView(BuildContext context, NoticesController controller, double width) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: width > 900 ? 3 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        mainAxisExtent: 220, // Strict height for grid cells
      ),
      itemCount: controller.notices.length,
      itemBuilder: (context, index) {
        return _NoticeCard(notice: controller.notices[index], isGrid: true);
      },
    );
  }
}

class _NoticeCard extends StatelessWidget {
  final dynamic notice;
  final bool isGrid;

  const _NoticeCard({required this.notice, required this.isGrid});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Essential for ListView
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    notice.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (notice.isNew == true) ...[
                  const SizedBox(width: 8),
                  _buildNewTag(context),
                ],
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notice.description,
              maxLines: isGrid ? 3 : 5, // Show more text on mobile list
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 16),
            // Replacing Spacer with a simple Row for the date to avoid unbounded height errors
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  "${notice.date.day.toString().padLeft(2, '0')}-"
                  "${notice.date.month.toString().padLeft(2, '0')}-"
                  "${notice.date.year}",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewTag(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Text(
        "NEW",
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}