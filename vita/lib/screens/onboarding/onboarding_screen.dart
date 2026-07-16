import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageCtrl = PageController();
  int _page = 0;

  static const _slides = [
    _Slide(
      bg: Color(0xFF1A6B4A),
      bgNum: '01',
      tag: 'VitaCard',
      titleBig: 'Your\nHealth',
      titleItalic: 'always with you.',
      body:
          'A ₦300 NFC sticker stores your blood type, allergies, and emergency contacts — readable offline in any crisis.',
      btnLabel: 'Get Started',
      skipLabel: 'Already registered? Sign In',
      floatLabel: 'Pool Size',
      floatValue: '133M',
      floatSub: 'Uninsured Nigerians',
      floatGold: false,
    ),
    _Slide(
      bg: Color(0xFF1A1A2E),
      bgNum: '02',
      tag: 'VitaPool',
      titleBig: 'Community',
      titleItalic: 'funds that act fast.',
      body:
          'Tiny ₦100 sweeps from everyday OPay transactions build a shared safety fund — ready the moment anyone needs it most.',
      btnLabel: 'Next',
      skipLabel: 'Skip intro',
      floatLabel: 'Pool Today',
      floatValue: '₦48k',
      floatSub: '18 members',
      floatGold: true,
    ),
    _Slide(
      bg: Color(0xFF0D2A1E),
      bgNum: '90',
      tag: 'VitaVoice',
      titleBig: '90',
      titleItalic: 'seconds to help.',
      body:
          'Tap card → get first aid → trigger pool → funds reach bystander. Even in rural areas, even without a smartphone.',
      btnLabel: 'Create Account',
      skipLabel: 'Sign In Instead',
      floatLabel: null,
      floatValue: null,
      floatSub: null,
      floatGold: false,
    ),
  ];

  void _next() {
    if (_page < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageCtrl,
        itemCount: _slides.length,
        onPageChanged: (i) => setState(() => _page = i),
        itemBuilder: (context, i) => _SlideView(
          slide: _slides[i],
          page: i,
          currentPage: _page,
          onNext: _next,
          onSkip: () => context.go('/auth'),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.bg,
    required this.bgNum,
    required this.tag,
    required this.titleBig,
    required this.titleItalic,
    required this.body,
    required this.btnLabel,
    required this.skipLabel,
    required this.floatLabel,
    required this.floatValue,
    required this.floatSub,
    required this.floatGold,
  });

  final Color bg;
  final String bgNum;
  final String tag;
  final String titleBig;
  final String titleItalic;
  final String body;
  final String btnLabel;
  final String skipLabel;
  final String? floatLabel;
  final String? floatValue;
  final String? floatSub;
  final bool floatGold;
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.page,
    required this.currentPage,
    required this.onNext,
    required this.onSkip,
  });

  final _Slide slide;
  final int page;
  final int currentPage;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: slide.bg,
      child: Stack(
        children: [
          // Giant background number
          Positioned(
            bottom: -60,
            right: -40,
            child: Text(
              slide.bgNum,
              style: VitaText.display(320,
                color: Colors.white.withValues(alpha: 0.04),
                weight: FontWeight.w700,
              ).copyWith(letterSpacing: -20),
            ),
          ),

          // Floating stat card (slides 1 & 2)
          if (slide.floatLabel != null)
            Positioned(
              top: 50,
              right: 20,
              child: _FloatCard(slide: slide),
            ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag chip
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: slide.floatGold
                          ? const Color(0xFFD4A017).withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: slide.floatGold
                                ? const Color(0xFFD4A017)
                                : Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slide.tag,
                          style: VitaText.mono(11,
                            color: slide.floatGold
                                ? const Color(0xFFD4A017).withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.8),
                            weight: FontWeight.w600,
                          ).copyWith(
                            letterSpacing: 1,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Hero content
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        slide.titleBig,
                        style: VitaText.display(58,
                          color: Colors.white,
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: -2, height: 0.9),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slide.titleItalic,
                        style: VitaText.serif(54,
                          color: Colors.white.withValues(alpha: 0.7),
                        ).copyWith(letterSpacing: -1, height: 1),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        slide.body,
                        style: VitaText.body(14,
                          color: Colors.white.withValues(alpha: 0.6),
                        ).copyWith(height: 1.65),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 32),
                      // Progress dots
                      Row(
                        children: List.generate(3, (i) {
                          final active = i == currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 5),
                            height: 2,
                            width: active ? 28 : 20,
                            decoration: BoxDecoration(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // Footer
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                  child: ClipRect(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                      child: Column(
                        children: [
                          // Main button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onNext,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: VitaColors.dark,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    slide.btnLabel,
                                    style: VitaText.display(16,
                                      color: VitaColors.dark,
                                      weight: FontWeight.w700,
                                    ).copyWith(letterSpacing: -0.3),
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: slide.bg,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: onSkip,
                            child: Text(
                              slide.skipLabel,
                              style: VitaText.body(12.5,
                                color: Colors.white.withValues(alpha: 0.45),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatCard extends StatelessWidget {
  const _FloatCard({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: slide.floatGold
            ? const Color(0xFFD4A017).withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: slide.floatGold
              ? const Color(0xFFD4A017).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.floatLabel!.toUpperCase(),
            style: VitaText.mono(10,
              color: slide.floatGold
                  ? const Color(0xFFD4A017).withValues(alpha: 0.7)
                  : Colors.white.withValues(alpha: 0.5),
            ).copyWith(letterSpacing: 0.8),
          ),
          const SizedBox(height: 4),
          Text(
            slide.floatValue!,
            style: VitaText.display(22,
              color: slide.floatGold
                  ? const Color(0xFFF5D060)
                  : Colors.white,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 2),
          Text(
            slide.floatSub!,
            style: VitaText.body(11,
              color: slide.floatGold
                  ? const Color(0xFFD4A017).withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
