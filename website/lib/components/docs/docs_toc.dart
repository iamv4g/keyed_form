import 'package:jaspr/dom.dart';
import 'package:jaspr/jaspr.dart';

class DocsToc extends StatelessComponent {
  const DocsToc({super.key});

  @override
  Component build(BuildContext context) {
    return aside(classes: 'docs-toc', [
      div(classes: 'docs-toc-header mono', [.text('ON THIS PAGE')]),
      ul(classes: 'docs-toc-list', [
        li([
          a(href: '/docs#overview', [.text('Overview & Problem')]),
        ]),
        li([
          a(href: '/docs#mental-model', [.text('The Mental Model')]),
        ]),
        li([
          a(href: '/docs#quickstart', [.text('Quickstart in 5 Min')]),
        ]),
        li([
          a(href: '/docs#package-architecture', [.text('Package Architecture')]),
        ]),
        li([
          a(href: '/docs#controller-lifecycle', [.text('Controller Lifecycle')]),
        ]),
        li([
          a(href: '/docs#field-handles', [.text('Field Handles & Mutations')]),
        ]),
        li([
          a(href: '/docs#relations', [.text('Cross-Field Relations')]),
        ]),
        li([
          a(href: '/docs#validation', [.text('Validation & Server Errors')]),
        ]),
        li([
          a(href: '/docs#virtualization', [.text('Virtualization & Lazy Scroll')]),
        ]),
        li([
          a(href: '/docs#scroll-to-first-error', [.text('Scroll-to-First-Error')]),
        ]),
        li([
          a(href: '/docs#recipes', [.text('Production Recipes')]),
        ]),
        li([
          a(href: '/docs#testing-without-widgets', [.text('Testing Without Widgets')]),
        ]),
        li([
          a(href: '/docs#api-reference', [.text('API Reference')]),
        ]),
        li([
          a(href: '/docs#faq', [.text('Gotchas & FAQ')]),
        ]),
        li([
          a(href: '/docs#benchmarks-methodology', [.text('Benchmarks & Methodology')]),
        ]),
      ]),
    ]);
  }
}
