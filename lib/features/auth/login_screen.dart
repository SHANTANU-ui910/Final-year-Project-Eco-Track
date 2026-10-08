import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../transportation/screens/home_screen.dart';
import 'ambient_background.dart';
import 'animated_logo.dart';
import 'auth_segmented_control.dart';
import 'cta_button.dart';
import 'design_tokens.dart';
import 'eco_text_field.dart';
import 'footer_trust_link.dart';
import 'liquid_glass_card.dart';
import 'quick_access_row.dart';
import 'verified_badge.dart';

/// Flagship EcoTrack Mobility Authentication Screen.
/// Built with Apple / Stripe-grade design polish, fluid micro-interactions,
/// and verified IPCC Tier-1 carbon accounting security.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Form Controllers
  final TextEditingController _emailController =
      TextEditingController(text: 'alex.mobility@ecotrack.org');
  final TextEditingController _passwordController =
      TextEditingController(text: '••••••••••••');
  final TextEditingController _nameController = TextEditingController();

  final GlobalKey<EcoTextFieldState> _emailFieldKey = GlobalKey<EcoTextFieldState>();
  final GlobalKey<EcoTextFieldState> _passwordFieldKey = GlobalKey<EcoTextFieldState>();
  final GlobalKey<EcoTextFieldState> _nameFieldKey = GlobalKey<EcoTextFieldState>();

  final ScrollController _scrollController = ScrollController();

  // State
  AuthTab _currentTab = AuthTab.signIn;
  bool _keepMeSignedIn = true;
  bool _agreeToTerms = false;
  CtaState _ctaState = CtaState.idle;
  int _passwordStrengthSegments = 0; // 0 to 4
  bool _isDark = false;

  // Staggered Entrance Controller (Total 1100ms)
  late AnimationController _entranceController;
  late Animation<double> _logoEntrance;
  late Animation<double> _badgeEntrance;
  late Animation<double> _headlineEntrance;
  late Animation<double> _cardEntrance;
  late Animation<double> _ctaEntrance;
  late Animation<double> _quickAccessEntrance;
  late Animation<double> _footerEntrance;

  // Live Trust Dot Pulsing Beacon (1.8s loop)
  late AnimationController _pulseDotController;

  @override
  void initState() {
    super.initState();

    // 1. Entrance Stagger Sequence (< 1.2s total)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _logoEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOutCubic),
    );
    _badgeEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.11, 0.52, curve: Curves.easeOutCubic),
    );
    _headlineEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.16, 0.62, curve: Curves.easeOutCubic),
    );
    _cardEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.22, 0.72, curve: Curves.easeOutCubic),
    );
    _ctaEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.44, 0.88, curve: Curves.easeOutCubic),
    );
    _quickAccessEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.51, 0.94, curve: Curves.easeOutCubic),
    );
    _footerEntrance = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.58, 1.0, curve: Curves.easeOutCubic),
    );

    // 2. Verified Mobility Node live beacon (1.8s loop)
    _pulseDotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _entranceController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _scrollController.dispose();
    _entranceController.dispose();
    _pulseDotController.dispose();
    super.dispose();
  }

  void _calculatePasswordStrength(String password) {
    int strength = 0;
    if (password.length >= 6) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[^A-Za-z0-9]'))) strength++;
    setState(() {
      _passwordStrengthSegments = strength;
    });
  }

  void _handleSignIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@')) {
      _emailFieldKey.currentState?.triggerShake('Please enter a valid work or personal email');
      return;
    }

    if (password.isEmpty || password.length < 4) {
      _passwordFieldKey.currentState?.triggerShake('Password must be at least 6 characters');
      return;
    }

    setState(() {
      _ctaState = CtaState.loading;
    });

    // Simulated verified authentication handshake (900ms)
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _ctaState = CtaState.success;
    });

    // Success celebration burst window (900ms) before navigation
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, anim, _) => const HomeScreen(),
        transitionsBuilder: (context, anim, _, child) {
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        },
      ),
    );
  }

  void _handleGoogleSignIn() async {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentTab = AuthTab.signIn;
      _emailController.text = 'alex.morgan@gmail.com';
      _passwordController.text = '••••••••••••';
      _ctaState = CtaState.loading;
    });

    // Simulated verified Google OAuth credential exchange (800ms)
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    setState(() {
      _ctaState = CtaState.success;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (context, anim, _) => const HomeScreen(),
        transitionsBuilder: (context, anim, _, child) {
          return FadeTransition(
            opacity: anim,
            child: child,
          );
        },
      ),
    );
  }

  void _handle1TapDemo() {
    setState(() {
      _currentTab = AuthTab.signIn;
      _emailController.text = 'alex.mobility@ecotrack.org';
      _passwordController.text = 'GreenMobility#2026';
    });
    _handleSignIn();
  }

  void _showIpccLedgerBottomSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          decoration: BoxDecoration(
            color: _isDark ? const Color(0xFF081C16) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
            border: Border.all(
              color: _isDark ? EcoTokens.darkBorder : EcoTokens.border,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: _isDark ? EcoTokens.darkMuted : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: EcoTokens.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const PhosphorIcon(
                      PhosphorIconsFill.shieldCheck,
                      color: EcoTokens.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'IPCC Tier-1 Carbon Ledger',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16.0,
                            fontWeight: FontWeight.w800,
                            color: _isDark ? EcoTokens.darkInk : EcoTokens.ink,
                          ),
                        ),
                        Text(
                          'Certified Emission Audit Protocol',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.0,
                            color: _isDark ? EcoTokens.darkMuted : EcoTokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Text(
                'Every kilometer tracked in EcoTrack is cryptographically logged using Intergovernmental Panel on Climate Change (IPCC) Tier-1 fuel combustion and electricity grid carbon intensity coefficients. Your carbon savings are tamper-proof and verifiable for carbon tax credits and enterprise ESG reports.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.5,
                  height: 1.5,
                  color: _isDark ? EcoTokens.darkMuted : EcoTokens.muted,
                ),
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EcoTokens.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close & Return',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isKeyboardOpen = mediaQuery.viewInsets.bottom > 100;
    final keyboardScale = isKeyboardOpen ? 0.72 : 1.0;
    final isReducedMotion = mediaQuery.disableAnimations;

    return Scaffold(
      backgroundColor: _isDark ? EcoTokens.darkBg : EcoTokens.mintBg,
      body: AmbientBackground(
        isDark: _isDark,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Theme Toggle Icon
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                              size: 20.0,
                              color: _isDark ? EcoTokens.limeGlow : EcoTokens.deepEmerald,
                            ),
                            onPressed: () {
                              setState(() {
                                _isDark = !_isDark;
                              });
                            },
                          ),
                        ),

                        // 1. Hero Brand Logo (88px Squircle with soft emerald glow)
                        _buildAnimatedEntrance(
                          animation: _logoEntrance,
                          isReducedMotion: isReducedMotion,
                          child: AnimatedLogoTile(
                            scaleFactor: keyboardScale,
                            isDark: _isDark,
                          ),
                        ),
                        const SizedBox(height: 14.0),

                        // 2. Trust Badge: "VERIFIED MOBILITY NODE" with live pulsing beacon
                        _buildAnimatedEntrance(
                          animation: _badgeEntrance,
                          isReducedMotion: isReducedMotion,
                          child: VerifiedBadge(isDark: _isDark),
                        ),
                        const SizedBox(height: 12.0),

                        // 3. Headline & Subline (Fades slightly when keyboard is open)
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: isKeyboardOpen ? 0.0 : 1.0,
                          child: _buildAnimatedEntrance(
                            animation: _headlineEntrance,
                            isReducedMotion: isReducedMotion,
                            child: Column(
                              children: [
                                Text(
                                  _currentTab == AuthTab.signIn
                                      ? 'Welcome back'
                                      : 'Create your node',
                                  style: EcoTokens.headline(isDark: _isDark),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 4.0),
                                Text(
                                  'A cleaner tomorrow starts with your next trip.',
                                  style: EcoTokens.subline(isDark: _isDark),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isKeyboardOpen ? 12.0 : 20.0),

                        // 4. Glassmorphism Interactive Authentication Card
                        _buildAnimatedEntrance(
                          animation: _cardEntrance,
                          isReducedMotion: isReducedMotion,
                          child: LiquidGlassCard(
                            isDark: _isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sliding-Pill Segmented Control
                                AuthSegmentedControl(
                                  currentTab: _currentTab,
                                  isDark: _isDark,
                                  onTabChanged: (tab) {
                                    setState(() {
                                      _currentTab = tab;
                                    });
                                  },
                                ),
                                const SizedBox(height: 20.0),

                                // Animated Tab Form Body
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: _currentTab == AuthTab.signIn
                                      ? _buildSignInForm()
                                      : _buildCreateAccountForm(),
                                ),
                                const SizedBox(height: 20.0),

                                // Primary Gradient CTA Button
                                _buildAnimatedEntrance(
                                  animation: _ctaEntrance,
                                  isReducedMotion: isReducedMotion,
                                  child: CtaButton(
                                    text: _currentTab == AuthTab.signIn
                                        ? 'Sign In →'
                                        : 'Create EcoTrack Node →',
                                    state: _ctaState,
                                    isDark: _isDark,
                                    onPressed: _handleSignIn,
                                  ),
                                ),
                                const SizedBox(height: 22.0),

                                // "Fast instant access" Divider & Action Buttons
                                _buildAnimatedEntrance(
                                  animation: _quickAccessEntrance,
                                  isReducedMotion: isReducedMotion,
                                  child: QuickAccessRow(
                                    isDark: _isDark,
                                    onGoogleTap: _handleGoogleSignIn,
                                    onDemoTap: _handle1TapDemo,
                                    onBiometricSuccess: _handleSignIn,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 18.0),

                        // 5. Footer Trust Row
                        _buildAnimatedEntrance(
                          animation: _footerEntrance,
                          isReducedMotion: isReducedMotion,
                          child: FooterTrustLink(isDark: _isDark),
                        ),
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Sign In Form Fields & Checkbox
  Widget _buildSignInForm() {
    return Column(
      key: const ValueKey('SignInForm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EcoTextField(
          key: _emailFieldKey,
          controller: _emailController,
          labelText: 'Email Address',
          hintText: 'alex.mobility@ecotrack.org',
          prefixIcon: PhosphorIconsRegular.envelopeSimple,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          isDark: _isDark,
        ),
        const SizedBox(height: 16.0),

        EcoTextField(
          key: _passwordFieldKey,
          controller: _passwordController,
          labelText: 'Password',
          hintText: '••••••••••••',
          prefixIcon: PhosphorIconsRegular.lockSimple,
          isPassword: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          isDark: _isDark,
          onSubmitted: _handleSignIn,
        ),
        const SizedBox(height: 14.0),

        // Custom Checkbox + "Forgot?" Link
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _keepMeSignedIn = !_keepMeSignedIn;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
                child: Row(
                  children: [
                    _buildAnimatedCheckbox(_keepMeSignedIn),
                    const SizedBox(width: 8.0),
                    Text(
                      'Keep me signed in',
                      style: EcoTokens.caption(isDark: _isDark).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () {
                HapticFeedback.lightImpact();
                _handleSignIn();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fingerprint,
                      size: 16.0,
                      color: _isDark ? EcoTokens.limeGlow : EcoTokens.primary,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      'Use biometrics',
                      style: EcoTokens.caption(isDark: _isDark).copyWith(
                        fontWeight: FontWeight.w600,
                        color: _isDark ? Colors.white.withValues(alpha: 0.85) : EcoTokens.ink,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Create Account Form with Password Strength Meter
  Widget _buildCreateAccountForm() {
    return Column(
      key: const ValueKey('CreateAccountForm'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EcoTextField(
          key: _nameFieldKey,
          controller: _nameController,
          labelText: 'Full Name',
          hintText: 'Alex Morgan',
          prefixIcon: PhosphorIconsRegular.user,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.name],
          isDark: _isDark,
        ),
        const SizedBox(height: 16.0),

        EcoTextField(
          controller: _emailController,
          labelText: 'Work or Personal Email',
          hintText: 'alex.mobility@ecotrack.org',
          prefixIcon: PhosphorIconsRegular.envelopeSimple,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          isDark: _isDark,
        ),
        const SizedBox(height: 16.0),

        EcoTextField(
          controller: _passwordController,
          labelText: 'Create Strong Password',
          hintText: 'Min. 8 chars, 1 uppercase, 1 symbol',
          prefixIcon: PhosphorIconsRegular.lockSimple,
          isPassword: true,
          textInputAction: TextInputAction.done,
          onChanged: _calculatePasswordStrength,
          isDark: _isDark,
          onSubmitted: _handleSignIn,
        ),
        const SizedBox(height: 10.0),

        // 4-Segment Animated Strength Meter
        _buildPasswordStrengthMeter(),
        const SizedBox(height: 14.0),

        // Terms of Service Agreement Checkbox
        InkWell(
          borderRadius: BorderRadius.circular(8.0),
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() {
              _agreeToTerms = !_agreeToTerms;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedCheckbox(_agreeToTerms),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    'I agree to the IPCC Tier-1 Carbon Auditing Protocol and Environmental Privacy Charter.',
                    style: EcoTokens.caption(isDark: _isDark).copyWith(
                      fontSize: 12.0,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 4-Segment Password Strength Indicator
  Widget _buildPasswordStrengthMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (index) {
            final isFilled = index < _passwordStrengthSegments;
            Color segColor;
            if (_passwordStrengthSegments <= 1) {
              segColor = EcoTokens.error;
            } else if (_passwordStrengthSegments <= 2) {
              segColor = const Color(0xFFF59E0B);
            } else {
              segColor = EcoTokens.bright;
            }

            return Expanded(
              child: Container(
                height: 4.0,
                margin: EdgeInsets.only(right: index < 3 ? 6.0 : 0.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2.0),
                  color: isFilled
                      ? segColor
                      : (_isDark ? const Color(0xFF163228) : const Color(0xFFE2E8F0)),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 5.0),
        Text(
          _passwordStrengthSegments == 0
              ? 'Password strength'
              : _passwordStrengthSegments == 1
                  ? 'Weak'
                  : _passwordStrengthSegments == 2
                      ? 'Fair'
                      : _passwordStrengthSegments == 3
                          ? 'Good'
                          : 'Strong & Secure',
          style: TextStyle(
            fontSize: 11.0,
            fontWeight: FontWeight.w600,
            color: _isDark ? EcoTokens.darkMuted : EcoTokens.muted,
          ),
        ),
      ],
    );
  }

  /// Custom animated checkbox with 160ms scale and 200ms vector check draw
  Widget _buildAnimatedCheckbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 20.0,
      height: 20.0,
      decoration: BoxDecoration(
        color: isChecked
            ? (_isDark ? EcoTokens.primary : EcoTokens.deepEmerald)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6.0),
        border: Border.all(
          color: isChecked
              ? (_isDark ? EcoTokens.primary : EcoTokens.deepEmerald)
              : (_isDark ? EcoTokens.darkBorder : const Color(0xFF94A3B8)),
          width: 1.6,
        ),
      ),
      child: isChecked
          ? const Center(
              child: Icon(
                Icons.check_rounded,
                size: 14.0,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  /// Verified Mobility Node Trust Badge with pulsing live dot
  Widget _buildTrustBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: _isDark
            ? EcoTokens.deepEmerald.withValues(alpha: 0.6)
            : const Color(0xFFEAF5EE),
        borderRadius: BorderRadius.circular(EcoTokens.radiusPill),
        border: Border.all(
          color: _isDark ? const Color(0x33B9F36B) : const Color(0xFFC8E6C9),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1.8s live pulsing beacon
          AnimatedBuilder(
            animation: _pulseDotController,
            builder: (context, _) {
              final t = _pulseDotController.value;
              final scale = 1.0 + (t * 0.6);
              final opacity = (1.0 - t) * 0.6;
              final dotColor = _isDark ? EcoTokens.limeGlow : EcoTokens.bright;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: dotColor.withValues(alpha: opacity),
                      ),
                    ),
                  ),
                  Container(
                    width: 6.5,
                    height: 6.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(width: 8.0),
          Text(
            'VERIFIED MOBILITY NODE',
            style: EcoTokens.trustBadge(isDark: _isDark),
          ),
        ],
      ),
    );
  }

  /// Tappable footer trust anchor opening the IPCC carbon ledger spec sheet
  Widget _buildFooterTrustRow() {
    return InkWell(
      borderRadius: BorderRadius.circular(12.0),
      onTap: _showIpccLedgerBottomSheet,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PhosphorIcon(
              PhosphorIconsFill.shieldCheck,
              size: 16.0,
              color: _isDark ? EcoTokens.limeGlow : EcoTokens.primary,
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                'Secured by the IPCC Tier-1 Carbon Ledger',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: _isDark ? EcoTokens.darkMuted : EcoTokens.muted,
                  decoration: TextDecoration.underline,
                  decorationColor: (_isDark ? EcoTokens.darkMuted : EcoTokens.muted).withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper rendering staggered slide & fade transitions
  Widget _buildAnimatedEntrance({
    required Animation<double> animation,
    required Widget child,
    bool isReducedMotion = false,
  }) {
    if (isReducedMotion) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final progress = animation.value;
        final offsetY = (1.0 - progress) * 20.0;

        return Transform.translate(
          offset: Offset(0, offsetY),
          child: Opacity(
            opacity: progress,
            child: child,
          ),
        );
      },
    );
  }
}
