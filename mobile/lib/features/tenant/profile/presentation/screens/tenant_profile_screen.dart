import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../features/auth/providers/auth_provider.dart';

class TenantProfileScreen extends ConsumerWidget {
  const TenantProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Profile'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Center(child: Text(user?.fullName.substring(0, 1).toUpperCase() ?? 'T', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.fullName ?? 'Tenant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
                        Text(user?.phone ?? '', style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(leading: const Icon(Icons.lock_outline), title: const Text('Change Password'), trailing: const Icon(Icons.arrow_forward_ios, size: 16), onTap: () => context.push('/tenant/profile/change-password')),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.notifications_outlined), title: const Text('Notifications'), trailing: const Icon(Icons.arrow_forward_ios, size: 16)),
                const Divider(height: 1),
                ListTile(leading: const Icon(Icons.logout, color: AppColors.error), title: const Text('Logout', style: TextStyle(color: AppColors.error)), onTap: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/auth/login');
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
