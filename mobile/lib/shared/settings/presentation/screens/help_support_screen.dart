import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/localization/app_localizations.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {'question': context.tr('faq_q1'), 'answer': context.tr('faq_a1')},
      {'question': context.tr('faq_q2'), 'answer': context.tr('faq_a2')},
      {'question': context.tr('faq_q3'), 'answer': context.tr('faq_a3')},
      {'question': context.tr('faq_q4'), 'answer': context.tr('faq_a4')},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text(context.tr('help_support'), style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('need_help'), style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(context.tr('contact_support'), style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildContactCard(context, icon: Icons.phone, title: context.tr('call_us'), value: '0734070202'),
            const SizedBox(height: 12),
            _buildContactCard(context, icon: Icons.email, title: context.tr('email_us'), value: 'support@mannaapartment.co.tz'),
            const SizedBox(height: 12),
            _buildContactCard(context, icon: Icons.chat_bubble, title: context.tr('whatsapp'), value: '0734070202'),
            const SizedBox(height: 32),
            Text(context.tr('faq'), style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
            const SizedBox(height: 12),
            ...faqs.map((faq) => _buildFaqItem(context, faq['question']!, faq['answer']!)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(BuildContext context, {required IconData icon, required String title, required String value}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.nunito(fontSize: 12, color: isDark ? Colors.white60 : AppColors.textLight)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: tileColor,
        borderRadius: BorderRadius.circular(12),
        child: ExpansionTile(
          shape: const Border(),
          collapsedShape: const Border(),
          backgroundColor: tileColor,
          collapsedBackgroundColor: tileColor,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(question, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
          iconColor: AppColors.primary,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(answer, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight)),
            ),
          ],
        ),
      ),
    );
  }
}
