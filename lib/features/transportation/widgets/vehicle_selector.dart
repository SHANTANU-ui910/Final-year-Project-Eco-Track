import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/design_tokens.dart';
import 'vehicle_icons.dart';

class VehicleSelectorItem {
  final String key;
  final String label;
  final Color accentColor;

  const VehicleSelectorItem({
    required this.key,
    required this.label,
    required this.accentColor,
  });
}

/// 64dp sliding pill segmented control with spring damping physics and micro-hop animation
class VehicleSelector extends StatefulWidget {
  final String selectedMode;
  final ValueChanged<String> onModeChanged;
  final bool isDark;

  static const List<VehicleSelectorItem> items = [
    VehicleSelectorItem(key: 'scooty', label: 'Scooty', accentColor: EcoDesignTokens.scootyCoral),
    VehicleSelectorItem(key: 'bike', label: 'Bike', accentColor: EcoDesignTokens.bikeAmber),
    VehicleSelectorItem(key: 'car', label: 'Car', accentColor: EcoDesignTokens.carEmerald),
    VehicleSelectorItem(key: 'bus', label: 'Bus', accentColor: EcoDesignTokens.busSky),
  ];

  const VehicleSelector({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
    this.isDark = false,
  });

  @override
  State<VehicleSelector> createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = VehicleSelector.items.indexWhere(
      (item) => item.key.toLowerCase() == widget.selectedMode.toLowerCase(),
    );
    final activeIndex = selectedIndex == -1 ? 2 : selectedIndex; // Default Car
    final activeItem = VehicleSelector.items[activeIndex];

    return Container(
      height: 64.0,
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: widget.isDark
            ? const Color(0xFF0C2019)
            : const Color(0xFFE8F3EC),
        borderRadius: BorderRadius.circular(22.0),
        border: Border.all(
          color: widget.isDark ? EcoDesignTokens.darkBorder : EcoDesignTokens.border,
          width: 1.0,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final pillWidth = (constraints.maxWidth - 6) / 4;

          return Stack(
            children: [
              // Gliding Pill Indicator with Spring Damping
              AnimatedPositioned(
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutCubic,
                left: activeIndex * pillWidth,
                top: 0,
                bottom: 0,
                width: pillWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        activeItem.accentColor,
                        activeItem.accentColor.withValues(alpha: 0.85),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18.0),
                    boxShadow: [
                      BoxShadow(
                        color: activeItem.accentColor.withValues(alpha: 0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 14,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                ),
              ),

              // Interactive 4 Vehicle Buttons
              Row(
                children: List.generate(VehicleSelector.items.length, (index) {
                  final item = VehicleSelector.items[index];
                  final isSelected = index == activeIndex;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.selectionClick();
                          widget.onModeChanged(item.key);
                        }
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Vector Icon with selected hop
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutBack,
                            transform: Matrix4.translationValues(
                              0,
                              isSelected ? -2.0 : 0.0,
                              0,
                            ),
                            child: VehicleIcon(
                              modeKey: item.key,
                              size: 26.0,
                              isSelected: isSelected,
                              primaryColor: isSelected
                                  ? Colors.white
                                  : (widget.isDark
                                      ? EcoDesignTokens.darkMuted
                                      : const Color(0xFF64748B)),
                              secondaryColor: isSelected
                                  ? Colors.white.withValues(alpha: 0.65)
                                  : (widget.isDark
                                      ? EcoDesignTokens.darkMuted.withValues(alpha: 0.4)
                                      : const Color(0xFF94A3B8)),
                            ),
                          ),
                          const SizedBox(height: 3.0),
                          // Text Label
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 11.5,
                              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (widget.isDark
                                      ? EcoDesignTokens.darkMuted
                                      : EcoDesignTokens.muted),
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}

