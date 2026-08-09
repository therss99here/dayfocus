// ignore_for_file: deprecated_member_use_from_same_package
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../notifications/notification_service.dart';

part 'notification_providers.g.dart';

@Riverpod(keepAlive: true)
NotificationService notificationService(NotificationServiceRef ref) =>
    NotificationService();
