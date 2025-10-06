import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/colors.dart';
import '../providers/home_providers.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/today_prayers_list.dart';
import '../widgets/monthly_stats_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.background,
      navigationBar: const CupertinoNavigationBar(
        backgroundColor: AppColors.secondaryBackground,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            NextPrayerCard(),
            SizedBox(height: 24),
            TodayPrayersList(),
            SizedBox(height: 24),
            MonthlyStatsCard(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
