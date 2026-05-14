import 'package:flutter/material.dart';
import 'package:service_provider_app/core/theme/qs_color_extension.dart';
import 'package:provider/provider.dart';
import '../viewmodels/notification_viewmodel.dart';
import '../models/notification_model.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/app_localizations.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // جلب الإشعارات عند فتح الصفحة
    Future.microtask(() {
      context.read<NotificationViewModel>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.qsColors.background,
      appBar: AppBar(
        backgroundColor: context.qsColors.card,
        elevation: 0,
        title: Text(
          context.tr('notifications_title'),
          style: TextStyle(
              color: context.qsColors.text, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.qsColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<NotificationViewModel>().markAllAsRead();
            },
            icon: Icon(Icons.done_all, color: context.qsColors.primary),
            tooltip: context.tr('mark_all_as_read'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              final unreadCount = viewModel.unreadCount;
              final readCount = viewModel.notifications.length - unreadCount;

              return Container(
                color: context.qsColors.card,
                child: TabBar(
                  controller: _tabController,
                  labelColor: context.qsColors.primary,
                  unselectedLabelColor: context.qsColors.textSub,
                  indicatorColor: context.qsColors.primary,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500, fontSize: 14),
                  tabs: [
                    Tab(text: 'الكل (${viewModel.notifications.length})'),
                    Tab(text: 'غير مقروءة ($unreadCount)'),
                    Tab(text: 'مقروءة ($readCount)'),
                  ],
                ),
              );
            },
          ),
        ),
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
                child: CircularProgressIndicator(
                    color: context.qsColors.primary));
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewModel.errorMessage!,
                    style: TextStyle(color: context.qsColors.error),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.qsColors.primary,
                      foregroundColor: context.qsColors.card,
                    ),
                    onPressed: () => viewModel.fetchNotifications(),
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            );
          }

          final allNotifications = viewModel.notifications;
          final unreadNotifications =
              allNotifications.where((n) => !n.isRead).toList();
          final readNotifications =
              allNotifications.where((n) => n.isRead).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              // تبويب: الكل
              _buildNotificationList(allNotifications, context.tr('auto_tr_65')),
              // تبويب: غير مقروءة
              _buildNotificationList(
                  unreadNotifications, context.tr('auto_tr_67')),
              // تبويب: مقروءة
              _buildNotificationList(
                  readNotifications, context.tr('auto_tr_39')),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotificationList(
      List<NotificationModel> notifications, String emptyMessage) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: context.qsColors.textSub),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style:
                  TextStyle(color: context.qsColors.textSub, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.qsColors.primary,
      onRefresh: () =>
          context.read<NotificationViewModel>().fetchNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationItem(notification: notification);
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notification;

  const _NotificationItem({required this.notification});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<NotificationViewModel>();

    return InkWell(
      onTap: () {
        if (!notification.isRead) {
          viewModel.markAsRead(notification.id);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead
              ? context.qsColors.card
              : context.qsColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: notification.isRead
                ? context.qsColors.textSub.withOpacity(0.1)
                : context.qsColors.primary.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: context.qsColors.text.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context, notification.type),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.bold,
                            fontSize: 16,
                            color: context.qsColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: context.qsColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(
                      color: context.qsColors.textSub,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm')
                        .format(notification.createdAt),
                    style: TextStyle(
                      color: context.qsColors.textSub.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, String type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'new_request':
        iconData = Icons.add_shopping_cart;
        iconColor = context.qsColors.success;
        break;
      case 'request_accepted':
        iconData = Icons.check_circle_outline;
        iconColor = context.qsColors.info;
        break;
      case 'points_received':
        iconData = Icons.stars;
        iconColor = context.qsColors.warning;
        break;
      case 'complaint_update':
        iconData = Icons.report_problem_outlined;
        iconColor = context.qsColors.error;
        break;
      default:
        iconData = Icons.notifications_none;
        iconColor = context.qsColors.primary;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(iconData, color: iconColor, size: 22),
    );
  }
}
