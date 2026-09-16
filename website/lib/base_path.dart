/// The subpath this site is served under, e.g. `/keyed_form` on GitHub
/// Pages (`https://iamv4g.github.io/keyed_form/`). Empty for local dev,
/// where `jaspr serve`/`jaspr build` always serve from `/`.
///
/// `jaspr build` pre-renders every route through an internal server that
/// always serves from `/`, so anchor hrefs baked into the static HTML at
/// build time need this prefix hardcoded — there's no CLI flag for it, and
/// jaspr_router's `Link` only resolves the real `<base>` path client-side,
/// after hydration. Set via `--dart-define=SITE_BASE_PATH=/keyed_form` (only
/// the deploy workflow passes it) so it stays empty everywhere else.
const siteBasePath = String.fromEnvironment('SITE_BASE_PATH');
