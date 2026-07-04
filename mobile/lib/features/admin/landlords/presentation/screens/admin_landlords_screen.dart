import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../../../../core/widgets/error_state.dart';
import '../../../../../core/widgets/loading_indicator.dart';
import '../../providers/admin_landlords_provider.dart';

class AdminLandlordsScreen extends ConsumerStatefulWidget {
  const AdminLandlordsScreen({super.key});

  @override
  ConsumerState<AdminLandlordsScreen> createState() => _AdminLandlordsScreenState();
}

class _AdminLandlordsScreenState extends ConsumerState<AdminLandlordsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final landlordsAsync = ref.watch(adminLandlordsProvider((status: _filterStatus, search: _searchQuery)));

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Manage Landlords', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context, isDark),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search landlords...',
                hintStyle: GoogleFonts.nunito(fontSize: 14),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('All', 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Active', 'active'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Suspended', 'suspended'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Deactivated', 'deactivated'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => ref.invalidate(adminLandlordsProvider),
              color: AppColors.primary,
              child: landlordsAsync.when(
                loading: () => const LoadingIndicator(),
                error: (e, _) => ErrorState(message: e.toString(), onRetry: () => ref.invalidate(adminLandlordsProvider)),
                data: (landlords) {
                  if (landlords.isEmpty) {
                    return const EmptyState(message: 'No landlords found.');
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: landlords.length,
                    itemBuilder: (context, index) => _LandlordCard(landlord: landlords[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/admin/landlords/create'),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Owner'),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Admin Panel', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 20),
            _buildDrawerItem(context, Icons.people, 'Landlords', '/admin/landlords'),
            _buildDrawerItem(context, Icons.assessment, 'Analytics', '/admin/analytics'),
            _buildDrawerItem(context, Icons.attach_money, 'Revenue', '/admin/revenue'),
            _buildDrawerItem(context, Icons.verified_user, 'KYC Review', '/admin/kyc'),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Logout', style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: AppColors.error)),
              onTap: () => context.go('/auth/login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, String route) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(icon, color: selected ? AppColors.primary : (isDark ? Colors.white60 : AppColors.textLight)),
      title: Text(title, style: GoogleFonts.nunito(fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
      tileColor: selected ? AppColors.primary.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: () {
        Navigator.pop(context);
        if (!selected) context.push(route);
      },
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterStatus == value;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
      label: Text(label, style: GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : (isDark ? Colors.white70 : AppColors.textLight))),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => setState(() => _filterStatus = value),
    );
  }
}

class _LandlordCard extends StatelessWidget {
  final Map<String, dynamic> landlord;
  const _LandlordCard({required this.landlord});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = (landlord['status'] ?? 'active').toString();
    final kycStatus = (landlord['kyc_status'] ?? 'pending').toString();
    final Color statusColor = {
      'active': AppColors.success,
      'suspended': AppColors.warning,
      'deactivated': Colors.grey,
    }[status] ?? AppColors.info;
    final owner = landlord['owner'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => context.push('/admin/landlords/${landlord['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      landlord['business_name'] ?? 'Organization',
                      style: GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textDark),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(status.toUpperCase(), style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Owner: ${owner?['full_name'] ?? 'N/A'}', style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight)),
              Text('Phone: ${owner?['phone'] ?? 'N/A'}', style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildBadge('KYC: ${kycStatus.toUpperCase()}', kycStatus == 'approved' ? AppColors.success : AppColors.warning),
                  const SizedBox(width: 8),
                  _buildBadge('SMS: ${landlord['sms_balance'] ?? 0}', AppColors.primary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: GoogleFonts.nunito(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }
}
