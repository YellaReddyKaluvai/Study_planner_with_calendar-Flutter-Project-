import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/animated_input.dart';
import 'auth_notifier.dart';
import 'auth_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // Listen to auth state changes to navigate
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        // Navigate to Home if logged in
        context.go('/');
      }
    });

    return Scaffold(
      body: Stack(
        children: [
          // 1. Animated Gradient Background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
            )
                .animate(
                    onPlay: (controller) => controller.repeat(reverse: true))
                .saturate(
                    delay: 2.seconds,
                    duration: 3.seconds,
                    begin: 0.8,
                    end: 1.2),
          ),

          // 2. Background Pattern / Blobs
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.4),
              ),
            )
                .animate()
                .scale(
                    duration: 5.seconds,
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.2, 1.2),
                    curve: Curves.easeInOut)
                .fadeIn(),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.secondary.withOpacity(0.3),
              ),
            )
                .animate()
                .scale(
                    duration: 7.seconds,
                    begin: const Offset(1, 1),
                    end: const Offset(1.5, 1.5),
                    curve: Curves.easeInOut)
                .fadeIn(),
          ),

          // 3. Center Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 64,
                    color: Colors.white,
                  ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    'Study Planner Ultra',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 8),
                  Text(
                    'Elevate your productivity.',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 48),

                  // Login Card
                  GlassContainer(
                    opacity: 0.1,
                    blur: 20,
                    borderRadius: BorderRadius.circular(24),
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? 'Welcome Back' : 'Create Account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),

                          // Name Input (Sign Up only)
                          if (!_isLogin) ...[
                            AnimatedInput(
                              label: 'Full Name',
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (!_isLogin &&
                                    (value == null || value.isEmpty)) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Email Input
                          AnimatedInput(
                            label: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Input
                          AnimatedInput(
                            label: 'Password',
                            prefixIcon: Icons.lock_outlined,
                            isPassword: true,
                            controller: _passwordController,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            onFieldSubmitted: (_) {
                              if (_isLogin) {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signInWithEmailAndPassword(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                              } else {
                                ref
                                    .read(authNotifierProvider.notifier)
                                    .signUpWithEmailAndPassword(
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                      displayName: _nameController.text.trim(),
                                    );
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          if (_isLogin)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // Forgot Password logic
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),

                          const SizedBox(height: 8),

                          // Action Button
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        final email =
                                            _emailController.text.trim();
                                        final password =
                                            _passwordController.text.trim();
                                        if (_isLogin) {
                                          ref
                                              .read(
                                                  authNotifierProvider.notifier)
                                              .signInWithEmailAndPassword(
                                                  email, password);
                                        } else {
                                          ref
                                              .read(
                                                  authNotifierProvider.notifier)
                                              .signUpWithEmailAndPassword(
                                                  email, password,
                                                  displayName: _nameController
                                                      .text
                                                      .trim());
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: authState.isLoading
                                  ? const CircularProgressIndicator()
                                  : Text(
                                      _isLogin ? 'Sign In' : 'Sign Up',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          )
                              .animate()
                              .scale(delay: 600.ms, curve: Curves.elasticOut),

                          const SizedBox(height: 24),

                          // Google Sign In
                          Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text('OR',
                                    style: TextStyle(color: Colors.white54)),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),
                          const SizedBox(height: 24),

                          SizedBox(
                            height: 56,
                            child: OutlinedButton.icon(
                              onPressed: authState.isLoading
                                  ? null
                                  : () {
                                      ref
                                          .read(authNotifierProvider.notifier)
                                          .signInWithGoogle();
                                    },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              icon: Image.network(
                                'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
                                height: 24,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.g_mobiledata, size: 32),
                              ),
                              label: Text('Continue with Google'),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Switch Mode
                          Center(
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: RichText(
                                text: TextSpan(
                                  text: _isLogin
                                      ? "Don't have an account? "
                                      : "Already have an account? ",
                                  style: TextStyle(color: Colors.white70),
                                  children: [
                                    TextSpan(
                                      text: _isLogin ? 'Sign Up' : 'Sign In',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          if (authState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: Text(
                                authState.error!,
                                style: TextStyle(
                                    color: AppTheme.error, fontSize: 12),
                                textAlign: TextAlign.center,
                              ).animate().shake(),
                            ),
                        ],
                      ),
                    ),
                  )
                      .animate()
                      .slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOutBack)
                      .fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
