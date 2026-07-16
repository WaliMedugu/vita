import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class HospitalFinderScreen extends StatefulWidget {
  const HospitalFinderScreen({super.key});

  @override
  State<HospitalFinderScreen> createState() => _HospitalFinderScreenState();
}

class _HospitalFinderScreenState extends State<HospitalFinderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _liveDotCtrl;
  late Animation<double> _liveDotAnim;

  @override
  void initState() {
    super.initState();
    _liveDotCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _liveDotAnim = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _liveDotCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _liveDotCtrl.dispose(); super.dispose(); }

  static const _hospitals = [
    _Hospital(rank: '1', name: 'National Hospital Abuja', addr: 'Plot 132 Central Business District, Abuja', open: true, dist: '1.2 km'),
    _Hospital(rank: '2', name: 'Maitama District Hospital', addr: 'Maitama District, Abuja FCT', open: true, dist: '2.7 km'),
    _Hospital(rank: '3', name: 'Garki General Hospital', addr: 'Area 1, Garki District, Abuja', open: false, dist: '3.4 km'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildMap()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('3 HOSPITALS FOUND NEARBY', style: VitaText.mono(12, color: VitaColors.gray).copyWith(letterSpacing: 0)),
                    const SizedBox(height: 12),
                    ..._hospitals.map((h) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HospitalCard(hospital: h),
                    )),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => context.push('/emergency/receipt'),
                        style: ElevatedButton.styleFrom(backgroundColor: VitaColors.red, padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos_rounded, size: 20),
                            const SizedBox(width: 8),
                            Text('Still need help? Re-alert', style: VitaText.display(15, color: Colors.white, weight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: VitaColors.red,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nearby Hospitals', style: VitaText.display(18, color: Colors.white, weight: FontWeight.w700).copyWith(letterSpacing: -0.4)),
              const SizedBox(height: 1),
              Text('Emergency active · Abuja, FCT', style: VitaText.body(11.5, color: Colors.white.withValues(alpha: 0.6))),
            ],
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _liveDotAnim,
            builder: (_, __) => Opacity(
              opacity: _liveDotAnim.value,
              child: Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF6FFFC2)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Container(
      height: 190,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFFC8E6D4), Color(0xFFA8D5B8)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _GridPainter()),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 32, color: VitaColors.green),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(20)),
                  child: Text('Abuja, FCT · Live Map', style: VitaText.display(12, color: VitaColors.green, weight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    for (double x = 0; x <= size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Hospital {
  const _Hospital({required this.rank, required this.name, required this.addr, required this.open, required this.dist});
  final String rank;
  final String name;
  final String addr;
  final bool open;
  final String dist;
}

class _HospitalCard extends StatelessWidget {
  const _HospitalCard({required this.hospital});
  final _Hospital hospital;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x12000000)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 2))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34, height: 34,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: VitaColors.lightGreen),
            alignment: Alignment.center,
            child: Text(hospital.rank, style: VitaText.display(14, color: VitaColors.green, weight: FontWeight.w700)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital.name, style: VitaText.display(14, color: VitaColors.dark, weight: FontWeight.w700).copyWith(letterSpacing: -0.2)),
                const SizedBox(height: 3),
                Text(hospital.addr, style: VitaText.body(11.5, color: VitaColors.gray).copyWith(height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: hospital.open ? VitaColors.teal.withValues(alpha: 0.12) : VitaColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 5, height: 5, decoration: BoxDecoration(shape: BoxShape.circle, color: hospital.open ? VitaColors.green : VitaColors.red)),
                          const SizedBox(width: 4),
                          Text(hospital.open ? 'Open' : 'Closed', style: VitaText.mono(11, color: hospital.open ? VitaColors.green : VitaColors.red, weight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(hospital.dist, style: VitaText.mono(12, color: VitaColors.green, weight: FontWeight.w700)),
                    const Spacer(),
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Simulating map navigation to ${hospital.name}...', style: VitaText.body(13, color: Colors.white)),
                              backgroundColor: VitaColors.dark,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: VitaColors.lightGreen,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: VitaColors.green.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.map_outlined, size: 14, color: VitaColors.green),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('Directions', style: VitaText.body(12, color: VitaColors.green, weight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                              ),
                            ]
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
