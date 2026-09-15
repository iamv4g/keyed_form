import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class MatrixSection extends StatelessComponent {
  const MatrixSection({super.key});

  @override
  Component build(BuildContext context) {
    return section(id: 'matrix', classes: 'wrap', [
      span(classes: 'section-kicker mono', [
        .text('// CAPABILITY MATRIX'),
      ]),
      h2(classes: 'section-title display', [
        .text('Built in by default vs built yourself'),
      ]),
      p(classes: 'section-lede', [
        .text(
          'Direct capability comparison across the major Flutter form architectures.',
        ),
      ]),
      div(classes: 'table-scroll', [
        table(classes: 'matrix', [
          thead([
            tr([
              th([.text('Architectural Feature')]),
              th(classes: 'us', [.text('keyed_form')]),
              th([.text('Flutter Form')]),
              th([.text('String-Keyed Reactive')]),
              th([.text('Declarative Builder')]),
              th([.text('Sealed-State Validator')]),
            ]),
          ]),
          tbody([
            tr([
              td(classes: 'feat', [.text('Compile-time typed field access')]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'yes', [.text('✓')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('List rows keep identity across reorder'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Rebuild cost independent of form size (O(1))'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'yes', [.text('✓')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Nested objects & discriminated unions'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Freeze a field, and everything under it'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Derived / computed fields without rebuild cascades'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Async validation with distinct "check failed" state'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'partial', [.text('~')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [.text('Built-in scroll-to-first-error')]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'no', [.text('✗')]),
            ]),
            tr([
              td(classes: 'feat', [
                .text('Form logic testable with zero pumped widgets'),
              ]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'yes', [.text('✓')]),
              td(classes: 'no', [.text('✗')]),
              td(classes: 'yes', [.text('✓')]),
            ]),
          ]),
        ]),
      ]),
      div(classes: 'matrix-legend mono', [
        span([
          b(classes: 'yes', [.text('✓')]),
          .text(' Built in'),
        ]),
        span([
          b(classes: 'partial', [.text('~')]),
          .text(' Possible with user wiring'),
        ]),
        span([
          b(classes: 'no', [.text('✗')]),
          .text(' Not supported'),
        ]),
      ]),
    ]);
  }
}
