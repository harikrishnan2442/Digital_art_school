import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/app_logo.dart';
import '../../core/widgets/gradient_button.dart';
import '../../services/api_client.dart';
import '../../state/app_state.dart';
import '../shell/main_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context
          .read<AppState>()
          .login(_emailCtrl.text.trim(), _passwordCtrl.text, rememberMe: _rememberMe);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pageBg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            if (wide) {
              return Row(
                children: [
                  Expanded(flex: 5, child: _BrandPanel()),
                  Expanded(flex: 6, child: _buildFormPanel()),
                ],
              );
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  const _CompactBrandBanner(),
                  _buildFormPanel(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFormPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sign in',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.deep,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text('New student? ',
                    style: TextStyle(color: AppColors.slate, fontSize: 13.5)),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Email Address',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'your.email@example.com',
                prefixIcon: Icon(AppIcons.mail, size: 20),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            const Text('Password',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.deep)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(AppIcons.lock, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? AppIcons.eye : AppIcons.eyeOff),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 6) return 'Minimum 6 characters';
                return null;
              },
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: AppColors.blue,
                    onChanged: (v) => setState(() => _rememberMe = v ?? false),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Remember me on this device',
                      style: TextStyle(fontSize: 12.5, color: AppColors.slate)),
                ),
              ],
            ),
            const SizedBox(height: 18),
            GradientButton(
              label: 'Sign In',
              loading: _loading,
              onPressed: _loading ? null : _submit,
            ),
            const SizedBox(height: 20),
            Center(
              child: Builder(builder: (context) {
                final live = context.watch<AppState>().isUsingLiveApi;
                return Text(
                  live
                      ? 'Connected to your database — sign in with a registered account.'
                      : 'Demo mode — any email & a 6+ character password will sign you in. '
                          '(Set API_BASE_URL in .env to use your real database.)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11.5, color: AppColors.slate.withOpacity(0.7)),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      padding: const EdgeInsets.all(40),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -60,
            child: _blob(AppColors.teal, 200),
          ),
          Positioned(
            bottom: -40,
            left: -50,
            child: _blob(AppColors.gold, 220),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: const [
                  AppLogo(size: 34, onDark: true),
                  SizedBox(width: 10),
                  Text('Digital Art School',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                ],
              ),
              const SizedBox(height: 44),
              const Text(
                'Welcome\nback, Artist.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sign in to continue your creative journey. Your courses, '
                'progress, and community are waiting.',
                style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 30),
              _badge(AppIcons.award, 'Access all your enrolled courses'),
              const SizedBox(height: 12),
              _badge(AppIcons.trendingUp, 'Track your learning milestones'),
              const SizedBox(height: 12),
              _badge(AppIcons.users, 'Connect with your instructors'),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Text(
              '© Digital Art School — Preserving tradition through technology',
              style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text,
              style: TextStyle(color: Colors.white.withOpacity(0.92), fontSize: 12.5)),
        ),
      ],
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.30), color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _CompactBrandBanner extends StatelessWidget {
  const _CompactBrandBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: const BoxDecoration(gradient: AppColors.heroGradient),
      child: Column(
        children: const [
          AppLogo(size: 44, onDark: true),
          SizedBox(height: 12),
          Text('Welcome back, Artist.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          SizedBox(height: 6),
          Text('Sign in to continue your creative journey.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 12.5)),
        ],
      ),
    );
  }
}
