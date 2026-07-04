import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final faqs = [
      {'question': 'How do I add a property?', 'answer': 'Go to the Properties tab, tap the + button, and fill in the property details.'},
      {'question': 'How do I record a payment?', 'answer': 'Open a tenant profile, select Payments, then tap Record Payment.'},
      {'question': 'How does the free trial work?', 'answer': 'New landlords get 3 days of full access. Activate it from the Subscription page.'},
      {'question': 'What happens when my subscription expires?', 'answer': 'Your account will be limited until you renew or choose a new plan.'},
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        elevation: 0,
        title: Text('Help & Support', style: GoogleFonts.nunito(fontWeight: FontWeight.w700)),
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
                  Text('Need help?', style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('Contact our support team and we will get back to you within 24 hours.', style: GoogleFonts.nunito(fontSize: 14, color: Colors.white70)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildContactCard(context, icon: Icons.phone, title: 'Call Us', value: '+255 700 000 000'),
            const SizedBox(height: 12),
            _buildContactCard(context, icon: Icons.email, title: 'Email Us', value: 'support@mannaapartment.co.tz'),
            const SizedBox(height: 12),
            _buildContactCard(context, icon: Icons.chat_bubble, title: 'WhatsApp', value: '+255 700 000 000'),
            const SizedBox(height: 32),
            Text('Frequently Asked Questions', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(question, style: GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textDark)),
        iconColor: AppColors.primary,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(answer, style: GoogleFonts.nunito(fontSize: 13, color: isDark ? Colors.white70 : AppColors.textLight)),
          ),
        ],
      ),
    );
  }
}
