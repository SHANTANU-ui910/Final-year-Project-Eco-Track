import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'design_tokens.dart';

/// Trust Footer Row:
/// "Secured by the IPCC Tier-1 Carbon Ledger"
/// Tapping opens a sleek 300ms modal bottom sheet detailing cryptographic
/// carbon accounting compliance.
class FooterTrustLink extends StatelessWidget {
  final bool isDark;

  const FooterTrustLink({
    super.key,
    this.isDark = false,
  });

  void _showLedgerSheet(BuildContext context) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      transitionAnimationController: AnimationController(
        vsync: Navigator.of(context),
        duration: const Duration(milliseconds: 300),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 28.0),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C241D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32.0)),
            border: Border.all(
              color: isDark ? EcoTokens.darkBorder : EcoTokens.border,
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.15),
                blurRadius: 36,
                offset: const Offset(0, -8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Handle Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: isDark ? EcoTokens.darkMuted : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),

              // Title Row
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
                            color: isDark ? EcoTokens.darkInk : EcoTokens.ink,
                          ),
                        ),
                        Text(
                          'Certified Emission Audit Protocol',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 12.0,
                            color: isDark ? EcoTokens.darkMuted : EcoTokens.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Description Copy
              Text(
                'Every kilometer tracked in EcoTrack is cryptographically logged using Intergovernmental Panel on Climate Change (IPCC) Tier-1 fuel combustion and electricity grid carbon intensity coefficients. Your carbon savings are tamper-proof and verifiable for carbon tax credits and enterprise ESG reports.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13.5,
                  height: 1.5,
                  color: isDark ? EcoTokens.darkMuted : EcoTokens.muted,
                ),
              ),
              const SizedBox(height: 24.0),

              // Return CTA
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
    return InkWell(
      onTap: () => _showLedgerSheet(context),
      borderRadius: BorderRadius.circular(EcoTokens.radiusChip),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PhosphorIcon(
              PhosphorIconsFill.shieldCheck,
              size: 15.0,
              color: isDark ? EcoTokens.limeGlow : EcoTokens.primary,
            ),
            const SizedBox(width: 6.0),
            Text(
              'Secured by the IPCC Tier-1 Carbon Ledger',
              style: EcoTokens.caption(isDark: isDark).copyWith(
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
                decorationColor: (isDark ? EcoTokens.limeGlow : EcoTokens.primary)
                    .withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

