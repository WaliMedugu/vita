import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vita/theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0; // 0 = Login, 1 = Register
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _switchTab(int t) {
    _ctrl.reverse().then((_) {
      setState(() => _tab = t);
      _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VitaColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── Dark Hero Header ────────────────────────────────────────────
              Container(
                height: 200,
                width: double.infinity,
                color: VitaColors.dark,
                child: Stack(
                  children: [
                    // Big background text
                    Positioned(
                      top: -20,
                      left: -10,
                      child: Text(
                        _tab == 0 ? 'VITA' : 'JOIN',
                        style: VitaText.display(180,
                          color: Colors.white.withValues(alpha: 0.05),
                          weight: FontWeight.w700,
                        ).copyWith(letterSpacing: -8),
                      ),
                    ),
                    // Title
                    Positioned(
                      bottom: 24,
                      left: 24,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _tab == 0
                            ? _buildTitle('Welcome', 'back.', key: const ValueKey('login'))
                            : _buildTitle('Create', 'account.', key: const ValueKey('reg')),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Tab Switcher ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _Tab(label: 'Login', active: _tab == 0, onTap: () => _switchTab(0)),
                      _Tab(label: 'Register', active: _tab == 1, onTap: () => _switchTab(1)),
                    ],
                  ),
                ),
              ),

              // ── Form ────────────────────────────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: _tab == 0
                      ? _LoginForm(
                          onLogin: () => context.go('/dashboard'),
                          onRegisterTap: () => _switchTab(1),
                          onForgotTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Password recovery link sent to email.', style: VitaText.body(13, color: Colors.white)),
                                backgroundColor: VitaColors.dark,
                              ),
                            );
                          },
                        )
                      : _RegisterForm(
                          onLoginTap: () => _switchTab(0),
                          onRegister: () => context.go('/dashboard'),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String line1, String line2, {Key? key}) => Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            line1,
            style: VitaText.display(34,
              color: Colors.white,
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: -1),
          ),
          Text(
            line2,
            style: VitaText.serif(30,
              color: Colors.white.withValues(alpha: 0.55),
            ).copyWith(letterSpacing: -0.5),
          ),
        ],
      );
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: VitaText.body(13.5,
              color: active ? VitaColors.dark : VitaColors.gray,
              weight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── LOGIN FORM ───────────────────────────────────────────────────────────────
// ─── LOGIN FORM ───────────────────────────────────────────────────────────────
class _LoginForm extends StatelessWidget {
  const _LoginForm({this.onLogin, required this.onRegisterTap, required this.onForgotTap});
  final VoidCallback? onLogin;
  final VoidCallback onRegisterTap;
  final VoidCallback onForgotTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormField(label: 'Email', hint: 'wali@example.com'),
        const SizedBox(height: 14),
        const _FormField(label: 'Password', hint: '••••••••', obscure: true),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: onForgotTap,
            child: Text(
              'Forgot password?',
              style: VitaText.body(12.5, color: VitaColors.green, weight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onLogin,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sign In', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: onRegisterTap,
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: VitaText.body(13, color: VitaColors.gray),
                children: [
                  TextSpan(
                    text: 'Register',
                    style: VitaText.body(13, color: VitaColors.green, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── REGISTER FORM ────────────────────────────────────────────────────────────
class _RegisterForm extends StatelessWidget {
  const _RegisterForm({required this.onLoginTap, required this.onRegister});
  final VoidCallback onLoginTap;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _FormField(label: 'Full Name', hint: 'Amina Bello'),
        const SizedBox(height: 14),
        const _FormField(label: 'Email', hint: 'amina@example.com'),
        const SizedBox(height: 14),
        const _FormField(label: 'Phone', hint: '+234 801 234 5678'),
        const SizedBox(height: 14),
        const _FormField(label: 'Password', hint: 'At least 8 characters', obscure: true),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onRegister,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Create Account', style: VitaText.display(16, color: Colors.white, weight: FontWeight.w700)),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: GestureDetector(
            onTap: onLoginTap,
            child: RichText(
              text: TextSpan(
                text: 'Have an account? ',
                style: VitaText.body(13, color: VitaColors.gray),
                children: [
                  TextSpan(
                    text: 'Sign In',
                    style: VitaText.body(13, color: VitaColors.green, weight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SHARED FORM FIELD ────────────────────────────────────────────────────────
class _FormField extends StatelessWidget {
  const _FormField({required this.label, required this.hint, this.obscure = false});
  final String label;
  final String hint;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: VitaText.mono(11.5,
            color: VitaColors.dark,
            weight: FontWeight.w600,
          ).copyWith(letterSpacing: 0.8),
        ),
        const SizedBox(height: 5),
        TextField(
          obscureText: obscure,
          style: VitaText.body(14, weight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF2F2F0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: VitaColors.teal, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            hintStyle: VitaText.body(14, color: const Color(0xFFB0B0AE)),
          ),
        ),
      ],
    );
  }
}
