import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/location_search_modal.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationService = ref.watch(locationServiceProvider);
    final notificationService = ref.watch(notificationServiceProvider);
    final prayerRepository = ref.watch(prayerRepositoryProvider);
    final location = locationService.getSavedOrDefaultLocation();
    final notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Settings',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 34,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
        backgroundColor: AppColors.secondaryBackground,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          children: [
            SettingsSection(
              title: 'LOCATION',
              children: [
                SettingsTile(
                  icon: CupertinoIcons.location_fill,
                  title: 'Current Location',
                  subtitle: location.name,
                  onTap: () {
                    _showLocationInfo(context, location);
                  },
                ),
                SettingsTile(
                  icon: CupertinoIcons.search,
                  title: 'Change Location',
                  subtitle: 'Search for your city',
                  onTap: () async {
                    final result = await Navigator.of(context).push<Map<String, dynamic>>(
                      CupertinoPageRoute(
                        builder: (context) => const LocationSearchModal(),
                      ),
                    );

                    if (result != null && context.mounted) {
                      // Update location
                      await locationService.updateLocation(
                        latitude: result['latitude'] as double,
                        longitude: result['longitude'] as double,
                        name: result['name'] as String,
                      );

                      // Refresh UI
                      ref.invalidate(locationServiceProvider);

                      // Show success message
                      if (context.mounted) {
                        _showAlert(
                          context,
                          'Location Updated',
                          'Prayer times will be recalculated for ${result['name']}',
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'NOTIFICATIONS',
              children: [
                SettingsTile(
                  icon: CupertinoIcons.bell_fill,
                  title: 'Prayer Reminders',
                  subtitle: notificationsEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  trailing: CupertinoSwitch(
                    value: notificationsEnabled,
                    onChanged: (value) async {
                      final toggle = ref.read(toggleNotificationsProvider);
                      await toggle(value);
                    },
                  ),
                ),
                SettingsTile(
                  icon: CupertinoIcons.chat_bubble_fill,
                  title: 'Test Notification',
                  subtitle: 'Send a test notification',
                  onTap: () async {
                    await notificationService.sendTestNotification();
                    if (context.mounted) {
                      _showAlert(
                        context,
                        'Test Sent',
                        'Check your notification center for the test notification.',
                      );
                    }
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'PRAYER CALCULATION',
              children: [
                SettingsTile(
                  icon: CupertinoIcons.compass_fill,
                  title: 'Calculation Method',
                  subtitle: 'Muslim World League',
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.textTertiary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Coming Soon',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SettingsSection(
              title: 'DATA MANAGEMENT',
              children: [
                SettingsTile(
                  icon: CupertinoIcons.square_arrow_up,
                  title: 'Export Data',
                  subtitle: 'Export prayer logs as JSON',
                  onTap: () {
                    _showExportDialog(context, prayerRepository);
                  },
                ),
                SettingsTile(
                  icon: CupertinoIcons.trash,
                  title: 'Clear All Data',
                  subtitle: 'Delete all prayer logs',
                  titleColor: AppColors.error,
                  onTap: () {
                    _showClearDataDialog(context, prayerRepository);
                  },
                ),
              ],
            ),
            SettingsSection(
              title: 'ABOUT',
              children: [
                const SettingsTile(
                  icon: CupertinoIcons.info_circle_fill,
                  title: 'App Version',
                  subtitle: AppConstants.appVersion,
                ),
                SettingsTile(
                  icon: CupertinoIcons.heart_fill,
                  title: 'About',
                  subtitle: 'Islamic Prayer Tracker',
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLocationInfo(BuildContext context, dynamic location) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Location Details'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text('Location: ${location.name}'),
            const SizedBox(height: 8),
            Text('Latitude: ${location.latitude.toStringAsFixed(4)}'),
            Text('Longitude: ${location.longitude.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, dynamic repository) {
    final data = repository.exportData();

    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Export Data'),
        content: Column(
          children: [
            const SizedBox(height: 12),
            Text('Total logs: ${data['totalLogs']}'),
            const SizedBox(height: 8),
            const Text(
              'Data has been generated. In a production app, this would be saved to a file.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog(BuildContext context, dynamic repository) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all prayer logs? This action cannot be undone.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              await repository.clearAllData();
              if (context.mounted) {
                Navigator.pop(context);
                _showAlert(
                  context,
                  'Data Cleared',
                  'All prayer logs have been deleted.',
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('About Salah Tracker'),
        content: const Column(
          children: [
            SizedBox(height: 12),
            Text(
              'Salah Tracker helps Muslims track their daily prayers and maintain consistency in worship.',
            ),
            SizedBox(height: 12),
            Text(
              'Features:\n• Automatic prayer time calculation\n• Quick logging from notifications\n• Monthly statistics\n• Beautiful Cupertino UI',
              style: TextStyle(fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              'Developed by NeyoZyn',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'May Allah accept all our prayers.',
              style: TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showAlert(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
