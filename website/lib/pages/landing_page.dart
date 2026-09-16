import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

import '../components/code_section.dart';
import '../components/footer.dart';
import '../components/hero_section.dart';
import '../components/invariants_grid.dart';
import '../components/matrix_section.dart';
import '../components/navbar.dart';
import '../components/telemetry_section.dart';
import '../components/topology_section.dart';

class LandingPage extends StatelessComponent {
  const LandingPage({super.key});

  @override
  Component build(BuildContext context) {
    return Component.fragment([
      const Navbar(),
      const HeroSection(),
      const hr(classes: 'rule'),
      const InvariantsGrid(),
      const hr(classes: 'rule'),
      const TelemetrySection(),
      const hr(classes: 'rule'),
      const MatrixSection(),
      const hr(classes: 'rule'),
      const CodeSection(),
      const hr(classes: 'rule'),
      const TopologySection(),
      const Footer(),
    ]);
  }
}
