import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';
import 'package:vita/widgets/vita_tag_chip.dart';

class EditHealthScreen extends StatefulWidget {
  const EditHealthScreen({super.key});

  @override
  State<EditHealthScreen> createState() => _EditHealthScreenState();
}

class _EditHealthScreenState extends State<EditHealthScreen> {
  String _bloodType = 'O+ (Positive)';
  List<String> _conditions = ['Asthma', 'Hypertension'];
  List<String> _allergies = ['Penicillin', 'Peanuts'];

  final _bloodTypes = ['O+ (Positive)', 'O−', 'A+', 'A−', 'B+', 'AB+'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: VitaColors.dark,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Icon(Icons.arrow_back, color: Colors.white.withValues(alpha: 0.6), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Text('Edit Profile', style: VitaText.display(17, color: Colors.white, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Blood Type'),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: _bloodType,
                      items: _bloodTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _bloodType = v!),
                      style: VitaText.body(14, weight: FontWeight.w500),
                      decoration: _inputDec(),
                    ),
                    const SizedBox(height: 14),
                    _sectionLabel('Conditions'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: _conditions.map((c) => VitaTagChip(
                        label: c,
                        onRemove: () => setState(() => _conditions.remove(c)),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: VitaText.body(14, weight: FontWeight.w500),
                      decoration: _inputDec(hint: 'Add a condition...'),
                      onSubmitted: (v) {
                        if (v.isNotEmpty) setState(() => _conditions.add(v));
                      },
                    ),
                    const SizedBox(height: 14),
                    _sectionLabel('Allergies'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: _allergies.map((a) => VitaTagChip(
                        label: a,
                        isDanger: true,
                        onRemove: () => setState(() => _allergies.remove(a)),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      style: VitaText.body(14, weight: FontWeight.w500),
                      decoration: _inputDec(hint: 'Add an allergen...'),
                      onSubmitted: (v) {
                        if (v.isNotEmpty) setState(() => _allergies.add(v));
                      },
                    ),
                    const SizedBox(height: 14),
                    _formField('Primary Contact Name', 'Fatima Medugu'),
                    const SizedBox(height: 14),
                    _formField('Primary Contact Phone', '+234 800 123 4567'),
                    const SizedBox(height: 14),
                    _formField('Secondary Contact', 'Dr. Nubwa Medugu'),
                    const SizedBox(height: 14),
                    _formField('VitaPool ID', 'POOL-KAN-0041'),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.pop(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Save Changes', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) => Text(
    label.toUpperCase(),
    style: VitaText.mono(11.5, color: VitaColors.dark, weight: FontWeight.w600).copyWith(letterSpacing: 0.8),
  );

  Widget _formField(String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel(label),
        const SizedBox(height: 5),
        TextFormField(
          initialValue: initialValue,
          style: VitaText.body(14, weight: FontWeight.w500),
          decoration: _inputDec(),
        ),
      ],
    );
  }

  InputDecoration _inputDec({String? hint}) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: const Color(0xFFF2F2F0),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.transparent, width: 1.5)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: VitaColors.teal, width: 1.5)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    hintStyle: VitaText.body(14, color: const Color(0xFFB0B0AE)),
  );
}
