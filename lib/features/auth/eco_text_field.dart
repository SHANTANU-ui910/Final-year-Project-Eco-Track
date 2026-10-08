import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'design_tokens.dart';
import 'sound_effects_service.dart';

/// Luxury Input Field with floating label, animated focus glow ring,
/// Phosphor icon tinting, caps-lock warning, and 320ms error shake response.
class EcoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final PhosphorIconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onSubmitted;
  final bool isDark;
  final bool enabled;

  const EcoTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.autofillHints,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.isDark = false,
    this.enabled = true,
  });

  @override
  State<EcoTextField> createState() => EcoTextFieldState();
}

class EcoTextFieldState extends State<EcoTextField>
    with SingleTickerProviderStateMixin {
  late FocusNode _focusNode;
  bool _obscureText = true;
  bool _isFocused = false;
  bool _isCapsLockOn = false;
  String? _errorMessage;

  // Shake animation on validation failure (3 oscillations, +-6px, 320ms)
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: -6.0), weight: 15),
      TweenSequenceItem(tween: Tween<double>(begin: -6.0, end: 6.0), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 6.0, end: -4.0), weight: 25),
      TweenSequenceItem(tween: Tween<double>(begin: -4.0, end: 4.0), weight: 20),
      TweenSequenceItem(tween: Tween<double>(begin: 4.0, end: 0.0), weight: 10),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      EcoAudioHapticService.play(EcoSoundEvent.fieldFocus);
    }
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Triggers the shake animation when form validation fails
  void triggerShake(String errorMessage) {
    EcoAudioHapticService.play(EcoSoundEvent.errorShake);
    setState(() {
      _errorMessage = errorMessage;
    });
    _shakeController.forward(from: 0.0);
  }

  /// Clears error message
  void clearError() {
    if (_errorMessage != null) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    // Detect Caps Lock state on Desktop/Web
    final isCapsLock = HardwareKeyboard.instance.lockModesEnabled.contains(
      KeyboardLockMode.capsLock,
    );
    if (isCapsLock != _isCapsLockOn) {
      setState(() {
        _isCapsLockOn = isCapsLock;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasError = _errorMessage != null;
    final isDark = widget.isDark;

    // Computed border and tint colors
    final borderColor = hasError
        ? EcoTokens.error
        : _isFocused
            ? (isDark ? EcoTokens.limeGlow : EcoTokens.primary)
            : (isDark ? EcoTokens.darkBorder : EcoTokens.border);

    final iconColor = hasError
        ? EcoTokens.error
        : _isFocused
            ? (isDark ? EcoTokens.limeGlow : EcoTokens.primary)
            : (isDark ? EcoTokens.darkMuted : EcoTokens.muted);

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: _handleKeyEvent,
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation.value, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating Upper Label
                Padding(
                  padding: const EdgeInsets.only(left: 4.0, bottom: 6.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.labelText.toUpperCase(),
                        style: EcoTokens.label(isDark: isDark).copyWith(
                          color: hasError
                              ? EcoTokens.error
                              : _isFocused
                                  ? (isDark ? EcoTokens.limeGlow : EcoTokens.primary)
                                  : (isDark ? EcoTokens.darkMuted : EcoTokens.muted),
                        ),
                      ),
                      if (widget.isPassword && _isCapsLockOn)
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.arrowFatUp(PhosphorIconsStyle.fill),
                              size: 11.0,
                              color: isDark ? EcoTokens.limeGlow : EcoTokens.primary,
                            ),
                            const SizedBox(width: 3.0),
                            Text(
                              'CAPS LOCK ON',
                              style: TextStyle(
                                fontSize: 10.0,
                                fontWeight: FontWeight.w700,
                                color: isDark ? EcoTokens.limeGlow : EcoTokens.primary,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),

                // Interactive Input Container with 180ms focus glow ring
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0A1E17) : Colors.white,
                    borderRadius: BorderRadius.circular(EcoTokens.radiusField),
                    border: Border.all(
                      color: borderColor,
                      width: _isFocused ? 1.6 : 1.1,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: borderColor.withValues(alpha: isDark ? 0.28 : 0.16),
                              offset: const Offset(0, 0),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: TextFormField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: _obscureText,
                      keyboardType: widget.keyboardType,
                      textInputAction: widget.textInputAction,
                      autofillHints: widget.autofillHints,
                      enabled: widget.enabled,
                      style: EcoTokens.input(isDark: isDark),
                      onChanged: (val) {
                        clearError();
                        widget.onChanged?.call(val);
                      },
                      onFieldSubmitted: (_) => widget.onSubmitted?.call(),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 14.0,
                        ),
                        border: InputBorder.none,
                        hintText: widget.hintText,
                        hintStyle: EcoTokens.input(isDark: isDark).copyWith(
                          color: isDark
                              ? EcoTokens.darkMuted.withValues(alpha: 0.6)
                              : EcoTokens.muted.withValues(alpha: 0.6),
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: PhosphorIcon(
                            widget.prefixIcon,
                            size: EcoTokens.iconSize,
                            color: iconColor,
                          ),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        suffixIcon: widget.isPassword
                            ? IconButton(
                                splashRadius: 20,
                                icon: PhosphorIcon(
                                  _obscureText
                                      ? PhosphorIcons.eyeClosed(PhosphorIconsStyle.bold)
                                      : PhosphorIcons.eye(PhosphorIconsStyle.bold),
                                  size: 18.0,
                                  color: iconColor,
                                icon: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 220),
                                  transitionBuilder: (child, anim) =>
                                      ScaleTransition(scale: anim, child: child),
                                  child: PhosphorIcon(
                                    _obscureText
                                        ? PhosphorIcons.eyeClosed(PhosphorIconsStyle.bold)
                                        : PhosphorIcons.eye(PhosphorIconsStyle.bold),
                                    key: ValueKey<bool>(_obscureText),
                                    size: 18.0,
                                    color: iconColor,
                                  ),
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),

                // Inline Slide-in Error Message
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 200),
                  crossFadeState: hasError
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  firstChild: Padding(
                    padding: const EdgeInsets.only(left: 4.0, top: 5.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 13.0,
                          color: EcoTokens.error,
                        ),
                        const SizedBox(width: 4.0),
                        Expanded(
                          child: Text(
                            _errorMessage ?? '',
                            style: const TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: EcoTokens.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  secondChild: const SizedBox.shrink(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
