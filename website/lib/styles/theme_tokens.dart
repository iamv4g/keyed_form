import 'package:jaspr/dom.dart';

abstract final class AppColors {
  // Brand & Semantic Accents
  static const cyan = Color.variable('--cyan');
  static const cyanGlow = Color.variable('--cyan-glow');
  static const amber = Color.variable('--amber');
  static const amberGlow = Color.variable('--amber-glow');
  static const green = Color.variable('--green');
  static const red = Color.variable('--red');

  // Semantic Surface & Theme Colors
  static const bg = Color.variable('--bg');
  static const surface = Color.variable('--surface');
  static const surfaceElevated = Color.variable('--surface-elevated');
  static const border = Color.variable('--border');
  static const borderBright = Color.variable('--border-bright');
  static const ink = Color.variable('--ink');
  static const inkMuted = Color.variable('--ink-muted');
  static const inkFaint = Color.variable('--ink-faint');
  static const grid = Color.variable('--grid');
}

const darkThemeTokens = <String, String>{
  '--bg': '#070b0e',
  '--surface': '#0e141b',
  '--surface-elevated': '#141d26',
  '--border': '#1f2c38',
  '--border-bright': '#304456',
  '--ink': '#eaf2f8',
  '--ink-muted': '#8397a7',
  '--ink-faint': '#445666',
  '--cyan': '#00f0ff',
  '--cyan-glow': 'rgba(0, 240, 255, 0.16)',
  '--amber': '#ffb020',
  '--amber-glow': 'rgba(255, 176, 32, 0.16)',
  '--green': '#00e599',
  '--red': '#ff4d4d',
  '--grid': 'rgba(0, 240, 255, 0.04)',
  '--card-shadow': '0 4px 20px rgba(0, 0, 0, 0.5)',
};

const lightThemeTokens = <String, String>{
  '--bg': '#f4f7f9',
  '--surface': '#ffffff',
  '--surface-elevated': '#eaf0f4',
  '--border': '#d3dfe8',
  '--border-bright': '#a8bfcf',
  '--ink': '#0b1924',
  '--ink-muted': '#4b6375',
  '--ink-faint': '#98abb9',
  '--cyan': '#008799',
  '--cyan-glow': 'rgba(0, 135, 153, 0.12)',
  '--amber': '#c97200',
  '--amber-glow': 'rgba(201, 114, 0, 0.12)',
  '--green': '#0a8e5c',
  '--red': '#d62828',
  '--grid': 'rgba(0, 135, 153, 0.05)',
  '--card-shadow': '0 4px 20px rgba(11, 25, 36, 0.06)',
};
