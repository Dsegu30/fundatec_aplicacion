import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NavegacionGlass extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final bool wide;
  final bool compact;
  final bool showAvisosBadge;

  const NavegacionGlass({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.wide = false,
    this.compact = false,
    this.showAvisosBadge = false,
  });

  static const _items = [
    (Icons.home_rounded, Icons.home_outlined, 'Inicio'),
    (Icons.calendar_month_rounded, Icons.calendar_month_outlined, 'Calendario'),
    (Icons.notifications_rounded, Icons.notifications_none_rounded, 'Avisos'),
    (Icons.person_rounded, Icons.person_outline_rounded, 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      minimum: EdgeInsets.fromLTRB(
        wide ? 24 : 14,
        0,
        wide ? 24 : 14,
        compact ? 8 : 12,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: wide ? 760 : 460),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 6 : 8,
                  vertical: compact ? 6 : 8,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      (dark ? const Color(0xFF26384A) : Colors.white)
                          .withValues(alpha: dark ? 0.96 : 0.46),
                      (dark ? const Color(0xFF172534) : Colors.white)
                          .withValues(alpha: dark ? 0.9 : 0.24),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: (dark ? const Color(0xFF8FA5BA) : Colors.white)
                        .withValues(alpha: dark ? 0.9 : 0.78),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10243B).withValues(alpha: 0.13),
                      blurRadius: 34,
                      spreadRadius: 1,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: dark ? 0.08 : 0.9),
                      blurRadius: 2,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
                child: Row(
                  children: List.generate(_items.length, (index) {
                    final item = _items[index];
                    final selected = selectedIndex == index;

                    return Expanded(
                      child: Semantics(
                        button: true,
                        selected: selected,
                        label: item.$3,
                        child: Tooltip(
                          message: item.$3,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              HapticFeedback.selectionClick();
                              onSelected(index);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 420),
                              curve: Curves.easeOutCubic,
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 7 : 9,
                                horizontal: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                gradient: selected
                                    ? LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          dark
                                              ? const Color(0xFF33495F)
                                              : Colors.white.withValues(
                                                  alpha: 0.98,
                                                ),
                                          (dark
                                                  ? const Color(0xFF293D51)
                                                  : const Color(0xFFE5F4FF))
                                              .withValues(alpha: 0.94),
                                          (dark
                                                  ? const Color(0xFF203447)
                                                  : const Color(0xFFD5EAFB))
                                              .withValues(alpha: 0.88),
                                        ],
                                      )
                                    : null,
                                border: selected
                                    ? Border.all(
                                        color:
                                            (dark
                                                    ? const Color(0xFF526A81)
                                                    : Colors.white)
                                                .withValues(alpha: 0.95),
                                      )
                                    : null,
                                boxShadow: selected
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF2D80B9)
                                              .withValues(alpha: 0.16),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: dark ? 0.08 : 0.95,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, -1),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutBack,
                                scale: selected ? 1.04 : 1,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 350,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      width: selected ? 42 : 38,
                                      height: selected ? 32 : 30,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(18),
                                        gradient: selected
                                            ? const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF17466D),
                                                  Color(0xFF0B263F),
                                                ],
                                              )
                                            : null,
                                        boxShadow: selected
                                            ? [
                                                BoxShadow(
                                                  color: const Color(0xFF123D60)
                                                      .withValues(alpha: 0.24),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Icon(
                                            selected ? item.$1 : item.$2,
                                            size: selected ? 20 : 21,
                                            color: selected
                                                ? Colors.white
                                                : (dark
                                                      ? const Color(0xFFB0C0D0)
                                                      : const Color(
                                                          0xFF657487,
                                                        )),
                                          ),
                                          if (index == 2 && showAvisosBadge)
                                            Positioned(
                                              top: -2,
                                              right: -3,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFF3478F6,
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: dark
                                                        ? const Color(
                                                            0xFF26384A,
                                                          )
                                                        : Colors.white,
                                                    width: 1.3,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 260,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: selected ? 4 : 2,
                                        ),
                                        child: Text(
                                          item.$3,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: compact ? 9.5 : 10.5,
                                            height: 1.1,
                                            fontWeight: selected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            letterSpacing: -0.1,
                                            color: selected
                                                ? (dark
                                                      ? const Color(0xFFD7E9FF)
                                                      : const Color(0xFF123D60))
                                                : (dark
                                                      ? const Color(0xFFB0C0D0)
                                                      : const Color(
                                                          0xFF64748B,
                                                        )),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
