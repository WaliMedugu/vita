import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScreen(
      title: 'Privacy Policy',
      lastUpdated: 'Last updated: June 1, 2026',
      sections: const [
        _LegalSection('1. Information We Collect',
          'VITA collects information you provide directly, including your name, email address, phone number, and health information (blood type, allergies, medical conditions, and emergency contacts). This health information is stored securely and used exclusively to power emergency response features.'),
        _LegalSection('2. How We Use Your Information',
          'Your health data is stored on your NFC VitaCard sticker and our secure servers. In an emergency, this data may be shared with bystanders, emergency contacts, and healthcare providers. Financial data related to VitaPool contributions and releases is processed through OPay\'s secure payment infrastructure.'),
        _LegalSection('3. Data Sharing',
          'We do not sell your personal data to third parties. Emergency data (health profile, GPS location) is shared only with your designated emergency contacts and, where applicable, healthcare providers during an active emergency. Pool financial data is visible to pool members and admins.'),
        _LegalSection('4. Health Data (NDPR Compliance)',
          'As a Nigerian data processor, VITA complies with the Nigeria Data Protection Regulation (NDPR). Your health data is classified as sensitive personal data. You have the right to access, correct, and delete your health information at any time. Deletion requests will be processed within 72 hours.'),
        _LegalSection('5. NFC & Offline Access',
          'Your health profile is encoded to an NFC chip you own and control. Once encoded, the data exists on the physical sticker. Deleting your VITA account does not automatically erase NFC chip data — you must physically destroy or rewrite the chip.'),
        _LegalSection('6. Data Retention',
          'Active account data is retained for the duration of your membership. Emergency event records are retained for 7 years for financial compliance. You may request export of all your data at any time by contacting support@vita.ng.'),
        _LegalSection('7. Security',
          'All data is encrypted in transit (TLS 1.3) and at rest (AES-256). Financial transactions are processed by OPay and are subject to CBN regulations. We conduct quarterly security audits and penetration testing.'),
        _LegalSection('8. Contact',
          'For privacy-related inquiries:\nData Protection Officer\nVITA Health Technologies Ltd\nKano, Nigeria\nprivacy@vita.ng\n+234 800 VITA 001'),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return _LegalScreen(
      title: 'Terms of Service',
      lastUpdated: 'Effective: June 1, 2026',
      sections: const [
        _LegalSection('1. Service Description',
          'VITA is a community health emergency pooling platform. By using VITA, you agree to participate in a mutual aid community where small contributions from members collectively fund emergency healthcare costs for any member in need.'),
        _LegalSection('2. VitaPool Contributions',
          'By joining a VitaPool, you authorize VITA (via OPay) to debit your account according to your selected contribution mode (Passive Sweep of ₦100 per OPay transaction, or Scheduled Deposits). Contributions are non-refundable once processed.'),
        _LegalSection('3. Emergency Fund Release',
          'Pool funds may be released in genuine medical emergencies. An emergency is defined as a situation requiring immediate medical intervention. False emergency activations are prohibited and may result in account suspension and recovery of disbursed funds.'),
        _LegalSection('4. Pool Reserve Floor',
          'Each pool maintains a protected reserve floor (minimum ₦3,000) that cannot be disbursed. This ensures operational continuity. The floor amount may be adjusted by pool admins via the 30-minute objection window process.'),
        _LegalSection('5. NFC VitaCard',
          'The ₦300 NFC sticker is a one-time purchase. VITA grants you a license to use the VITA platform software. The NFC sticker is a physical product that remains your property. VITA is not responsible for lost, stolen, or damaged VitaCards.'),
        _LegalSection('6. Health Data Accuracy',
          'You are responsible for ensuring your health profile information is accurate and up to date. VITA and bystanders using your VitaCard during an emergency rely on this information to provide appropriate assistance. Inaccurate data may result in improper care.'),
        _LegalSection('7. Gemini AI First Aid',
          'First aid guidance generated by Gemini AI is provided for informational purposes only. It does not constitute medical advice. Always seek professional medical assistance in an emergency. VITA is not liable for outcomes resulting from following AI-generated guidance.'),
        _LegalSection('8. Limitation of Liability',
          'VITA\'s maximum liability to you for any claim arising from use of the platform is limited to the total contributions you have made in the 12 months preceding the claim. VITA is not liable for indirect, consequential, or punitive damages.'),
        _LegalSection('9. Governing Law',
          'These terms are governed by the laws of the Federal Republic of Nigeria. Disputes shall be resolved through arbitration in Kano, Nigeria under the Arbitration and Conciliation Act.'),
      ],
    );
  }
}

class _LegalScreen extends StatelessWidget {
  const _LegalScreen({required this.title, required this.lastUpdated, required this.sections});
  final String title;
  final String lastUpdated;
  final List<_LegalSection> sections;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: VitaColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Row(children: [
                        Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.6), size: 20),
                        const SizedBox(width: 8),
                        Text(title, style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700)),
                      ]),
                    ),
                    const SizedBox(height: 8),
                    Text(lastUpdated, style: VitaText.mono(11, color: Colors.white.withValues(alpha: 0.4))),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sections.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.title, style: VitaText.display(15, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.3)),
                        const SizedBox(height: 8),
                        Text(s.body, style: VitaText.body(13.5, color: VitaColors.gray).copyWith(height: 1.7)),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection(this.title, this.body);
  final String title;
  final String body;
}
