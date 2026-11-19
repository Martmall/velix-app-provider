import 'package:flutter/material.dart';

/// Every colour token from DESIGN.md (velix-web), by its token name.
///
/// Screens should read colours from `Theme.of(context).colorScheme` and the [VelixColors]
/// extension so they follow light and night automatically. These constants exist for the
/// places that can't (const widgets, the legacy hard-coded screens) and as the single source
/// the themes are built from. Never add a colour here that DESIGN.md doesn't define.
abstract final class VelixPalette {
  // Light
  static const Color ink = Color(0xFF14213D);
  static const Color onInk = Color(0xFFFBF8F2);
  static const Color inkHover = Color(0xFF1D2E52);
  static const Color stone = Color(0xFFEFE8DC);
  static const Color paper = Color(0xFFFBF8F2);
  static const Color stone2 = Color(0xFFE6DDCD);
  static const Color stone3 = Color(0xFFDCD1BE);
  static const Color muted = Color(0xFF4E5566);
  static const Color line = Color(0xFFD8CDB9);
  static const Color lineStrong = Color(0xFFA89C86);
  static const Color copper = Color(0xFFA4531F);
  static const Color onCopper = Color(0xFFFBF8F2);
  static const Color copperSoft = Color(0xFFF1DCCB);
  static const Color onCopperSoft = Color(0xFF5A2A0C);
  static const Color brass = Color(0xFF7A5C2E);
  static const Color brassLight = Color(0xFFD7B47A);
  static const Color brassSoft = Color(0xFFEDE0C6);
  static const Color claim = Color(0xFFB8372A);
  static const Color claimSoft = Color(0xFFF6DCD6);
  static const Color amberSoft = Color(0xFFF7E3B5);
  static const Color onAmberSoft = Color(0xFF4A3200);
  static const Color go = Color(0xFF2E6B4F);
  static const Color goSoft = Color(0xFFD8E8DD);
  static const Color onGoSoft = Color(0xFF173D2C);
  static const Color vault = Color(0xFF14213D);
  static const Color onVault = Color(0xFFFBF8F2);
  static const Color onVaultMuted = Color(0xFFE3DCCF);

  // Night
  static const Color nightStone = Color(0xFF0F1729);
  static const Color nightStone2 = Color(0xFF172238);
  static const Color nightStone3 = Color(0xFF22304D);
  static const Color nightPaper = Color(0xFF1A263F);
  static const Color nightLine = Color(0xFF2C3A58);
  static const Color nightLineStrong = Color(0xFF5A6888);
  static const Color nightMuted = Color(0xFFAEB6C8);
  static const Color nightInk = Color(0xFFEFE8DC);
  static const Color nightOnInk = Color(0xFF14213D);
  static const Color nightCopper = Color(0xFFE08A55);
  static const Color nightOnCopper = Color(0xFF14213D);
  static const Color nightCopperSoft = Color(0xFF4A2A16);
  static const Color nightOnCopperSoft = Color(0xFFF3C9A8);
  static const Color nightBrass = Color(0xFFD7B47A);
  static const Color nightBrassSoft = Color(0xFF33291A);
  static const Color nightAmberSoft = Color(0xFF3A2C0B);
  static const Color nightOnAmberSoft = Color(0xFFF6D58C);
  static const Color nightGo = Color(0xFF7FD3A6);
  static const Color nightGoSoft = Color(0xFF173126);
  static const Color nightOnGoSoft = Color(0xFFA8D7BC);
  static const Color nightClaim = Color(0xFFFF8A7A);
  static const Color nightClaimSoft = Color(0xFF3A1712);
  static const Color nightVault = Color(0xFF22304D);
  static const Color nightOnVault = Color(0xFFEFE8DC);
}

/// Corner radii from DESIGN.md ("rounded").
abstract final class VelixRadius {
  static const double segment = 2;
  static const double tag = 6;
  static const double chip = 8;
  static const double strip = 10;
  static const double control = 12;
  static const double card = 14;
  static const double indicator = 16;
  static const double full = 999;
}

/// Spacing scale from DESIGN.md.
abstract final class VelixSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double ticketInset = 14;
  static const double gutter = 16;
  static const double ticketPad = 18;
  static const double xl = 24;
}

/// The one shadow: "ticket lift", for the search sheet and the full claim ticket only.
abstract final class VelixShadows {
  static const List<BoxShadow> ticketLift = [
    BoxShadow(color: Color(0x0F14213D), offset: Offset(0, 1)),
    BoxShadow(color: Color(0x3814213D), offset: Offset(0, 10), blurRadius: 24, spreadRadius: -8),
  ];
}
