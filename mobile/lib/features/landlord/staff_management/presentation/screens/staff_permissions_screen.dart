import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../providers/staff_provider.dart';

class StaffPermissionsScreen extends ConsumerStatefulWidget {
  const StaffPermissionsScreen({super.key});
  @override
  ConsumerState<StaffPermissionsScreen> createState() => _StaffPermissionsScreenState();
}

class _StaffPermissionsScreenState extends ConsumerState<StaffPermissionsScreen> {
  final _permissions = <String, bool>{
    'view_properties': true,
    'manage_properties': false,
    'view_tenants': true,
    'manage_tenants': false,
    'view_payments': true,
    'record_payments': false,
    'view_contracts': true,
    'manage_contracts': false,
    'send_sms': false,
    'view_reports': true,
    'manage_staff': false,
  };
  bool _isLoading = false;

  Future<void> _save() async {
    final id = GoRouterState.of(context).pathParameters['id'] ?? '';
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(staffRepositoryProvider);
      final selected = _permissions.entries.where((e) => e.value).map((e) => e.key).toList();
      await repo.updatePermissions(id, selected);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permissions updated'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(title: const Text('Staff Permissions'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ..._permissions.keys.map((key) => Card(
            child: SwitchListTile(
              title: Text(
                key.split('_').map((w) => w[0].toUpperCase() + w.substring(1)).join(' '),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : AppColors.textDark),
              ),
              value: _permissions[key]!,
              onChanged: (v) => setState(() => _permissions[key] = v),
              activeColor: AppColors.primary,
            ),
          )),
          const SizedBox(height: 16),
          PrimaryButton(text: 'Save Permissions', isLoading: _isLoading, onPressed: _save),
        ],
      ),
    );
  }
}
