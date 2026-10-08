import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';
import 'vehicle_icons.dart';

/// Clean, non-redundant vehicle identity strip with left accent bar and compact emission block
class VehicleContextStrip extends StatelessWidget {
  final String modeKey;
  final String vehicleName;
  final String categoryBadge;
  final String description;
  final double emissionFactor;
  final bool isDark;

  const VehicleContextStrip({
    super.key,
    required this.modeKey,
    required this.vehicleName,
    required this.categoryBadge,
    required this.description,
    required this.emissionFactor,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = EcoDesignTokens.getVehicleAccent(modeKey);
    // Relative intensity: 0.0 to 0.30 kg/km scale
    final intensityRatio = (emissionFactor / 0.30).clamp(0.0, 1.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? EcoDesignTokens.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusTile),
        border: Border.all(
          color: isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
          width: 1.0,
        ),
        boxShadow: EcoDesignTokens.cardElevation,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(EcoDesignTokens.radiusTile),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Left Color Accent Bar
              Container(
                width: 5.0,
                color: accent,
              ),

              // 2. Identity & Category Column
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  child: Row(
                    children: [
                      // Duotone Icon Circle
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: isDark ? 0.20 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: VehicleIcon(
                            modeKey: modeKey,
                            size: 22.0,
                            primaryColor: accent,
                            secondaryColor: accent.withValues(alpha: 0.5),
                            isSelected: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),

                      // Text Block
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(
                                  vehicleName,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w800,
                                    color: isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                                  ),
                                ),
                                const SizedBox(width: 6.0),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(alpha: isDark ? 0.25 : 0.12),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    categoryBadge.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.5,
                                      color: accent,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              description,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Compact Emission Rate Block with Mini Intensity Bar
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 12.0, bottom: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${emissionFactor.toStringAsFixed(4)} kg',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        fontFeatures: EcoDesignTokens.tabularFeatures,
                        color: isDark ? EcoDesignTokens.darkInk : EcoDesignTokens.deepEmerald,
                      ),
                    ),
                    const SizedBox(height: 1.0),
                    Text(
                      'CO₂e/km',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11.0,
                        fontWeight: FontWeight.w600,
                        color: isDark ? EcoDesignTokens.darkMuted : EcoDesignTokens.muted,
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    // Mini Intensity Bar (50px wide)
                    Container(
                      width: 50.0,
                      height: 3.5,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF163228) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: intensityRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            color: EcoDesignTokens.getEmissionColor(emissionFactor),
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

