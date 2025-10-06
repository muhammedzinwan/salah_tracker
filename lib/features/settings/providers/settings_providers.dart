import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/constants/app_constants.dart';

// Notifications enabled provider
final notificationsEnabledProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool(AppConstants.keyNotificationsEnabled) ?? true;
});

// Toggle notifications
final toggleNotificationsProvider = Provider<Future<void> Function(bool)>(
  (ref) {
    return (bool enabled) async {
      final notificationService = ref.read(notificationServiceProvider);
      await notificationService.setNotificationsEnabled(enabled);
      ref.read(notificationsEnabledProvider.notifier).state = enabled;
    };
  },
);
