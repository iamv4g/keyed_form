/// Optional subpath when publishing below a repository path, e.g. `/keyed_form`
/// on the GitHub Pages project URL. Empty for local development and custom
/// domains served from the origin root.
///
/// `jaspr build` pre-renders every route through an internal server that
/// always serves from `/`, so anchor hrefs baked into the static HTML at
/// build time need this prefix hardcoded — there's no CLI flag for it, and
/// jaspr_router's `Link` only resolves the real `<base>` path client-side,
/// after hydration. Set via `--dart-define=SITE_BASE_PATH=/keyed_form` only
/// when deploying below a repository path; the custom-domain build leaves it
/// unset.
const siteBasePath = String.fromEnvironment('SITE_BASE_PATH');
